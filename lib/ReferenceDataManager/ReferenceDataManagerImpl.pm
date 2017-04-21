package ReferenceDataManager::ReferenceDataManagerImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = '0.0.1';
our $GIT_URL = 'https://qzzhang@github.com/kbaseapps/ReferenceDataManager.git';
our $GIT_COMMIT_HASH = '77348aab993d0502c32cc11962b14f1441f08917';

=head1 NAME

ReferenceDataManager

=head1 DESCRIPTION

A KBase module: ReferenceDataManager

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Workspace::WorkspaceClient;
use GenomeFileUtil::GenomeFileUtilClient;
use KBSolrUtil::KBSolrUtilClient;
use RAST_SDK::RAST_SDKClient;

use Config::IniFiles;
use Config::Simple;
use POSIX;
use FindBin qw($Bin);
use JSON;
use Data::Dumper qw(Dumper);
use LWP::UserAgent;
use XML::Simple;
use Try::Tiny;
use DateTime;

#The first thing every function should do is call this function
sub util_initialize_call {
    my ($self,$params,$ctx) = @_;
    $self->{_token} = $ctx->token();
    $self->{_username} = $ctx->user_id();
    $self->{_method} = $ctx->method();
    $self->{_provenance} = $ctx->provenance();

    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    $self->{data} = $cfg->val('ReferenceDataManager','data');
    $self->{scratch} = $cfg->val('ReferenceDataManager','scratch');
    $self->{workspace_url} = $cfg->val('ReferenceDataManager','workspace-url');#$config->{"workspace-url"}; 
    die "no workspace-url defined" unless $self->{workspace_url};
    
    $self->util_timestamp(DateTime->now()->datetime());
    $self->{_wsclient} = new Workspace::WorkspaceClient($self->{workspace_url},token => $ctx->token());
    return $params;
}

#This function returns the version of the current method
sub util_version {
    my ($self) = @_;
    return "1";
}

#This function returns the token of the user running the SDK method
sub util_token {
    my ($self) = @_;
    return $self->{_token};
}

#This function returns the username of the user running the SDK method
sub util_username {
    my ($self) = @_;
    return $self->{_username};
}

#This function returns the name of the SDK method being run
sub util_method {
    my ($self) = @_;
    return $self->{_method};
}

#Use this function to log messages to the SDK console
sub util_log {
    my($self,$message) = @_;
    print $message."\n";
}

#Use this function to get a client for the workspace service
sub util_ws_client {
    my ($self,$input) = @_;
    return $self->{_wsclient};
}

#This function validates the arguments to a method making sure mandatory arguments are present and optional arguments are set
sub util_args {
    my($self,$args,$mandatoryArguments,$optionalArguments,$substitutions) = @_;
    if (!defined($args)) {
        $args = {};
    }
    if (ref($args) ne "HASH") {
        die "Arguments not hash";
    }
    if (defined($substitutions) && ref($substitutions) eq "HASH") {
        foreach my $original (keys(%{$substitutions})) {
            $args->{$original} = $args->{$substitutions->{$original}};
        }
    }
    if (defined($mandatoryArguments)) {
        for (my $i=0; $i < @{$mandatoryArguments}; $i++) {
            if (!defined($args->{$mandatoryArguments->[$i]})) {
                push(@{$args->{_error}},$mandatoryArguments->[$i]);
            }
        }
    }
    if (defined($args->{_error})) {
        die "Mandatory arguments ".join("; ",@{$args->{_error}})." missing";
    }
    foreach my $argument (keys(%{$optionalArguments})) {
        if (!defined($args->{$argument})) {
            $args->{$argument} = $optionalArguments->{$argument};
        }
    }
    return $args;
}

#This function specifies the name of the workspace where genomes are loaded for the specified source database
sub util_workspace_names {
    my($self,$source) = @_;
    if (!defined($self->{_workspace_map}->{$source})) {
        die "No workspace specified for source: ".$source;
    }
    return $self->{_workspace_map}->{$source};
}

#This function returns a timestamp recorded when the functionw was first started
sub util_timestamp {
    my ($self,$input) = @_;
    if (defined($input)) {
        $self->{_timestamp} = $input;
    }
    return $self->{_timestamp};
}

sub util_create_report {
    my($self,$args) = @_;
    my $reportobj = {
        text_message => $args->{"message"},
        objects_created => []
    };
    if (defined($args->{objects})) {
        for (my $i=0; $i < @{$args->{objects}}; $i++) {
            push(@{$reportobj->{objects_created}},{
                'ref' => $args->{objects}->[$i]->[0],
                description => $args->{objects}->[$i]->[1]
            });
        }
    }
    $self->util_ws_client()->save_objects({
        workspace => $args->{workspace},
        objects => [{
            provenance => $self->{_provenance},
            type => "KBaseReport.Report",
            data => $reportobj,
            hidden => 1,
            name => $self->util_method()
        }]
    });
}

#################### methods for accessing SOLR using its web interface#######################
#
#
# Internal Method: to list the genomes already in SOLR and return an array of those genomes
# Input parameters:
#       $solrCore: string, the name of the solr core
#       $fields: comma delimited string of field names, default to all fields ('*')
#       $rowStart: an integer that offsets the rows before displaying the results, default to 0
#       $rowCount: an integer for how many rows of results to display, default to 0 meaning to display all result rows
#       $gnm_type: a string indicating the type of genomes to be returned
#       $dmn: a string indicating the domain of the genomes to be returned
#       $cmplt: an integer (1 for complete genomes only, or 0 for all genomes)
# Output: a list of KBSolrUtil.solrdoc
#
sub _listGenomesInSolr {
    my ($self, $solrCore, $fields, $rowStart, $rowCount, $gnm_type, $dmn, $cmplt) = @_;
    my $start = ($rowStart) ? $rowStart : 0;
    my $count = ($rowCount) ? $rowCount : 0;
    $fields = "*" unless $fields;
    $gnm_type = "KBaseGenomes.Genome-8.2" unless $gnm_type;
    
    my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service_version=ver parameter when master is done.
    #my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL });
    
    my $query = {"object_type"=>$gnm_type};#{ q => "*" };
        
    if( defined( $cmplt )) {
        if( defined( $dmn )) {
            $query = { domain=>$dmn, complete=>$cmplt, object_type=>$gnm_type };
        }
        else {
            $query = { complete=>$cmplt, object_type=>$gnm_type };
        }
    }
    else {
        if( defined( $dmn )) {
            $query = { domain=>$dmn, object_type=>$gnm_type};
        }
    }
    my $solrgnms;
    if($count == 0) {#get the real total count
        $count = $solrer->get_total_count({search_core=>$solrCore, search_query=>$query});
    }

    my $params = {
        fl => $fields,
        wt => "json",
        rows => $count,
        sort => "genome_id asc",
        hl => "false",
        start => $start
    };
    
    eval {
        $solrgnms = $solrer->search_solr({
          search_core => $solrCore,
          search_param => $params,
          search_query => $query,
          result_format => "json",
          group_option => "",
          skip_escape => {}
        });  
    };   
    if ($@) {
         print "ERROR:".$@;
         return undef;
    } else {
        #print "Search results:" . Dumper($solrgnms->{response}) . "\n";
        return $solrgnms;
    }
}

#
#Internal Method: to list the taxa already in SOLR and returns those taxa as a list of KBSolrUtil.solrdoc
#
sub _listTaxaInSolr {
    my ($self, $solrCore, $fields, $rowStart, $rowCount, $grp) = @_;
    $solrCore = ($solrCore) ? $solrCore : "taxonomy_prod";
    my $start = ($rowStart) ? $rowStart : 0;
    my $count = ($rowCount) ? $rowCount : 0;
    $fields = ($fields) ? $fields : "*";
    
    my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service_version=ver parameter when master is done.
    #my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL });

    my $query = { q => "*" };
    my $solrout;
    if($count == 0) {#get the real total count
        $count = $solrer->get_total_count({search_core=>$solrCore, search_query=>$query});
    }
    my $params = {
        fl => $fields,
        wt => "json",
        rows => $count,
        sort => "taxonomy_id asc",
        hl => "false",
        start => $start
    };
    
    eval {
        $solrout = $solrer->search_solr({
          search_core => $solrCore,
          search_param => $params,
          search_query => $query,
          result_format => "json",
          group_option => $grp,
          skip_escape => {}
        });  
    };   
    if ($@) {
         print "ERROR:".$@;
         return undef;
    } else {
        #print "Search results:" . Dumper($solrout->{response}) . "\n";
        return $solrout;
    }
}

#
# method name: _updateGenomesCore
# Internal method: to update the Genomes_* core with the corresponding GenomeFeatures_* core.
# Input parameters:   
#     $src_core: This parameter specifies the source Solr core name.
#     $dest_core: This parameter specifies the target Solr core name.
#     $gnm_type: This parameter specifies the type of genomes to be updated, default to "KBaseGenomes.Genome-8.2".
# return
#    1 for success
#    0 for any failure
#
#
sub _updateGenomesCore
{
    my ($self, $src_core, $dest_core, $gnm_type) = @_;
    my $solrgnms;
    my $ret_gnms;
    $src_core = "GenomeFeatures_ci" unless $src_core;
    $dest_core = "Genome_ci" unless $dest_core;
    $gnm_type = "KBaseGenomes.Genome-8.2" unless $gnm_type;

    my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service_version=ver parameter when master is done.
    #my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL });

    eval {
        $solrgnms = $solrer->search_solr({
          search_core => $src_core,
          search_param => {
                rows => 100000,
                wt => 'json'
          },
          search_query => {"object_type"=>$gnm_type},
          result_format => "json",
          group_option => "",
          skip_escape => {}
        });
    };
    if ($@) {
         print "ERROR from search_solr:".$@;
         return 0;
    } else {
         #print "Search results:" . Dumper($solrgnms->{response}->{response}) . "\n";
         $ret_gnms = $solrgnms->{response}->{response}->{docs};
         my $num = $solrgnms->{response}->{response}->{numFound};
         foreach my $gnm (@{$ret_gnms}) {
            delete $gnm->{_version_};
         }
         eval {
                $solrer->add_json_2solr({solr_core=>$dest_core, json_docs=>$ret_gnms});
         };
         if ($@) {
                print "ERROR:".$@;
                return 0;
         } else {
                #print "Done updating " . $dest_core . " with ". $src_core. "!";
                return 1;
         }
    }
}

#
# Internal Method: to check if a given genome has been indexed by KBase in SOLR.  Returns a string stating the status
#
# Input parameters :
# $current_genome is a genome object whose KBase status is to be checked.
# $solr_core is the name of the SOLR core
#
# returns : a string stating the status
#    
sub _checkTaxonStatus
{
    my ($self, $current_genome, $solr_core) = @_;
    #print "\nChecking taxon status for genome:\n " . Dumper($current_genome) . "\n";
    
    my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service_version=ver parameter when master is done.
    #my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL });
    
    my $status = "";
    my $query = { taxonomy_id => $current_genome->{tax_id} };
    
    if($solrer->exists_in_solr({search_core=>$solr_core,search_query=>{taxonomy_id=>$current_genome->{tax_id}}})==1) {
        $status = "Taxon in KBase";
    }    
    else {
        $status = "Taxon not found";
    }
    #print "\nStatus:$status\n";
    return $status;
}

#
# Internal Method 
# Name: _checkGenomeStatus
# Purpose: to check if a given genome status against genomes in SOLR.  
#
# Input parameters :
#       $current_genome is a genome object whose KBase status is to be checked.
#       $solr_core is the name of the SOLR core
#
# returns : a string stating the status
#    
sub _checkGenomeStatus 
{
    my ($self, $current_genome, $solr_core, $gn_type) = @_;
    #print "\nChecking status for genome:\n " . Dumper($current_genome) . "\n";
    $gn_type = "KBaseGenomes.Genome-8.2" unless $gn_type;

    my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service_version=ver parameter when master is done.
    #my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL });

    my $status = "";
    my $query = { 
        genome_id => $current_genome->{id} . "*", 
        object_type => $gn_type
    };
    my $params = {
        fl => "genome_id",
        wt => "json",
        start => 0
    };
    
    my $solrgnm;
    my $gnms;
    my $gcnt;
    eval {
        $solrgnm = $solrer->search_solr({
          search_core => $solr_core,
          search_param => $params,
          search_query => $query,
          result_format => "json",
          group_option => "",
          skip_escape => {}
        });  
    };   
    if ($@) {
         print "ERROR:".$@;
         $status = "";
    } else {
        #print "Search results:" . Dumper($solrgnm->{response}) . "\n";
        $gnms = $solrgnm->{response}->{response}->{docs};
        $gcnt = $solrgnm->{response}->{response}->{numFound};
    }
    if( $gcnt == 0 ) {
        $status = "New genome";
    }
    else {
        for (my $i = 0; $i < @{$gnms}; $i++ ) {
            my $record = $gnms->[$i];
            my $gm_id = uc $record->{genome_id};

            if ($gm_id eq uc $current_genome->{accession}){
                $status = "Existing genome: current";
                $current_genome->{genome_id} = $gm_id;
                last;
            }elsif ($gm_id =~/uc $current_genome->{id}/){
                $status = "Existing genome: updated ";
                $current_genome->{genome_id} = $gm_id;
                last;
            }
        }
    }
        
    if( $status eq "" )
    {
        $status = "New genome";#or "Existing genome: status unknown";
    }
    
    #print "\nStatus:$status\n";
    return $status;
}

#
# Internal method
# Name: _getGenomeInfo
# Purpose: to fetch the information about a genome records from a given genome reference
# Input parameter: a reference to a Workspace.object_info (which is a reference to a list containing 11 items)
# Output: a reference to a hash of the type of ReferenceDataManager.LoadedReferenceGenomeData
#
sub _getGenomeInfo 
{
    my ($self, $ws_objinfo) = @_;
    my $gn_info = [];

    $gn_info = {
        "ref" => $ws_objinfo->[6]."/".$ws_objinfo->[0]."/".$ws_objinfo->[4],
        id => $ws_objinfo->[0],
        workspace_name => $ws_objinfo->[7],
        type => $ws_objinfo->[2],
        source_id => $ws_objinfo->[10]->{"Source ID"},
        accession => $ws_objinfo->[1],
        name => $ws_objinfo->[1],
        version => $ws_objinfo->[4],
        source => $ws_objinfo->[10]->{Source},
        domain => $ws_objinfo->[10]->{Domain},
        save_date => $ws_objinfo->[3],
        contig_count => $ws_objinfo->[10]->{"Number contigs"},
        feature_count => $ws_objinfo->[10]->{"Number features"},
        size_bytes => $ws_objinfo->[9],
        ftp_url => $ws_objinfo->[10]->{"url"},
        gc => $ws_objinfo->[10]->{"GC content"}
    };
    return $gn_info;
}

#
# Internal method 
# Build the genome solr object for the sake of the search UI/search service
# Input parameters: 
#       $ws_ref: a string of three parts connected with forward slash in the form of 'ws_id/obj_id/obj_ver'
#       $ws_gn_data: an UnspecifiedObject containing data about the genome object
#       $ws_gn_info: a reference to a list containing 11 items
#       $ws_gn_asmlevel: a string indicating the level of the assembly
#       $ws_gn_tax: the genome's taxonomy id
#       $numCDs: the number of genes in the genome
#       $ws_gn_save_date: as it states
# Output: a reference to a hash of the type of ReferenceDataManager.SolrGenomeFeatureData
#
sub _buildSolrGenome
{
    my ($self, $ws_ref, $ws_gn_data, $ws_gn_info, $ws_gn_asmlevel, $ws_gn_tax, $numCDs, $ws_gn_save_date) = @_;

    my $ws_gnobj = {
        object_id => "kb|ws_ref:" . $ws_ref->{ref},
        object_name => "kb|g." . $ws_gn_data->{id}, 
        object_type => $ws_gn_info->[2], 
        ws_ref => $ws_ref->{ref},
        genome_id => $ws_gn_data->{id},
        genome_source_id => $ws_gn_info->[10]->{"Source ID"},
        genome_source => $ws_gn_data->{source},
        genetic_code => $ws_gn_data->{genetic_code},
        domain => $ws_gn_data->{domain},
        scientific_name => $ws_gn_data->{scientific_name},
        genome_dna_size => $ws_gn_info->[10]->{Size},
        num_contigs => $ws_gn_info->[10]->{"Number contigs"},#$ws_gn_data->{num_contigs},
        assembly_ref => $ws_gn_data->{assembly_ref},
        gc_content => $ws_gn_info->[10]->{"GC content"},
        complete => $ws_gn_asmlevel,
        taxonomy => $ws_gn_tax,
        taxonomy_ref => $ws_gn_data->{taxon_ref},
        workspace_name => $ws_gn_info->[7],
        num_cds => $numCDs,
        #gnmd5checksum => $ws_gn_info->[8],
        save_date => $ws_gn_save_date,
        refseq_category => $ws_gn_data->{type}        
   };
   return $ws_gnobj;
}

#
# Internal method 
# Build the genome_feature solr object
# Input parameters: 
#       $ws_gn_feature: the reference pointing to the feature data
#       $ws_ref: a string of three parts connected with forward slash in the form of 'ws_id/obj_id/obj_ver'
#       $ws_gn_data: an UnspecifiedObject containing data about the genome object
#       $ws_gn_info: a reference to a list containing 11 items
#       $ws_gn_asmlevel: a string indicating the level of the assembly
#       $ws_gn_tax: the genome's taxonomy id
#       $numCDs: the number of genes in the genome
#       $ws_gn_save_date: as it states
#
# Output: a reference to a hash of the type of ReferenceDataManager.SolrGenomeFeatureData
#
sub _buildSolrGenomeFeature
{
    my ($self, $ws_gn_feature, $ws_ref, $ws_gn_data, $ws_gn_info, $ws_gn_asmlevel, $ws_gn_tax, $numCDs, $ws_gn_save_date) = @_;

    my $ws_gn_aliases;
    my $ws_gn_nm;
    my $loc_contig;
    my $loc_begin;
    my $loc_end;
    my $loc_strand;
    my $ws_gn_loc;
    my $ws_gn_onterms ={};
    my $ws_gn_roles;
    my $ws_gn_funcs;
    
    if( defined($ws_gn_feature->{aliases})) {
        $ws_gn_nm = $ws_gn_feature->{aliases}[0] unless $ws_gn_feature->{aliases}[0]=~/^(NP_|WP_|YP_|GI|GeneID)/i;
        $ws_gn_aliases = join(";", @{$ws_gn_feature->{aliases}});
        $ws_gn_aliases =~s/ *; */;;/g;
    }
    else {
        $ws_gn_nm = undef;
        $ws_gn_aliases = undef;
    }
        
    $ws_gn_funcs = $ws_gn_feature->{function};
    $ws_gn_funcs = join(";;", split(/\s*;\s+|\s+[\@\/]\s+/, $ws_gn_funcs));
        
    if( defined($ws_gn_feature->{roles}) ) {
        $ws_gn_roles = join(";;", $ws_gn_feature->{roles});
    }
    else {
        $ws_gn_roles = undef;
    }
    
    $loc_contig = "";
    $loc_begin = 0;
    $loc_end = "";
    $loc_strand = "";
    $ws_gn_loc = $ws_gn_feature->{location};
        
    my $end = 0;
    foreach my $contig_loc (@{$ws_gn_loc}) {
        $loc_contig = $loc_contig . ";;" unless $loc_contig eq "";
        $loc_contig = $loc_contig . $contig_loc->[0];
        
        $loc_begin = $loc_begin . ";;" unless $loc_begin eq "";
        $loc_begin = $loc_begin . $contig_loc->[1];
        
        if( $contig_loc->[2] eq "+") {
            $end = $contig_loc->[1] + $contig_loc->[3];
        }
        else {
            $end = $contig_loc->[1] - $contig_loc->[3];
        }
        $loc_end = $loc_end . ";;" unless $loc_end eq "";
        $loc_end = $loc_end . $end;
        
        $loc_strand = $loc_strand . ";;" unless $loc_strand eq "";
        $loc_strand = $loc_strand . $contig_loc->[2];
    }
    
    $ws_gn_onterms = $ws_gn_feature->{ontology_terms};
    
    my $ws_gnft = {
            #genome data (redundant)
                genome_source_id => $ws_gn_info->[10]->{"Source ID"},
                genome_id => $ws_gn_data->{id},
                ws_ref => $ws_ref->{ref},
                genome_source => $ws_gn_data->{source},
                genetic_code => $ws_gn_data->{genetic_code},
                domain => $ws_gn_data->{domain},
                scientific_name => $ws_gn_data->{scientific_name},
                genome_dna_size => $ws_gn_info->[10]->{Size},
                num_contigs => $ws_gn_info->[10]->{"Number contigs"},#$ws_gn_data->{num_contigs},
                assembly_ref => $ws_gn_data->{assembly_ref},
                gc_content => $ws_gn_info->[10]->{"GC content"},
                complete => $ws_gn_asmlevel,
                taxonomy => $ws_gn_tax,
                taxonomy_ref => $ws_gn_data->{taxon_ref},
                workspace_name => $ws_gn_info->[7],
                num_cds => $numCDs,
                save_date => $ws_gn_save_date,
                refseq_category => $ws_gn_data->{type},        
            #feature data
                genome_feature_id => $ws_gn_data->{id} . "|feature:" . $ws_gn_feature->{id},
                object_id => "kb|ws_ref:". $ws_ref->{ref}. "|feature:" . $ws_gn_feature->{id},
                object_name => $ws_gn_info->[1] . "|feature:" . $ws_gn_feature->{id},
                object_type => $ws_gn_info->[2] . ".Feature",
                feature_type => $ws_gn_feature->{type},
                feature_id => $ws_gn_feature->{id},
                functions => $ws_gn_funcs,
                roles => $ws_gn_roles,
                md5 => $ws_gn_feature->{md5},
                gene_name => $ws_gn_nm,
                protein_translation_length => ($ws_gn_feature->{protein_translation_length}) != "" ? $ws_gn_feature->{protein_translation_length} : 0,
                dna_sequence_length => ($ws_gn_feature->{dna_sequence_length}) != "" ? $ws_gn_feature->{dna_sequence_length} : 0,
                aliases => $ws_gn_aliases,
                location_contig => $loc_contig,
                location_strand => $loc_strand,
                location_begin => $loc_begin,
                location_end => $loc_end,
                ontology_namespaces => $ws_gn_feature->{ontology_terms}
    };
    return $ws_gnft;
}

#
#Internal method, to fetch genome records for a given set of ws_ref's and index the genome_feature combo in SOLR.
#
#First call get_objects2() to get the genome object one at a time.
#Then plow through the genome object data to assemble the data items for a Solr genomie_feature object.
#Finally send the data document to Solr for indexing.
#Input: a list of ReferenceDataManager.KBaseReferenceGenomeData
#Output: a list of SolrGenomeFeatureData and the total count of genome_features indexed
#
sub _indexGenomeFeatureData 
{
    my ($self, $solrCore, $ws_gnData) = @_;
    
    my $ws_gnout;
    my $solr_gnftData = [];
    my $gnft_batch = [];
    my $batchCount = 10000;
    my $gn_solr_core = $solrCore;
    my $count = 0;

    my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service_version=ver parameter when master is done.
    #my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL });

    foreach my $ws_gn (@{$ws_gnData}) { 
        my $ws_ref = {"ref" => $ws_gn->{ref}};
        my $gn_id = $ws_gn->{name};
        #check if the genome is already present in the database by querying SOLR
        if(($solrer->exists_in_solr({search_core=>$gn_solr_core,search_query=>{genome_id=>$gn_id}}))==1) {
            print $gn_id . ": has already been indexed in Solr " . $gn_solr_core . ".\n";
        }
        else {
            print $gn_id . ": is not found in Solr " . $gn_solr_core . ".\n";         
            #print "\nStart to fetch the object(s) for " . $gn_id .  " on " . scalar localtime . "\n";
            eval {#return a reference to a list where each element is a Workspace.ObjectData with a key named 'data'
                $ws_gnout = $self->util_ws_client()->get_objects2({
                        objects => [$ws_ref]
                });
            };
            if($@) {
                print "Cannot get object information!\n";
                print "ERROR:".$@;
                if(ref($@) eq 'HASH' && defined($@->{status_line})) {
                    print $@->{status_line}."\n";
                }
            }
            else {
                #print "Done getting genome object info for " . $gn_id . " on " . scalar localtime . "\n";
                $ws_gnout = $ws_gnout->{data};#a reference to a list where each element is a Workspace.ObjectData
                my $ws_gn_data;#to hold a value which is a Workspace.objectData
                my $ws_gn_info;#to hold a value which is a Workspace.object_info
                my $ws_gn_features = {};
                my $ws_gn_tax;
                my $ws_gn_save_date;
                my $numCDs = 0;
                my $ws_gn_asmlevel;

                #fetch individual data item to assemble the genome_feature info for $solr_gnftData
                for (my $i=0; $i < @{$ws_gnout}; $i++) {
                    $ws_gn_data = $ws_gnout->[$i]->{data};#an UnspecifiedObject
                    $ws_gn_info = $ws_gnout->[$i]->{info};#is a reference to a list containing 11 items
                    $ws_gn_features = $ws_gn_data->{features};
                    $ws_gn_tax = $ws_gn_data->{taxonomy};
                    $ws_gn_tax =~s/ *; */;;/g;
                    $ws_gn_save_date = $ws_gn_info->[3];
                    $ws_gn_asmlevel = ($ws_gn_info->[10]->{assembly_level}=~/Complete Genome/i);
                            
                    $numCDs  = 0;
                    foreach my $feature (@{$ws_gn_features}) {
                        if ($feature->{type} eq "gene") {
                            $numCDs++;
                        }
                    }

                    ###1)---Build the genome solr object for the sake of the search UI/search service
                    my $ws_gnobj = $self->_buildSolrGenome($ws_ref, $ws_gn_data, $ws_gn_info, $ws_gn_asmlevel, $ws_gn_tax, $numCDs, $ws_gn_save_date);
                    if( @{$solr_gnftData} < 10 ) {
                        push @{$solr_gnftData}, $ws_gnobj;
                    }
                    push @{$gnft_batch}, $ws_gnobj;
                    $count ++;
                
                    ###2)---Build the genome_feature solr object
                    for (my $ii=0; $ii < @{$ws_gn_features}; $ii++) {
                        my $ws_gnft = $self->_buildSolrGenomeFeature($ws_gn_features->[$ii], $ws_ref, $ws_gn_data, $ws_gn_info, $ws_gn_asmlevel, $ws_gn_tax, $numCDs, $ws_gn_save_date);
                        if( @{$solr_gnftData} < 10 ) {
                            push @{$solr_gnftData}, $ws_gnft;
                        }
                        push @{$gnft_batch}, $ws_gnft;
                        $count ++;
                        
                        if(@{$gnft_batch} >= $batchCount) {
                            eval {
                                $solrer->index_in_solr({solr_core=>$solrCore, doc_data=>$gnft_batch});
                            };
                            if($@) {
                                print "Failed to index the genome_feature(s)!\n";
                                print "ERROR:". Dumper( $@ );
                                if(ref($@) eq 'HASH' && defined($@->{status_line})) {
                                    print $@->{status_line}."\n";
                                }
                            }
                            else {
                                print "\nIndexed " . @{$gnft_batch} . " genome_feature(s) on " . scalar localtime . "\n";
                            }
                            $gnft_batch = [];
                        }
                    }
                    #after looping through all features, index the leftover set of genomeFeature objects
                    if(@{$gnft_batch} > 0) {
                        eval {
                            $solrer->index_in_solr({solr_core=>$solrCore, doc_data=>$gnft_batch});
                        };
                        if($@) {
                            print "Failed to index the genome_feature(s)!\n";
                            print "ERROR:". Dumper( $@ );
                            if(ref($@) eq 'HASH' && defined($@->{status_line})) {
                                print $@->{status_line}."\n";
                            }
                        }
                        else {
                            print "\nIndexed " . @{$gnft_batch} . " genome_feature(s) on " . scalar localtime . "\n";
                        }
                        $gnft_batch = [];
                    }
                }
            }
        }
    }
    return {"genome_features"=>$solr_gnftData,"count"=>$count};
}

#
#internal method, for fetching one taxon record to be indexed in solr
#
sub _getTaxon 
{
    my ($self, $taxonData, $wsref) = @_;

    my $t_aliases = defined($taxonData->{aliases}) ? join(";", @{$taxonData->{aliases}}) : "";
    my $current_taxon = {
        taxonomy_id => $taxonData->{taxonomy_id},
        scientific_name => $taxonData->{scientific_name},
        scientific_lineage => $taxonData->{scientific_lineage},
        rank => $taxonData->{rank},
        kingdom => $taxonData->{kingdom},
        domain => $taxonData->{domain},
        ws_ref => $wsref,
        aliases => $t_aliases,
        genetic_code => ($taxonData->{genetic_code}) ? ($taxonData->{genetic_code}) : "0",
        parent_taxon_ref => $taxonData->{parent_taxon_ref},
        embl_code => $taxonData->{embl_code},
        inherited_div_flag => ($taxonData->{inherited_div_flag}) ? $taxonData->{inherited_div_flag} : "0",
        inherited_GC_flag => ($taxonData->{inherited_GC_flag}) ? $taxonData->{inherited_GC_flag} : "0",
        division_id => ($taxonData->{division_id}) ? $taxonData->{division_id} : "0",
        mitochondrial_genetic_code => ($taxonData->{mitochondrial_genetic_code}) ? $taxonData->{mitochondrial_genetic_code} : "0",
        inherited_MGC_flag => ($taxonData->{inherited_MGC_flag}) ? ($taxonData->{inherited_MGC_flag}) : "0",
        GenBank_hidden_flag => ($taxonData->{GenBank_hidden_flag}) ? ($taxonData->{GenBank_hidden_flag}) : "0",
        hidden_subtree_flag => ($taxonData->{hidden_subtree_flag}) ? ($taxonData->{hidden_subtree_flag}) : "0",
        deleted => ($taxonData->{deleted}) ? ($taxonData->{deleted}) : "0",
        comments => $taxonData->{comments}
    };
    return $current_taxon;
}


#
#internal method, for creating a message string and return it. 
#
sub _genomeInfoString
{
    my ($self, $gn_info) = @_;
    my $retStr = "". $gn_info->{accession}.";".$gn_info->{workspace_name}.";".$gn_info->{domain}.";".$gn_info->{source}.";".$gn_info->{save_date}.";".$gn_info->{contig_count}." contigs;".$gn_info->{feature_count}." features; KBase id:".$gn_info->{ref}."\n";
    return $retStr;
}

#################### End subs for accessing SOLR #######################

#################### Start subs for accessing NCBI refseq genomes#######################

#
# Internal method: _list_ncbi_refgenomes
# params:
#   input:
#       $source: "refseq" | "genbank" {default => "refseq"}
#       $division: "bacteria" | "archaea" | "plant" | "fungi" | multivalued, comma-seperated, {default => "bacteria"}
#       $update_only: 0 | 1 {default => 0}
#   output:
#       a list of ncbi genomes
#
sub _list_ncbi_refgenomes
{
    my ($self, $source, $division, $update_only) = @_;
       
    $source = "refseq" unless $source;
    $update_only = 0 unless $update_only;

    my $output = [];
    my $summary = "";
    my $count = 0;
    
    if(!defined($division)) {
        return undef;
    }
    my @divisions = split /,/, $division;
    foreach my $dvsn (@divisions){
        $count = 0;
        my $assembly_summary_url = "ftp://ftp.ncbi.nlm.nih.gov/genomes/".$source."/".$dvsn."/assembly_summary.txt";
        my $assemblies = [`wget -q -O - $assembly_summary_url`];
    
        foreach my $entry (@{$assemblies}) {
            $count++;
            chomp $entry;
            if ($entry=~/^#/) { #header
                next;
            }
            my @attribs = split /\t/, $entry;
            my $current_genome = {
                source => $source,
                domain => $dvsn
            };
            $current_genome->{accession} = $attribs[0];
            $current_genome->{version_status} = $attribs[10];
            $current_genome->{asm_name} = $attribs[15];
            $current_genome->{ftp_dir} = $attribs[19];
            $current_genome->{file} = $current_genome->{ftp_dir};
            $current_genome->{file}=~s/.*\///;
            ($current_genome->{id}, $current_genome->{version}) = $current_genome->{accession}=~/(.*)\.(\d+)$/;
            $current_genome->{refseq_category} = $attribs[4];
            $current_genome->{tax_id} = $attribs[5];
            $current_genome->{assembly_level} = $attribs[11];

            if( $update_only == 1 ) {
                my $gn_solr_core = "GenomeFeatures_prod";
                if( ($self->_checkGenomeStatus( $current_genome, $gn_solr_core ))=~/(new|updated)/i ) {
                    push(@{$output},$current_genome);
                }
            }
            else {
                push(@{$output},$current_genome);
            }
            
            if ($count <= 10) {
                $summary .= $current_genome->{accession}.";".$current_genome->{version_status}.";".$current_genome->{id}.";".$current_genome->{ftp_dir}.";".$current_genome->{file}.";".$current_genome->{id}.";".$current_genome->{version}.";".$current_genome->{source}.";".$current_genome->{domain}."\n";
            }
        }
    }
    return({summary => $summary, ref_genomes => $output});
}

#################### End subs for accessing NCBI refseq genomes########################

sub _extract_ncbi_taxa {
    my $self=shift;
    my $args = shift;
    my $taxon_file_path=$self->{'data'}."/taxon_dump/";
    if(!-d $taxon_file_path || !-f $taxon_file_path."names.dmp"){
	mkdir($taxon_file_path);
	chdir($taxon_file_path);
	system("curl -o taxdump.tar.gz ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz");
	system("tar -zxf taxdump.tar.gz");
    }

    open(my $fh, "< ${taxon_file_path}nodes.dmp");
    my $taxon_objects={};
    while(<$fh>){
        chomp;
        my @temp=split(/\s*\|\s*/,$_,-1);

	#Bad, because the lineage needs to be formed from all taxa before ignoring any
	#The extract case is OK if you're testing a whole branch
	next if defined($args->{extract}) && !exists($args->{extract}{$temp[1]});
	#next if defined($args->{ignore}) && exists($args->{ignore}{$temp[0]});

        my $object = {'taxonomy_id'=>$temp[0]+0,
                      'parent_taxon_id'=>$temp[1]+0,
                      'rank'=>$temp[2],
                      'embl_code'=>$temp[3],
                      'division_id'=>$temp[4]+0,
                      'inherited_div_flag'=>$temp[5]+0,
                      'genetic_code'=>$temp[6]+0,
                      'inherited_GC_flag'=>$temp[7]+0,
                      'mitochondrial_genetic_code'=>$temp[8]+0,
                      'inherited_MGC_flag'=>$temp[9]+0,
                      'GenBank_hidden_flag'=>$temp[10]+0,
                      'hidden_substree_root_flag'=>$temp[11],
                      'comments'=>$temp[12],
                      'domain'=>"Unknown",
                      'scientific_name'=>"",
                      'scientific_lineage'=>"",
                      'aliases'=>[]};

        $taxon_objects->{$temp[0]}=$object;
    }
    close($fh);

    open(my $fh, "< ${taxon_file_path}names.dmp");
    my %Duplicate_Names=();
    while(<$fh>){
	chomp;
	my @temp=split(/\s*\|\s*/,$_,-1);
	if(exists($taxon_objects->{$temp[0]})){
	    if($temp[3] eq "scientific name"){
		$taxon_objects->{$temp[0]}{"scientific_name"}=$temp[1];
		$taxon_objects->{$temp[0]}{"unique_variant"}=$temp[2];
		$Duplicate_Names{$temp[1]}{$temp[0]}=1;
	    }else{
		push(@{$taxon_objects->{$temp[0]}{"aliases"}},$temp[1]);
	    }
	}
    }
    close($fh);

    #Iterate through to make lineage, need to determine "level" of each object so to sort properly before loading
    my %taxon_level=();
    foreach my $obj ( map { $taxon_objects->{$_} } sort { $a <=> $b } keys %$taxon_objects ){
	$obj->{"scientific_lineage"} = _make_lineage($obj->{"taxonomy_id"},$taxon_objects);

	#Determine Domain
	foreach my $domain ("Eukaryota","Bacteria","Viruses","Archaea"){
	    if($obj->{"scientific_lineage"} =~ /${domain}/){
		$obj->{"domain"}=$domain;
		last;
	    }
	}

	#Determine Kingdom
	foreach my $kingdom ("Fungi","Viridiplantae","Metazoa"){
	    if($obj->{"domain"} eq "Eukaryota" && $obj->{"scientific_lineage"} =~ /${kingdom}/){
		$obj->{"kingdom"}=$kingdom;
		last;
	    }
	}
	
	my $level = scalar( split(/;\s/,$obj->{"scientific_lineage"}) );
	$taxon_level{$level}{$obj->{"taxonomy_id"}}=1;
    }

    my $taxon_objs=[];
    foreach my $level ( sort { $a <=> $b } keys %taxon_level ){
	foreach my $obj ( map { $taxon_objects->{$_} } sort { $a <=> $b } keys %{$taxon_level{$level}} ){
	    delete $obj->{"parent_taxon_id"} if $obj->{"taxonomy_id"} == 1;
	    push(@$taxon_objs,$obj);
	}
    }

    foreach my $obj (@$taxon_objs){
	#Here we checked whether, in the instance of a clash, a taxon did not have a unique variant
	#We find that in the few cases this happens (~50), only one member of the clash didn't have unique variant
	#if(scalar(keys %{$Duplicate_Names{$obj->{'scientific_name'}}})>1 && $obj->{'unique_variant'} =~ /^\s*$/){
	    #print Dumper($obj),"\n";
	    #print $obj->{'scientific_name'},"\n";
	#}

	#If a scientific name belongs to more than one taxon, and if the unique variant is available
	if(scalar(keys %{$Duplicate_Names{$obj->{'scientific_name'}}})>1 && $obj->{'unique_variant'} !~ /^\s*$/){
	    $obj->{'scientific_name'}=$obj->{'unique_variant'};
	}
	delete($obj->{'unique_variant'});
    }
    return $taxon_objs;
}

sub _make_lineage {
    my ($taxon_id,$taxon_objects)=@_;
    return "" if $taxon_id == 1;
    my @lineages=();
    if(exists($taxon_objects->{$taxon_id}) && exists($taxon_objects->{$taxon_id}{"parent_taxon_id"})){
	my $parent_taxon_id=$taxon_objects->{$taxon_id}{"parent_taxon_id"};
	while($parent_taxon_id > 1){
	    if(exists($taxon_objects->{$parent_taxon_id}{"scientific_name"}) && $taxon_objects->{$parent_taxon_id}{"scientific_name"} ne ""){
		unshift(@lineages,$taxon_objects->{$parent_taxon_id}{"scientific_name"});
	    }
	    if(exists($taxon_objects->{$parent_taxon_id}{"parent_taxon_id"})){
		$parent_taxon_id=$taxon_objects->{$parent_taxon_id}{"parent_taxon_id"};
	    }else{
		$parent_taxon_id = 0;
	    }
	}
    }
    return join("; ",@lineages);
}

sub _check_taxon {
    my $self=shift;
    my ($new_taxon,$current_taxon)=@_;

    my @Mismatches=();
    my @Fields_to_Check = ('parent_taxon_ref','rank','domain','scientific_name','scientific_lineage');
    foreach my $field (@Fields_to_Check){
	if($field eq 'parent_taxon_ref'){
	    my $parent_taxon = undef;
	    $parent_taxon = $current_taxon->{'parent_taxon_ref'} if exists $current_taxon->{'parent_taxon_ref'};
	    if(defined($parent_taxon)){
		if(!defined($new_taxon->{'parent_taxon_id'})){
		    push(@Mismatches,"Taxon ".$new_taxon->{'taxonomy_id'}." does not contain parent taxon, but current taxon does");
		}else{
		    $parent_taxon = $self->{_wsclient}->get_objects2({objects=>[{"ref" => $parent_taxon}],ignoreErrors=>1})->{data};
		    if(scalar(@$parent_taxon)){
			$parent_taxon=$parent_taxon->[0]{data};
		    }else{
			push(@Mismatches,"Taxon ".$new_taxon->{'taxonomy_id'}." and current taxon contain parent taxon, but cannot retrieve current parent taxon");
		    }
		    if($parent_taxon->{'taxonomy_id'} != $new_taxon->{'parent_taxon_id'}){
			push(@Mismatches,"Taxon ".$new_taxon->{'taxonomy_id'}." parent taxon id does not match current parent taxon id");
		    }
		}
	    }elsif(defined($new_taxon->{'parent_taxon_id'})){
		push(@Mismatches,"Taxon ".$new_taxon->{'taxonomy_id'}." does contains parent taxon, but current taxon does not");
	    }
	}else{
	    if($current_taxon->{$field} ne $new_taxon->{$field}){
		push(@Mismatches,"Taxon ".$new_taxon->{'taxonomy_id'}." field $field (".$new_taxon->{$field}.") does not match current value ".$current_taxon->{$field});
	    }
	}
    }
    return \@Mismatches;
}

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    $self->{_workspace_map} = {
        ensembl => "Ensembl_Genomes",
        phytozome => "Phytozome_Genomes",
        refseq => "ReferenceDataManager"
    };

    #SOLR specific parameters
    if (! $self->{_SOLR_URL}) {
        $self->{_SOLR_URL} = "http://kbase.us/internal/solr-ci/search";
    }
    $self->{_SOLR_POST_URL} = $self->{_SOLR_URL};
    $self->{_SOLR_PING_URL} = "$self->{_SOLR_URL}/select";
    $self->{_AUTOCOMMIT} = 0;
    $self->{_CT_XML} = { Content_Type => 'text/xml; charset=utf-8' };
    $self->{_CT_JSON} = { Content_Type => 'text/json'};

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 list_reference_genomes

  $output = $obj->list_reference_genomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.ListReferenceGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.ReferenceGenomeData
ListReferenceGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	updated_only has a value which is a ReferenceDataManager.bool
	domain has a value which is a string
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
bool is an int
ReferenceGenomeData is a reference to a hash where the following keys are defined:
	accession has a value which is a string
	version_status has a value which is a string
	asm_name has a value which is a string
	ftp_dir has a value which is a string
	file has a value which is a string
	id has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
	refseq_category has a value which is a string
	tax_id has a value which is a string
	assembly_level has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.ListReferenceGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.ReferenceGenomeData
ListReferenceGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	updated_only has a value which is a ReferenceDataManager.bool
	domain has a value which is a string
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
bool is an int
ReferenceGenomeData is a reference to a hash where the following keys are defined:
	accession has a value which is a string
	version_status has a value which is a string
	asm_name has a value which is a string
	ftp_dir has a value which is a string
	file has a value which is a string
	id has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
	refseq_category has a value which is a string
	tax_id has a value which is a string
	assembly_level has a value which is a string


=end text



=item Description

Lists genomes present in selected reference databases (ensembl, phytozome, refseq)

=back

=cut

sub list_reference_genomes
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_reference_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_reference_genomes');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN list_reference_genomes
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        refseq => 1,
        phytozome => 0,
        ensembl => 0, 
        domain => "bacteria",
        update_only => 0,
        create_report => 0,
        workspace_name => undef
    });

    my $summary = "";
    $output = [];

    my $gn_domain = $params->{domain};    
    my $gn_source = "refseq";
    if($params->{refseq} == 1) {
        $gn_source = "refseq";
    }
    elsif($params->{phytozome} == 1) {
        $gn_source = "phytozome";
        $gn_domain = undef;    
    }
    elsif($params->{ensembl} == 1) {
        $gn_source = "ensembl";
        $gn_domain = undef;    
    }
    
    print $gn_source . "---" . $gn_domain . "\n";
    
    my $list_items = $self->_list_ncbi_refgenomes($gn_source, $gn_domain, $params->{update_only});
    if(defined($list_items)) {
    $output = $list_items->{ref_genomes};
    $summary = $list_items->{summary};

    $summary .= "\nThere are a total of " . @{$output} . " " . $gn_domain . " Reference genomes in " . $gn_source .".\n";
    print $summary . "\n";     

    if ($params->{create_report}) {
        $self->util_create_report({
            message => $summary,
            workspace => $params->{workspace_name}
        });  
        $output = [$params->{workspace_name}."/list_reference_genomes"];
    }
    }    
    #END list_reference_genomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_reference_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_reference_genomes');
    }
    return($output);
}




=head2 list_loaded_genomes

  $output = $obj->list_loaded_genomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.ListLoadedGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceGenomeData
ListLoadedGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	genome_ver has a value which is an int
	create_report has a value which is a ReferenceDataManager.bool
bool is an int
LoadedReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
	type has a value which is a string
	save_date has a value which is a string
	contig_count has a value which is an int
	feature_count has a value which is an int
	size_bytes has a value which is an int
	ftp_url has a value which is a string
	gc has a value which is a float

</pre>

=end html

=begin text

$params is a ReferenceDataManager.ListLoadedGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceGenomeData
ListLoadedGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	genome_ver has a value which is an int
	create_report has a value which is a ReferenceDataManager.bool
bool is an int
LoadedReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
	type has a value which is a string
	save_date has a value which is a string
	contig_count has a value which is an int
	feature_count has a value which is an int
	size_bytes has a value which is an int
	ftp_url has a value which is a string
	gc has a value which is a float


=end text



=item Description

Lists genomes loaded into KBase from selected reference sources (ensembl, phytozome, refseq)

=back

=cut

sub list_loaded_genomes
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_loaded_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_loaded_genomes');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN list_loaded_genomes
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        ensembl => 0,
        phytozome => 0,
        refseq => 1,
        create_report => 0,
        genome_ver => 1,
        workspace_name => undef
    });
    my $msg = "";
    my $output = [];
    my $batch_count = 1000;
    my $obj_type = "KBaseGenomes.Genome-";
    my $sources = ["phytozome","refseq","ensembl"];
    my $wsname;
    
    for (my $i=0; $i < @{$sources}; $i++) {
        if ($params->{$sources->[$i]} == 1) {
            my $wsinfo;
            my $wsoutput;
            
            $wsname = $self->util_workspace_names($sources->[$i]);
            if(defined($self->util_ws_client())){
                $wsinfo = $self->util_ws_client()->get_workspace_info({
                    workspace => $wsname
                });
            }
            my $maxid = $wsinfo->[4];
            my $pages = ceil($maxid/$batch_count);
            #print "\nMax genome object id=$maxid\n";

            for (my $m = 0; $m < $pages; $m++) {
                eval {
                    $wsoutput = $self->util_ws_client()->list_objects({
                          workspaces => [$wsname],
                          minObjectID => $batch_count * $m + 1,
                          type => $obj_type,
                          maxObjectID => $batch_count * ( $m + 1),
                          includeMetadata => 1
                      });
                 };
                 if($@) {
                        print "Cannot list objects!\n";
                        print "ERROR:" . $@;#->{message}."\n";
                        if(ref($@) eq 'HASH' && defined($@->{status_line})) {
                            print "ERROR:" . $@->{status_line}."\n";
                        }
                 }
                 else {
                    #print "Genome object count=" . @{$wsoutput}. "\n";
                    my $ws_objinfo;
                    my $obj_src;
                    my $curr_gn_info;
                    if( @{$wsoutput} > 0 ) {
                        for (my $j=0; $j < @{$wsoutput}; $j++) {
                            $ws_objinfo = $wsoutput->[$j];
                            $obj_src = $ws_objinfo->[10]->{Source};
                            if( $obj_src && $i == 0 ) {#phytozome
                                if( $obj_src =~ /phytozome*/i) {#check the source to include phytozome genomes only
                                    $curr_gn_info = $self->_getGenomeInfo($ws_objinfo); 
                                    push @{$output}, $curr_gn_info; 
                            
                                    if (@{$output} < 10  && @{$output} > 0) {
                                        $msg .= $self->_genomeInfoString($curr_gn_info);
                                    }
                                }
                            }
                            elsif( $obj_src && $i == 1 ) {#refseq genomes (exclude 'plant')
                                if( $obj_src =~ /refseq*/i && $ws_objinfo->[4] == $params->{genome_ver}) {#check the source to exclude phytozome genomes
                                    $curr_gn_info = $self->_getGenomeInfo($ws_objinfo); 
                                    push @{$output}, $curr_gn_info;
                            
                                    if (@{$output} < 10  && @{$output} > 0) {
                                        $msg .= $self->_genomeInfoString($curr_gn_info);
                                    }
                                }
                            }
                            elsif( $obj_src && $i == 2 ) {#ensembl genomes #TODO
                                if( $obj_src !~ /phytozome*/ && $obj_src !~ /refseq*/ ) {
                                    if( $ws_objinfo->[10]->{Domain} !~ /Plant/i && $ws_objinfo->[10]->{Domain} !~ /Bacteria/i ) {
                                        $curr_gn_info = $self->_getGenomeInfo($ws_objinfo); 
                                        push @{$output}, $curr_gn_info; 
                            
                                        if (@{$output} < 10  && @{$output} > 0) {
                                           $msg .= $self->_genomeInfoString($curr_gn_info);
                                        }
                                    }       
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    $msg .= "\nThere are a total of " . @{$output} . " Reference genomes loaded in KBase.\n";
    print $msg . "\n";     

    if ($params->{create_report}) {
        $self->util_create_report({
                message => $msg,
                workspace => $params->{workspace_name}
        });
        $output = [$params->{workspace_name}."/list_loaded_genomes"];
    }

    #END list_loaded_genomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_loaded_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_loaded_genomes');
    }
    return($output);
}




=head2 list_solr_genomes

  $output = $obj->list_solr_genomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.ListSolrDocsParams
$output is a reference to a list where each element is a ReferenceDataManager.solrdoc
ListSolrDocsParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	row_start has a value which is an int
	row_count has a value which is an int
	group_option has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
	domain has a value which is a string
	complete has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
bool is an int
solrdoc is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.ListSolrDocsParams
$output is a reference to a list where each element is a ReferenceDataManager.solrdoc
ListSolrDocsParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	row_start has a value which is an int
	row_count has a value which is an int
	group_option has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
	domain has a value which is a string
	complete has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
bool is an int
solrdoc is a reference to a hash where the key is a string and the value is a string


=end text



=item Description

Lists genomes indexed in SOLR

=back

=cut

sub list_solr_genomes
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_solr_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_solr_genomes');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN list_solr_genomes
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        solr_core => "Genomes_prod",
        row_start => 0,
        row_count => 0,
        group_option => "",
        create_report => 0,
        domain => "Bacteria",
        complete => undef,
        workspace_name => undef
    });

    $output = [];
    my $msg = "Found ";
    my $solrout;
    my $fields = "genome_id, workspace_name, scientific_name, genetic_code, domain";
    my $grpOpt = $params->{group_option};
    eval {
        $solrout = $self->_listGenomesInSolr($params->{solr_core}, $fields, $params->{row_start}, $params->{row_count}, $params->{group_option}, $params->{domain}, $params->{complete});
    };
    if($@) {
        print "Cannot list genomes in SOLR information!\n";
        print "ERROR:".$@;
        if(ref($@) eq 'HASH' && defined($@->{status_line})) {
            print $@->{status_line}."\n";
        }
    }
    else {
        if( $grpOpt eq "" ) {
            $output = $solrout->{response}->{response}->{docs};
            $msg .= $solrout->{response}->{response}->{numFound}." genome(s)";
        }
        else {
            my $grp = $solrout->{response}->{grouped}->{$grpOpt};
            $output = $grp->{groups};
            $msg .= $grp->{matches}." genome_feature(s) in " . $grp->{ngroups}." ". $grpOpt . " groups";
        }
        $msg .= " in SOLR.\n";
    }
    $msg = ($msg ne "") ? $msg : "Nothing found!";
    print $msg . "\n";     

    if ($params->{create_report}) {
        $self->util_create_report({
                message => $msg,
                workspace => $params->{workspace_name}
        });
        $output = [$params->{workspace_name}."/list_solr_genomes"];
    }

    #END list_solr_genomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_solr_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_solr_genomes');
    }
    return($output);
}




=head2 index_genomes_in_solr

  $output = $obj->index_genomes_in_solr($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.IndexGenomesInSolrParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrGenomeFeatureData
IndexGenomesInSolrParams is a reference to a hash where the following keys are defined:
	genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
	solr_core has a value which is a string
	workspace_name has a value which is a string
	start_offset has a value which is an int
	genome_ver has a value which is an int
	create_report has a value which is a ReferenceDataManager.bool
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
bool is an int
SolrGenomeFeatureData is a reference to a hash where the following keys are defined:
	genome_feature_id has a value which is a string
	genome_id has a value which is a string
	feature_id has a value which is a string
	ws_ref has a value which is a string
	feature_type has a value which is a string
	aliases has a value which is a string
	scientific_name has a value which is a string
	domain has a value which is a string
	functions has a value which is a string
	genome_source has a value which is a string
	go_ontology_description has a value which is a string
	go_ontology_domain has a value which is a string
	gene_name has a value which is a string
	object_name has a value which is a string
	location_contig has a value which is a string
	location_strand has a value which is a string
	taxonomy has a value which is a string
	workspace_name has a value which is a string
	genetic_code has a value which is a string
	md5 has a value which is a string
	tax_id has a value which is a string
	assembly_ref has a value which is a string
	taxonomy_ref has a value which is a string
	ontology_namespaces has a value which is a string
	ontology_ids has a value which is a string
	ontology_names has a value which is a string
	ontology_lineages has a value which is a string
	dna_sequence_length has a value which is an int
	genome_dna_size has a value which is an int
	location_begin has a value which is an int
	location_end has a value which is an int
	num_cds has a value which is an int
	num_contigs has a value which is an int
	protein_translation_length has a value which is an int
	gc_content has a value which is a float
	complete has a value which is a ReferenceDataManager.bool
	refseq_category has a value which is a string
	save_date has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.IndexGenomesInSolrParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrGenomeFeatureData
IndexGenomesInSolrParams is a reference to a hash where the following keys are defined:
	genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
	solr_core has a value which is a string
	workspace_name has a value which is a string
	start_offset has a value which is an int
	genome_ver has a value which is an int
	create_report has a value which is a ReferenceDataManager.bool
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
bool is an int
SolrGenomeFeatureData is a reference to a hash where the following keys are defined:
	genome_feature_id has a value which is a string
	genome_id has a value which is a string
	feature_id has a value which is a string
	ws_ref has a value which is a string
	feature_type has a value which is a string
	aliases has a value which is a string
	scientific_name has a value which is a string
	domain has a value which is a string
	functions has a value which is a string
	genome_source has a value which is a string
	go_ontology_description has a value which is a string
	go_ontology_domain has a value which is a string
	gene_name has a value which is a string
	object_name has a value which is a string
	location_contig has a value which is a string
	location_strand has a value which is a string
	taxonomy has a value which is a string
	workspace_name has a value which is a string
	genetic_code has a value which is a string
	md5 has a value which is a string
	tax_id has a value which is a string
	assembly_ref has a value which is a string
	taxonomy_ref has a value which is a string
	ontology_namespaces has a value which is a string
	ontology_ids has a value which is a string
	ontology_names has a value which is a string
	ontology_lineages has a value which is a string
	dna_sequence_length has a value which is an int
	genome_dna_size has a value which is an int
	location_begin has a value which is an int
	location_end has a value which is an int
	num_cds has a value which is an int
	num_contigs has a value which is an int
	protein_translation_length has a value which is an int
	gc_content has a value which is a float
	complete has a value which is a ReferenceDataManager.bool
	refseq_category has a value which is a string
	save_date has a value which is a string


=end text



=item Description

Index specified genomes in SOLR from KBase workspace

=back

=cut

sub index_genomes_in_solr
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to index_genomes_in_solr:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'index_genomes_in_solr');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN index_genomes_in_solr
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        genomes => undef,
        solr_core => "GenomeFeatures_prod",
        workspace_name => undef,
        create_report => 0,
        genome_ver => 1,
        start_offset => 0
    });

    my $msg = "";
    my $genomes;

    my $objVer = $params->{genome_ver};
    if (!defined($params->{genomes})) {
        $genomes = $self->list_loaded_genomes({refseq=>1,genome_ver=>$objVer});
    } else {
        $genomes = $params->{genomes};
    }

    my $solrCore = $params->{solr_core};
    @{$genomes} = @{$genomes}[$params->{start_offset}..@{$genomes} - 1];
    print "\nTotal genomes to be indexed: ". @{$genomes} . " to SOLR ". $solrCore ."\n";
    $output = $self->_indexGenomeFeatureData($solrCore, $genomes);
    my $gnft_count = $output->{count};
    $output = $output->{genome_features};
    if (@{$output} > 0) {
        my $curr = @{$output}-1;
        $msg .= Data::Dumper->Dump([$output->[$curr]])."\n";
    }
    
    $msg .= "Indexed ". $gnft_count. " genome_feature(s)!\n";
    print $msg . "\n";
    
    if ($params->{create_report}) {
        $self->util_create_report({
            message => $msg,
            workspace => $params->{workspace_name}
        });  
        $output = [$params->{workspace_name}."/index_genomes_in_solr"];
    }    
    #END index_genomes_in_solr
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to index_genomes_in_solr:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'index_genomes_in_solr');
    }
    return($output);
}




=head2 list_loaded_taxa

  $output = $obj->list_loaded_taxa($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.ListLoadedTaxaParams
$output is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceTaxonData
ListLoadedTaxaParams is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
bool is an int
LoadedReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxon has a value which is a ReferenceDataManager.KBaseReferenceTaxonData
	ws_ref has a value which is a string
KBaseReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.ListLoadedTaxaParams
$output is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceTaxonData
ListLoadedTaxaParams is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
bool is an int
LoadedReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxon has a value which is a ReferenceDataManager.KBaseReferenceTaxonData
	ws_ref has a value which is a string
KBaseReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string


=end text



=item Description

Lists taxa loaded into KBase for a given workspace

=back

=cut

sub list_loaded_taxa
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_loaded_taxa:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_loaded_taxa');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN list_loaded_taxa
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        create_report => 0,
        workspace_name => "ReferenceTaxons"
    });
    my $msg = "";
    my $output = [];

    my $wsname = $params->{workspace_name};
    my $wsinfo;
    my $wsoutput;
    my $taxonout;
    my ($minid,$maxid)=(0,0);
    $minid = $params->{minid} if exists($params->{minid});
    if(!exists($params->{maxid})){
        $wsinfo = $self->util_ws_client()->get_workspace_info({workspace => $wsname});
	$maxid = $wsinfo->[4];
    }else{
	$maxid=$params->{maxid};
    }

    return [] if $maxid < $minid;

    my $batch_count = 5000;
    $batch_count=$params->{batch} if exists($params->{batch});
    my $pages = ceil($maxid/$batch_count);
    my $first_page = floor($minid/$batch_count);
    print "I: Starting at Page $first_page\n";
    print "I: Fetching ".($maxid-($minid-1))." taxon objects.\n";
    print "I: Paging through $pages of $batch_count objects\n"; 
    for (my $m = $first_page; $m <= $pages; $m++) {
        my ($minObjID,$maxObjID)=(( $batch_count * $m ) + 1,$batch_count * ( $m + 1));

        #set limit based on whats been done before
        $minObjID=$minid if $minid >$minObjID;

        last if $minObjID > $maxid;

        print ("I: Batch ". $m . "x$batch_count on " . scalar(localtime)."\n");
        print ("I: minObjectID: $minObjID\n");
        print ("I: maxObjectID: $maxObjID\n");

	$wsoutput = [];
        my $try_count=5;
        while(scalar(@$wsoutput)==0 && $try_count != 0){
            $try_count--;
            eval {
                $wsoutput = $self->util_ws_client()->list_objects({workspaces => [$wsname],
                                                                   type => "KBaseGenomeAnnotations.Taxon-1.0",
                                                                   minObjectID => $minObjID,
                                                                   maxObjectID => $maxObjID});
            };
	    if ($@) {
		print "ERROR on iteration $try_count for Batch $batch_count: Cannot list objects: $_ at ".scalar(localtime)."\n";
		print "Exception message: " . $@->{"message"} . "\n";
		print "JSONRPC code: " . $@->{"code"} . "\n";
		print "Method: " . $@->{"method_name"} . "\n";
		print "Client-side exception:\n";
		print $@;
		print "Server-side exception:\n";
		print $@->{"data"};
	    }
            sleep(3) if scalar(@$wsoutput)==0;
        }
        if(exists($params->{ignore})){
            $wsoutput = [ grep { !exists($params->{ignore}{$_->[0]}) } @$wsoutput ];
        }
        next if scalar(@$wsoutput)==0;
	
        my $wstaxonrefs = [];
        for (my $j=0; $j < @{$wsoutput}; $j++) {
            push(@{$wstaxonrefs},{"ref" => $wsoutput->[$j]->[6]."/".$wsoutput->[$j]->[0]."/".$wsoutput->[$j]->[4]});
        }

        $taxonout = [];
        my $try_count=5;
        while(scalar(@$taxonout)==0 && $try_count != 0){
            $try_count--;
            eval {
                print "\nStart to fetch the objects at the batch size of: " . @{$wstaxonrefs} . " on " . scalar localtime;
                $taxonout = $self->util_ws_client()->get_objects2({objects => $wstaxonrefs})->{data};
                print "\nDone getting the objects at the batch size of: " . @{$taxonout} . " on " . scalar localtime . "\n\n";
	    };
	    if($@) {
		print "ERROR on iteration $try_count for Batch $batch_count: Cannot get objects: $_ at ".scalar(localtime)."\n";
		print "Exception message: " . $@->{"message"} . "\n";
		print "JSONRPC code: " . $@->{"code"} . "\n";
		print "Method: " . $@->{"method_name"} . "\n";
		print "Client-side exception:\n";
		print $@;
		print "Server-side exception:\n";
		print $@->{"data"};
	    }
	    sleep(3) if scalar(@$taxonout)==0;
	}

        my $solr_taxa = [];
        for (my $i=0; $i < @{$taxonout}; $i++) {
            my $taxonData = $taxonout->[$i]->{data}; #an UnspecifiedObject
	    my $curr_taxon = {taxon => $taxonData, ws_ref => $wstaxonrefs->[$i]->{ref}};

            push(@{$output}, $curr_taxon);
	    push(@{$solr_taxa}, $curr_taxon);

            if (@{$output} < 10  && @{$output} > 0) {
                my $curr = @{$output}-1;
                $msg .= Data::Dumper->Dump([$output->[$curr]])."\n";
            }
	}

        if(exists($params->{batch}) && scalar(@$output) >= $params->{batch}){
            last;
        }
    }
    #END list_loaded_taxa
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_loaded_taxa:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_loaded_taxa');
    }
    return($output);
}




=head2 list_solr_taxa

  $output = $obj->list_solr_taxa($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.ListSolrDocsParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrTaxonData
ListSolrDocsParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	row_start has a value which is an int
	row_count has a value which is an int
	group_option has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
	domain has a value which is a string
	complete has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
bool is an int
SolrTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.ListSolrDocsParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrTaxonData
ListSolrDocsParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	row_start has a value which is an int
	row_count has a value which is an int
	group_option has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
	domain has a value which is a string
	complete has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
bool is an int
SolrTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string


=end text



=item Description

Lists taxa indexed in SOLR

=back

=cut

sub list_solr_taxa
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_solr_taxa:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_solr_taxa');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN list_solr_taxa
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        solr_core => "taxonomy_prod",
        row_start => 0,
        row_count => 10,
        group_option => "",
        workspace_name => undef,
        create_report => 0
    });

    my $msg = "Found ";
    $output = [];
    my $solrout;
    my $solrCore = $params->{solr_core};
    my $fields = "*";
    my $startRow = $params->{row_start};
    my $topRows = $params->{row_count};
    my $grpOpt = $params->{group_option}; #"taxonomy_id";    
    eval {
        $solrout = $self->_listTaxaInSolr($solrCore, $fields, $startRow, $topRows, $grpOpt);
    };
    if($@) {
        print "Cannot list taxa in SOLR information!\n";
        print "ERROR:".$@;
        if(ref($@) eq 'HASH' && defined($@->{status_line})) {
            print $@->{status_line}."\n";
        }
    }
    else {
        if( $grpOpt eq "" ) {
            $output = $solrout->{response}->{response}->{docs};
            $msg .= $solrout->{response}->{response}->{numFound}." taxa";
        }
        else {
            my $grp = $solrout->{response}->{grouped}->{$grpOpt};
            $output = $grp->{groups};
            $msg .= $grp->{matches}." taxa in " . $grp->{ngroups}." ". $grpOpt . " groups";
        }
        $msg .= " in SOLR.\n";
        $msg .=  "Taxon SOLR record example:\n";
        my $curr = @{$output}-1;
        $msg .= Data::Dumper->Dump([$output->[$curr]])."\n";
    }

    $msg = ($msg ne "") ? $msg : "Nothing found!";
    print $msg . "\n";     

    if ($params->{create_report}) {
        $self->util_create_report({
                message => $msg,
                workspace => $params->{workspace_name}
        });
        $output = [$params->{workspace_name}."/list_solr_taxa"];
    }
    #END list_solr_taxa
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_solr_taxa:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_solr_taxa');
    }
    return($output);
}




=head2 load_taxa

  $output = $obj->load_taxa($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.LoadTaxonsParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrTaxonData
LoadTaxonsParams is a reference to a hash where the following keys are defined:
	data has a value which is a string
	taxons has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceTaxonData
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
KBaseReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string
bool is an int
SolrTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.LoadTaxonsParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrTaxonData
LoadTaxonsParams is a reference to a hash where the following keys are defined:
	data has a value which is a string
	taxons has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceTaxonData
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
KBaseReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string
bool is an int
SolrTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string


=end text



=item Description

Loads specified taxa into KBase workspace and indexes in SOLR on demand

=back

=cut

sub load_taxa
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to load_taxa:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'load_taxa');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN load_taxa
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        data => undef,
        taxons => [],
        index_in_solr => 0,
        create_report => 0,
        workspace_name => undef
    });

    my $ncbi_taxon_objs = $self->_extract_ncbi_taxons();

    my $Taxon_WS = "ReferenceTaxons";
    my $loaded_taxon_objs = $self->list_loaded_taxa({workspace_name=>$Taxon_WS});

    my $taxon_provenance = [{"script"=>$0, "script_ver"=>"0.1", "description"=>"Taxon generated from NCBI taxonomy names and nodes files downloaded on 10/20/2016."}];
    foreach my $obj (@$ncbi_taxon_objs){
        $self->_check_taxon($obj,$loaded_taxon_objs);

        $obj->{'parent_taxon_ref'}=$Taxon_WS."/".$obj->{'parent_taxon_id'}."_taxon";
        delete $obj->{'parent_taxon_ref'} if $obj->{'taxonomy_id'}==1;
        delete $obj->{'parent_taxon_id'};

        my $taxon_name = $obj->{"taxonomy_id"}."_taxon";
        print "Loading $taxon_name\n";
        $obj->{"taxonomy_id"}+=0;
        $self->{_wsclient}->save_objects({"workspace"=>$Taxon_WS,"objects"=>[ {"type"=>"KBaseGenomeAnnotations.Taxon",
                                                                               "data"=>$obj,
                                                                               "name"=>$taxon_name,
                                                                               "provenance"=>$taxon_provenance}] });
        push(@$output, $self->_getTaxon($obj, $Taxon_WS."/".$taxon_name));
    }
    #END load_taxa
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to load_taxa:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'load_taxa');
    }
    return($output);
}




=head2 index_taxa_in_solr

  $output = $obj->index_taxa_in_solr($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.IndexTaxaInSolrParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrTaxonData
IndexTaxaInSolrParams is a reference to a hash where the following keys are defined:
	taxa has a value which is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceTaxonData
	solr_core has a value which is a string
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
	start_offset has a value which is an int
LoadedReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxon has a value which is a ReferenceDataManager.KBaseReferenceTaxonData
	ws_ref has a value which is a string
KBaseReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string
bool is an int
SolrTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.IndexTaxaInSolrParams
$output is a reference to a list where each element is a ReferenceDataManager.SolrTaxonData
IndexTaxaInSolrParams is a reference to a hash where the following keys are defined:
	taxa has a value which is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceTaxonData
	solr_core has a value which is a string
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
	start_offset has a value which is an int
LoadedReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxon has a value which is a ReferenceDataManager.KBaseReferenceTaxonData
	ws_ref has a value which is a string
KBaseReferenceTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string
bool is an int
SolrTaxonData is a reference to a hash where the following keys are defined:
	taxonomy_id has a value which is an int
	scientific_name has a value which is a string
	scientific_lineage has a value which is a string
	rank has a value which is a string
	kingdom has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	parent_taxon_ref has a value which is a string
	embl_code has a value which is a string
	inherited_div_flag has a value which is an int
	inherited_GC_flag has a value which is an int
	mitochondrial_genetic_code has a value which is an int
	inherited_MGC_flag has a value which is an int
	GenBank_hidden_flag has a value which is an int
	hidden_subtree_flag has a value which is an int
	division_id has a value which is an int
	comments has a value which is a string


=end text



=item Description

Index specified taxa in SOLR from KBase workspace

=back

=cut

sub index_taxa_in_solr
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to index_taxa_in_solr:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'index_taxa_in_solr');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN index_taxa_in_solr
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        taxa => undef,
        create_report => 0,
        workspace_name => undef,
        start_offset => 0,
        solr_core => "taxonomy_prod" 
    });
    
    my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service_version=ver parameter when master is done.
    #my $solrer = new KBSolrUtil::KBSolrUtilClient($ENV{ SDK_CALLBACK_URL });

    my $taxa;
    if (!defined($params->{taxa})) {
        $taxa = $self->list_loaded_taxa({
                workspace_name => "ReferenceTaxons",
                minid => $params->{start_offset},
                create_report => 0
        });
    } else {
        $taxa = $params->{taxa};
    }
    my $solrCore = $params->{solr_core};
    
    my $msg = "";
    $output = [];
    my $solrBatch = [];
    my $solrBatchCount = 10000;
    #print "\nTotal taxa to be indexed: ". @{$taxa} . " to $solrCore.\n";

    for (my $i = 0; $i < @{$taxa}; $i++) {
        my $taxonData = $taxa->[$i]->{taxon};#an UnspecifiedObject
        my $wref = $taxa->[$i]->{ws_ref};
        my $current_taxon = $self->_getTaxon($taxonData, $wref);

        push(@{$solrBatch}, $current_taxon);
        if(@{$solrBatch} >= $solrBatchCount) {
            eval {
                $solrer->index_in_solr({solr_core=>$solrCore, doc_data=>$solrBatch});
            };
            if($@) {
                print "Failed to index the taxa!\n";
                if( defined ($@)){
                    print "ERROR:".Dumper($@);
                }
                if(ref($@) eq 'HASH' && defined($@->{status_line})) {
                    print $@->{status_line}."\n";
                }
            }
            else {
                print "\nIndexed ". @{$solrBatch} . " taxa.\n";
                push(@{$output}, @{$solrBatch});
                $solrBatch = [];
            }
        }

        #push(@{$output}, $current_taxon);
        if (@{$output} < 10 && @{$output} > 0){
            my $curr = @{$output}-1;
            $msg .= Data::Dumper->Dump([$output->[$curr]])."\n";
        }
    }
    if(@{$solrBatch} > 0) {
            eval {
                $solrer->index_in_solr({solr_core=>$solrCore, doc_data=>$solrBatch});
            };
            if($@) {
                print "Failed to index the taxa!\n";
                if( defined ($@)){
                    print "ERROR:". Dumper($@);
                }
                if(ref($@) eq 'HASH' && defined($@->{status_line})) {
                    print $@->{status_line}."\n";
                }
            }
            else {
                push(@{$output}, @{$solrBatch});
                #print "\nIndexed ". @{$solrBatch} . " taxa.\n";
            }
    }
    $msg .= "Indexed ". scalar @{$output}. " taxa!\n";
    print $msg . "\n";

    if ($params->{create_report}) {
        $self->util_create_report({
            message => $msg,
            workspace => $params->{workspace_name}
        });
        $output = [$params->{workspace_name}."/index_taxa_in_solr"];
    }
    #END index_taxa_in_solr
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to index_taxa_in_solr:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'index_taxa_in_solr');
    }
    return($output);
}




=head2 load_genomes

  $output = $obj->load_genomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.LoadGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
LoadGenomesParams is a reference to a hash where the following keys are defined:
	data has a value which is a string
	genomes has a value which is a reference to a list where each element is a ReferenceDataManager.ReferenceGenomeData
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
ReferenceGenomeData is a reference to a hash where the following keys are defined:
	accession has a value which is a string
	version_status has a value which is a string
	asm_name has a value which is a string
	ftp_dir has a value which is a string
	file has a value which is a string
	id has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
	refseq_category has a value which is a string
	tax_id has a value which is a string
	assembly_level has a value which is a string
bool is an int
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.LoadGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
LoadGenomesParams is a reference to a hash where the following keys are defined:
	data has a value which is a string
	genomes has a value which is a reference to a list where each element is a ReferenceDataManager.ReferenceGenomeData
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
ReferenceGenomeData is a reference to a hash where the following keys are defined:
	accession has a value which is a string
	version_status has a value which is a string
	asm_name has a value which is a string
	ftp_dir has a value which is a string
	file has a value which is a string
	id has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
	refseq_category has a value which is a string
	tax_id has a value which is a string
	assembly_level has a value which is a string
bool is an int
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string


=end text



=item Description

Loads specified genomes into KBase workspace and indexes in SOLR on demand

=back

=cut

sub load_genomes
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to load_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'load_genomes');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN load_genomes
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        data => undef,
        genomes => [],
        index_in_solr => 0,
        workspace_name => undef
    });
#my $loader = new GenomeFileUtil::GenomeFileUtilClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev', 'async_version' => 'dev'));#should remove this service=ver parameter when master is done.
    my $loader = new GenomeFileUtil::GenomeFileUtilClient($ENV{ SDK_CALLBACK_URL });
    my $ncbigenomes;
    $output = [];
    my $msg = "";

    if (defined($params->{data})) {
        my $array = [split(/;/,$params->{data})];
        $ncbigenomes = [{
            accession => $array->[0],
            status => $array->[1],
            name => $array->[2],
            ftp_dir => $array->[3],
            file => $array->[4],
            id => $array->[5],
            version => $array->[6],
            source => $array->[7],
            domain => $array->[8]
        }];
    } else {
        $ncbigenomes = $params->{genomes};
    }

    for (my $i=0; $i < @{$ncbigenomes}; $i++) {
        my $ncbigenome = $ncbigenomes->[$i];
        #print "\n******************Genome#: $i ********************";
        my $wsname = "";
        if(defined( $ncbigenome->{workspace_name}))
        {
            $wsname = $ncbigenome->{workspace_name};
        }
        elsif(defined($ncbigenome->{source}))
        {
            $wsname = $self->util_workspace_names($ncbigenome->{source});
        }
        else
        {
            $wsname = "ReferenceDataManager";    
        }

        my $gn_type = "User upload";
        if( $ncbigenome->{refseq_category} eq "reference genome") {
           $gn_type = "Reference";
        }
        elsif($ncbigenome->{refseq_category} eq "representative genome") {
           $gn_type = "Representative";
        }
        
        #print "\nNow loading ".$ncbigenome->{id}." with loader url=".$ENV{ SDK_CALLBACK_URL }. " on " . scalar localtime . "\n";
        if ($ncbigenome->{source} eq "refseq" || $ncbigenome->{source} eq "") {
            my $genomeout;
            my $genutilout;
            my $gn_url = $ncbigenome->{ftp_dir}."/".$ncbigenome->{file}."_genomic.gbff.gz";
            my $asm_level = ($ncbigenome->{assembly_level}) ? $ncbigenome->{assembly_level} : "unknown"; 
            eval {
                $genutilout = $loader->genbank_to_genome({
		file => {
                    ftp_url => $gn_url
                },
                genome_name => $ncbigenome->{accession},
                workspace_name => $wsname,
                source => $ncbigenome->{source},
                taxon_wsname => "ReferenceTaxons",
                release => $ncbigenome->{version},
                generate_ids_if_needed => 1,
                type => $gn_type,
                metadata => { 
                    refid => $ncbigenome->{id},
                    accession => $ncbigenome->{accession},
                    refname => $ncbigenome->{accession},
                    url => $gn_url,
                    assembly_level => $asm_level,
                    version => $ncbigenome->{version}
                }
              });
            };
            if ($@) {
                print "**********Received an exception from calling genbank_to_genome to load $ncbigenome->{id}:\n";
                print "Exception message: " . $@->{"message"} . "\n";
                print "JSONRPC code: " . $@->{"code"} . "\n";
                print "Method: " . $@->{"method_name"} . "\n";
                print "Client-side exception:\n";
                print $@;
                print "\nServer-side exception:\n";
                print $@->{"data"};
            }
            else
            {
                $genomeout = {
                    "ref" => $genutilout->{genome_ref},
                    id => $ncbigenome->{id},
                    workspace_name => $wsname,
                    source_id => $ncbigenome->{id},
                    accession => $ncbigenome->{accession},
                    name => $ncbigenome->{id},
                    version => $ncbigenome->{version},
                    source => $ncbigenome->{source},
                    domain => $ncbigenome->{domain}
                };

                my $gn_solrCore = "GenomeFeatures_prod";
                if ($params->{index_in_solr} == 1) {
                    $self->index_genomes_in_solr({
                        solr_core => $gn_solrCore,             
                        genomes => [$genomeout]
                    });
                }
                push(@{$output},$genomeout);
                if (@{$output} < 10  && @{$output} > 0) {
                   $msg .= "Loaded genome: ".$genomeout->{id}." into workspace ".$genomeout->{workspace_name}.";\n";
                }
            }
            #print "**********************Genome loading process ends on " . scalar localtime . "************************\n";
        } elsif ($ncbigenome->{source} eq "phytozome") {
            #NEED SAM TO PUT CODE FOR HIS LOADER HERE
            my $genomeout = {
                "ref" => $wsname."/".$ncbigenome->{id},
                id => $ncbigenome->{id},
                workspace_name => $wsname,
                source_id => $ncbigenome->{id},
                accession => $ncbigenome->{accession},
                name => $ncbigenome->{name},
                ftp_dir => $ncbigenome->{ftp_dir},
                version => $ncbigenome->{version},
                source => $ncbigenome->{source},
                domain => $ncbigenome->{domain}
            };
            push(@{$output},$genomeout);
        }
    }
    $msg .= "\nLoaded a total of ". scalar @{$output}. " genomes!\n";
    print $msg . "\n";
    
    if ($params->{create_report}) {
        $self->util_create_report({
                message => $msg,
                workspace => $params->{workspace_name}
        });
        $output = [$params->{workspace_name}."/load_genomes"];
    }

    #END load_genomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to load_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'load_genomes');
    }
    return($output);
}




=head2 load_refgenomes

  $output = $obj->load_refgenomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.LoadRefGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
LoadRefGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	start_offset has a value which is an int
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
bool is an int
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.LoadRefGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
LoadRefGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	start_offset has a value which is an int
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
bool is an int
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string


=end text



=item Description

Loads Reference genomes into KBase workspace without indexing

=back

=cut

sub load_refgenomes
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to load_refgenomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'load_refgenomes');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN load_refgenomes
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        refseq=>1,
        phytozome=>0,
        ensembl=>0,
        start_offset=>0, 
        index_in_solr=>0,
        workspace_name=>undef
    });

    $output = [];
    my $ref_genomes = $self->list_reference_genomes({refseq=>$params->{refseq},phytozome=>$params->{phytozome},ensembl=>$params->{ensembl},update_only=>0});
    @{$ref_genomes} = @{$ref_genomes}[$params->{start_offset}..@{$ref_genomes}-1];
    $output = $self->load_genomes({genomes =>$ref_genomes, index_in_solr=>$params->{index_in_solr}}); 
    #END load_refgenomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to load_refgenomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'load_refgenomes');
    }
    return($output);
}




=head2 rast_genomes

  $output = $obj->rast_genomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.RASTGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
RASTGenomesParams is a reference to a hash where the following keys are defined:
	data has a value which is a string
	genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
bool is an int

</pre>

=end html

=begin text

$params is a ReferenceDataManager.RASTGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
RASTGenomesParams is a reference to a hash where the following keys are defined:
	data has a value which is a string
	genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
	index_in_solr has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	create_report has a value which is a ReferenceDataManager.bool
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string
bool is an int


=end text



=item Description

RASTs specified genomes into KBase workspace and indexes in SOLR on demand

=back

=cut

sub rast_genomes
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to rast_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'rast_genomes');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN rast_genomes
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        data => undef,
        genomes => [], 
        index_in_solr => 0,
        create_report => 0,
        workspace_name => undef
    });
    my $raster = new RAST_SDK::RAST_SDKClient($ENV{ SDK_CALLBACK_URL }, ('service_version'=>'dev','async_version'=>'dev'));
    #my $raster = new RAST_SDK::RAST_SDKClient($ENV{ SDK_CALLBACK_URL });
    my $srcgenomes;
    my $rastgenomes;
    $output = [];
    my $msg = "";

    if (defined($params->{data})) {
        my $array = [split(/;/,$params->{data})];
        $srcgenomes = [{
            genome_id => $array->[0],
            scientific_name => $array->[1],
            domain => $array->[2],
            genetic_code => $array->[3]
        }];
    } elsif (defined($params->{genomes})) {
        $srcgenomes = $params->{genomes};
    } else {
        $srcgenomes = $self->list_solr_genomes({
            solr_core => "Genomes_prod",
            complete => 1
        });
    }
    my $rdm_rast_ws=$params->{workspace_name};
=begin
    if (defined($params->{workspace_name})) {
        $rdm_rast_ws = $params->{workspace_name};
    } else {
        my $rdm_rast_ws = "ReferenceGenomes_RAST"; #$wsname . "_RAST";
    }
    eval {
        $self->util_ws_client()->create_workspace({workspace=>$rdm_rast_ws,globalread=>"r",description=>"ws for RAST-ed Refseq Genomes"});
    };
    if ($@) {
        print $@;
	if( $@!~/is already in use/ ) {
           print "Failed to create the workspace " . $rdm_rast_ws;
           exit 0;
	}
    }
    else
=cut
    {
        print "\nNow rasting genomes with rast_sdk url=".$ENV{ SDK_CALLBACK_URL }. " on " . scalar localtime . "\n";
        my $rast_ret;
        my $rast_params={
             genomes=>$srcgenomes,
             workspace=>$rdm_rast_ws
        };
        eval {
          $rast_ret = $raster->annotate_genomes($rast_params);
        };
        if ($@) {
            print "**********Received an exception from calling genbank_to_genome to load $srcgenomes\n";
            if (ref($@) eq "HASH") { 
                print "Exception message: " . $@->{"message"} . "\n";
                print "JSONRPC code: " . $@->{"code"} . "\n";
                print "Method: " . $@->{"method_name"} . "\n";
                print "\nServer-side exception:\n";
                print $@->{"data"};
            } else {
                print "Client-side exception:\n";
                print $@;
            }
        }
        else
        {
            $rastgenomes = {
		  report_ref => $rast_ret->{report_ref},
                  report => $rast_ret->{report_name},
                  workspace_name => $rast_ret->{workspace}
            };
            
            if ($params->{index_in_solr} == 1) {
                my $gn_solrCore = "GenomeFeatures_RASTed";
                $self->index_genomes_in_solr({
                        solr_core => $gn_solrCore,             
                        genomes => $srcgenomes
                });
            }
            $output = $srcgenomes;
         }
         print "**********************Genome rasting process ends on " . scalar localtime . "************************\n";
    }
    $msg .= "\nRASTed a total of ". scalar @{$output}. " genomes!\n";
    print $msg . "\n";

    if ($params->{create_report}) {
        $self->util_create_report({
            message => $msg,
            workspace => $params->{workspace_name}
        });
        $output = [$params->{workspace_name}."/rast_genomes"];
    }

    #END rast_genomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to rast_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'rast_genomes');
    }
    return($output);
}




=head2 update_loaded_genomes

  $output = $obj->update_loaded_genomes($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ReferenceDataManager.UpdateLoadedGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
UpdateLoadedGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	update_only has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	domain has a value which is a string
	start_offset has a value which is an int
bool is an int
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string

</pre>

=end html

=begin text

$params is a ReferenceDataManager.UpdateLoadedGenomesParams
$output is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
UpdateLoadedGenomesParams is a reference to a hash where the following keys are defined:
	ensembl has a value which is a ReferenceDataManager.bool
	refseq has a value which is a ReferenceDataManager.bool
	phytozome has a value which is a ReferenceDataManager.bool
	update_only has a value which is a ReferenceDataManager.bool
	workspace_name has a value which is a string
	domain has a value which is a string
	start_offset has a value which is an int
bool is an int
KBaseReferenceGenomeData is a reference to a hash where the following keys are defined:
	ref has a value which is a string
	id has a value which is a string
	workspace_name has a value which is a string
	source_id has a value which is a string
	accession has a value which is a string
	name has a value which is a string
	version has a value which is a string
	source has a value which is a string
	domain has a value which is a string


=end text



=item Description

Updates the loaded genomes in KBase for the specified source databases

=back

=cut

sub update_loaded_genomes
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to update_loaded_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'update_loaded_genomes');
    }

    my $ctx = $ReferenceDataManager::ReferenceDataManagerServer::CallContext;
    my($output);
    #BEGIN update_loaded_genomes
    $params = $self->util_initialize_call($params,$ctx);
    $params = $self->util_args($params,[],{
        refseq=>1,
        phytozome=>0,
        ensembl=>0, 
        update_only=>0,
        domain => "bacteria",
        start_offset=>0,
        workspace_name=>undef
    });

    my $msg = "";
    $output = [];

    my $count = 0;
    my $gn_solr_core = "GenomeFeatures_prod";
    my $tx_solr_core = "taxonomy_prod";

    my $ref_genomes = $self->list_reference_genomes({refseq=>$params->{refseq},phytozome=>$params->{phytozome},ensembl=>$params->{ensembl},domain=>$params->{domain},update_only=>$params->{update_only}});

    @{$ref_genomes} = @{$ref_genomes}[$params->{start_offset}..@{$ref_genomes}-1];
    for (my $i=0; $i < @{$ref_genomes}; $i++) {
        #print "\n***************Ref genome #". $i. "****************\n";
        my $gnm = $ref_genomes->[$i];
    
        #check if the genome is already present in the database by querying SOLR
        my $gn_status = $self->_checkGenomeStatus( $gnm, $gn_solr_core );
       
        if ($gn_status=~/(new|updated)/i) { 
                #check if the taxon of the genome (named in KBase as $gnm->{tax_id} . "_taxon") is loaded in a KBase workspace
                if( ($self->_checkTaxonStatus($gnm, $tx_solr_core))=~/in KBase/i ){
                    $count ++;
                    #print "A '" . $gn_status . "' genome with taxon in KBase found, update_total=" . $count;
                    $self->load_genomes( {genomes => [$gnm], index_in_solr => 1} ); 
                    push(@{$output},{genome_id=>$gnm->{id}});
                    if ($count < 10) {
                        $msg .= $gnm->{accession}.";".$gnm->{status}.";".$gnm->{name}.";".$gnm->{ftp_dir}.";".$gnm->{file}.";".$gnm->{id}.";".$gnm->{version}.";".$gnm->{source}.";".$gnm->{domain}."\n";
                    }
                }
        }else{
            #print "Current version already in KBase"; #check for annotation update
        }
    }
    $msg .= "Updated ".@{$output}." genomes!";
    print $msg . "\n";
    
    if ($params->{create_report}) {
        $self->util_create_report({
                message => $msg,
                workspace => $params->{workspace_name}
        });
        $output = [$params->{workspace_name}."/update_loaded_genomes"];
    }

    #END update_loaded_genomes
    my @_bad_returns;
    (ref($output) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to update_loaded_genomes:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'update_loaded_genomes');
    }
    return($output);
}




=head2 status 

  $return = $obj->status()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module status. This is a structure including Semantic Versioning number, state and git info.

=back

=cut

sub status {
    my($return);
    #BEGIN_STATUS
    $return = {"state" => "OK", "message" => "", "version" => $VERSION,
               "git_url" => $GIT_URL, "git_commit_hash" => $GIT_COMMIT_HASH};
    #END_STATUS
    return($return);
}

=head1 TYPES



=head2 bool

=over 4



=item Description

A boolean.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ListReferenceGenomesParams

=over 4



=item Description

Arguments for the list_reference_genomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
updated_only has a value which is a ReferenceDataManager.bool
domain has a value which is a string
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
updated_only has a value which is a ReferenceDataManager.bool
domain has a value which is a string
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool


=end text

=back



=head2 ReferenceGenomeData

=over 4



=item Description

Struct containing data for a single genome output by the list_reference_genomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
accession has a value which is a string
version_status has a value which is a string
asm_name has a value which is a string
ftp_dir has a value which is a string
file has a value which is a string
id has a value which is a string
version has a value which is a string
source has a value which is a string
domain has a value which is a string
refseq_category has a value which is a string
tax_id has a value which is a string
assembly_level has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
accession has a value which is a string
version_status has a value which is a string
asm_name has a value which is a string
ftp_dir has a value which is a string
file has a value which is a string
id has a value which is a string
version has a value which is a string
source has a value which is a string
domain has a value which is a string
refseq_category has a value which is a string
tax_id has a value which is a string
assembly_level has a value which is a string


=end text

=back



=head2 ListLoadedGenomesParams

=over 4



=item Description

Arguments for the list_loaded_genomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
genome_ver has a value which is an int
create_report has a value which is a ReferenceDataManager.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
genome_ver has a value which is an int
create_report has a value which is a ReferenceDataManager.bool


=end text

=back



=head2 LoadedReferenceGenomeData

=over 4



=item Description

Struct containing data for a single genome output by the list_loaded_genomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a string
id has a value which is a string
workspace_name has a value which is a string
source_id has a value which is a string
accession has a value which is a string
name has a value which is a string
version has a value which is a string
source has a value which is a string
domain has a value which is a string
type has a value which is a string
save_date has a value which is a string
contig_count has a value which is an int
feature_count has a value which is an int
size_bytes has a value which is an int
ftp_url has a value which is a string
gc has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a string
id has a value which is a string
workspace_name has a value which is a string
source_id has a value which is a string
accession has a value which is a string
name has a value which is a string
version has a value which is a string
source has a value which is a string
domain has a value which is a string
type has a value which is a string
save_date has a value which is a string
contig_count has a value which is an int
feature_count has a value which is an int
size_bytes has a value which is an int
ftp_url has a value which is a string
gc has a value which is a float


=end text

=back



=head2 solrdoc

=over 4



=item Description

Solr doc data for search requests.                                       
Arbitrary key-value pairs returned by the solr.


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 SolrGenomeFeatureData

=over 4



=item Description

Struct containing data for a single genome element output by the list_solr_genomes and index_genomes_in_solr functions


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_feature_id has a value which is a string
genome_id has a value which is a string
feature_id has a value which is a string
ws_ref has a value which is a string
feature_type has a value which is a string
aliases has a value which is a string
scientific_name has a value which is a string
domain has a value which is a string
functions has a value which is a string
genome_source has a value which is a string
go_ontology_description has a value which is a string
go_ontology_domain has a value which is a string
gene_name has a value which is a string
object_name has a value which is a string
location_contig has a value which is a string
location_strand has a value which is a string
taxonomy has a value which is a string
workspace_name has a value which is a string
genetic_code has a value which is a string
md5 has a value which is a string
tax_id has a value which is a string
assembly_ref has a value which is a string
taxonomy_ref has a value which is a string
ontology_namespaces has a value which is a string
ontology_ids has a value which is a string
ontology_names has a value which is a string
ontology_lineages has a value which is a string
dna_sequence_length has a value which is an int
genome_dna_size has a value which is an int
location_begin has a value which is an int
location_end has a value which is an int
num_cds has a value which is an int
num_contigs has a value which is an int
protein_translation_length has a value which is an int
gc_content has a value which is a float
complete has a value which is a ReferenceDataManager.bool
refseq_category has a value which is a string
save_date has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_feature_id has a value which is a string
genome_id has a value which is a string
feature_id has a value which is a string
ws_ref has a value which is a string
feature_type has a value which is a string
aliases has a value which is a string
scientific_name has a value which is a string
domain has a value which is a string
functions has a value which is a string
genome_source has a value which is a string
go_ontology_description has a value which is a string
go_ontology_domain has a value which is a string
gene_name has a value which is a string
object_name has a value which is a string
location_contig has a value which is a string
location_strand has a value which is a string
taxonomy has a value which is a string
workspace_name has a value which is a string
genetic_code has a value which is a string
md5 has a value which is a string
tax_id has a value which is a string
assembly_ref has a value which is a string
taxonomy_ref has a value which is a string
ontology_namespaces has a value which is a string
ontology_ids has a value which is a string
ontology_names has a value which is a string
ontology_lineages has a value which is a string
dna_sequence_length has a value which is an int
genome_dna_size has a value which is an int
location_begin has a value which is an int
location_end has a value which is an int
num_cds has a value which is an int
num_contigs has a value which is an int
protein_translation_length has a value which is an int
gc_content has a value which is a float
complete has a value which is a ReferenceDataManager.bool
refseq_category has a value which is a string
save_date has a value which is a string


=end text

=back



=head2 ListSolrDocsParams

=over 4



=item Description

Arguments for the list_solr_genomes and list_solr_taxa functions


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
solr_core has a value which is a string
row_start has a value which is an int
row_count has a value which is an int
group_option has a value which is a string
create_report has a value which is a ReferenceDataManager.bool
domain has a value which is a string
complete has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
solr_core has a value which is a string
row_start has a value which is an int
row_count has a value which is an int
group_option has a value which is a string
create_report has a value which is a ReferenceDataManager.bool
domain has a value which is a string
complete has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string


=end text

=back



=head2 KBaseReferenceGenomeData

=over 4



=item Description

Structure of a single KBase genome in the list returned by the load_genomes, rast_genomes and update_loaded_genomes functions


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a string
id has a value which is a string
workspace_name has a value which is a string
source_id has a value which is a string
accession has a value which is a string
name has a value which is a string
version has a value which is a string
source has a value which is a string
domain has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a string
id has a value which is a string
workspace_name has a value which is a string
source_id has a value which is a string
accession has a value which is a string
name has a value which is a string
version has a value which is a string
source has a value which is a string
domain has a value which is a string


=end text

=back



=head2 IndexGenomesInSolrParams

=over 4



=item Description

Arguments for the index_genomes_in_solr function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
solr_core has a value which is a string
workspace_name has a value which is a string
start_offset has a value which is an int
genome_ver has a value which is an int
create_report has a value which is a ReferenceDataManager.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
solr_core has a value which is a string
workspace_name has a value which is a string
start_offset has a value which is an int
genome_ver has a value which is an int
create_report has a value which is a ReferenceDataManager.bool


=end text

=back



=head2 ListLoadedTaxaParams

=over 4



=item Description

Argument(s) for the the lists_loaded_taxa function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool


=end text

=back



=head2 KBaseReferenceTaxonData

=over 4



=item Description

Struct containing data for a single taxon element output by the list_loaded_taxa function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxonomy_id has a value which is an int
scientific_name has a value which is a string
scientific_lineage has a value which is a string
rank has a value which is a string
kingdom has a value which is a string
domain has a value which is a string
aliases has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
parent_taxon_ref has a value which is a string
embl_code has a value which is a string
inherited_div_flag has a value which is an int
inherited_GC_flag has a value which is an int
mitochondrial_genetic_code has a value which is an int
inherited_MGC_flag has a value which is an int
GenBank_hidden_flag has a value which is an int
hidden_subtree_flag has a value which is an int
division_id has a value which is an int
comments has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxonomy_id has a value which is an int
scientific_name has a value which is a string
scientific_lineage has a value which is a string
rank has a value which is a string
kingdom has a value which is a string
domain has a value which is a string
aliases has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
parent_taxon_ref has a value which is a string
embl_code has a value which is a string
inherited_div_flag has a value which is an int
inherited_GC_flag has a value which is an int
mitochondrial_genetic_code has a value which is an int
inherited_MGC_flag has a value which is an int
GenBank_hidden_flag has a value which is an int
hidden_subtree_flag has a value which is an int
division_id has a value which is an int
comments has a value which is a string


=end text

=back



=head2 LoadedReferenceTaxonData

=over 4



=item Description

Struct containing data for a single output by the list_loaded_taxa function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxon has a value which is a ReferenceDataManager.KBaseReferenceTaxonData
ws_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxon has a value which is a ReferenceDataManager.KBaseReferenceTaxonData
ws_ref has a value which is a string


=end text

=back



=head2 SolrTaxonData

=over 4



=item Description

Struct containing data for a single taxon element output by the list_solr_taxa function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxonomy_id has a value which is an int
scientific_name has a value which is a string
scientific_lineage has a value which is a string
rank has a value which is a string
kingdom has a value which is a string
domain has a value which is a string
ws_ref has a value which is a string
aliases has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
parent_taxon_ref has a value which is a string
embl_code has a value which is a string
inherited_div_flag has a value which is an int
inherited_GC_flag has a value which is an int
mitochondrial_genetic_code has a value which is an int
inherited_MGC_flag has a value which is an int
GenBank_hidden_flag has a value which is an int
hidden_subtree_flag has a value which is an int
division_id has a value which is an int
comments has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxonomy_id has a value which is an int
scientific_name has a value which is a string
scientific_lineage has a value which is a string
rank has a value which is a string
kingdom has a value which is a string
domain has a value which is a string
ws_ref has a value which is a string
aliases has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
parent_taxon_ref has a value which is a string
embl_code has a value which is a string
inherited_div_flag has a value which is an int
inherited_GC_flag has a value which is an int
mitochondrial_genetic_code has a value which is an int
inherited_MGC_flag has a value which is an int
GenBank_hidden_flag has a value which is an int
hidden_subtree_flag has a value which is an int
division_id has a value which is an int
comments has a value which is a string


=end text

=back



=head2 LoadTaxonsParams

=over 4



=item Description

Arguments for the load_taxa function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
data has a value which is a string
taxons has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceTaxonData
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
data has a value which is a string
taxons has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceTaxonData
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool


=end text

=back



=head2 IndexTaxaInSolrParams

=over 4



=item Description

Arguments for the index_taxa_in_solr function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxa has a value which is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceTaxonData
solr_core has a value which is a string
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool
start_offset has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxa has a value which is a reference to a list where each element is a ReferenceDataManager.LoadedReferenceTaxonData
solr_core has a value which is a string
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool
start_offset has a value which is an int


=end text

=back



=head2 LoadGenomesParams

=over 4



=item Description

Arguments for the load_genomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
data has a value which is a string
genomes has a value which is a reference to a list where each element is a ReferenceDataManager.ReferenceGenomeData
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
data has a value which is a string
genomes has a value which is a reference to a list where each element is a ReferenceDataManager.ReferenceGenomeData
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string


=end text

=back



=head2 LoadRefGenomesParams

=over 4



=item Description

Arguments for the load_refgenomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
start_offset has a value which is an int
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
start_offset has a value which is an int
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string


=end text

=back



=head2 RASTGenomesParams

=over 4



=item Description

Arguments for the rast_genomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
data has a value which is a string
genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
data has a value which is a string
genomes has a value which is a reference to a list where each element is a ReferenceDataManager.KBaseReferenceGenomeData
index_in_solr has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
create_report has a value which is a ReferenceDataManager.bool


=end text

=back



=head2 UpdateLoadedGenomesParams

=over 4



=item Description

Arguments for the update_loaded_genomes function


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
update_only has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
domain has a value which is a string
start_offset has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ensembl has a value which is a ReferenceDataManager.bool
refseq has a value which is a ReferenceDataManager.bool
phytozome has a value which is a ReferenceDataManager.bool
update_only has a value which is a ReferenceDataManager.bool
workspace_name has a value which is a string
domain has a value which is a string
start_offset has a value which is an int


=end text

=back



=cut

1;
