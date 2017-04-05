use strict;
use Data::Dumper;
use Test::More;
use Config::Simple;
use Time::HiRes qw(time);
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use ReferenceDataManager::ReferenceDataManagerImpl;

use Config::IniFiles;


local $| = 1;
my $token = $ENV{'KB_AUTH_TOKEN'};
my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
my $cfg = Config::IniFiles->new(-file=>$config_file);
my $wsInstance = $cfg->val('ReferenceDataManager','workspace-url');
die "no workspace-url defined" unless $wsInstance;

my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1, auth_svc=>$cfg->{'auth_service_url'});
print("ws url:".$cfg->{'workspace-url'} . "\n");
print("auth url:".$cfg->{'auth-service-url'} . "\n");   

#my $config = new Config::Simple($config_file)->get_block('ReferenceDataManager');
#my $ws_url = $config->{"workspace-url"};
#my $ws_name = undef;
#my $ws_client = new Bio::KBase::workspace::Client($ws_url,token => $token);
my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1);
my $ctx = LocalCallContext->new($token, $auth_token->user_id);
$ReferenceDataManager::ReferenceDataManagerServer::CallContext = $ctx;
my $impl = new ReferenceDataManager::ReferenceDataManagerImpl();

eval {
    #Altering workspace map
    $impl->{_workspace_map}->{refseq} = "ReferenceDataManager";
    #$impl->{_workspace_map}->{refseq} = "Phytozome_Genomes";
    #$impl->{_workspace_map}->{refseq} = "RefSeq_Genomes";
    #$impl->{_workspace_map}->{refseq} = "KBasePublicRichGenomesV5";

=begin
    #Testing update_loaded_genomes function
    my $wsgnmret;
    eval {
        $wsgnmret = $impl->update_loaded_genomes({
           refseq => 1
        });
    };
    ok(!$@,"update_loaded_genomes command successful");
    if ($@) {
        print "ERROR:".$@;
    } else {
        print "Number of records:".@{$wsgnmret}."\n";
        print "First record:\n";
        print Data::Dumper->Dump([$wsgnmret->[0]])."\n";
    }
    ok(defined($wsgnmret->[0]),"update_loaded_genomes command returned at least one record");
=cut
    
=begin passed tests
    #Testing _listGenomesInSolr
    my $solrret;
    eval {
        $solrret = $impl->_listGenomesInSolr("Genomes_ci", "*");
    };
    ok(!$@, "_listGenomesInSolr command successful");
    if ($@) { 
         print "ERROR:".$@;
     } else {
         print "First record:\n";
         print Dumper($solrret->[0])."\n";
     }
     ok(defined($solrret),"_listGenomesInSolr command returned at least one genome");
=cut    

#=begin
     #Testing list_solr_genomes function
    my $sgret;
    eval {
        $sgret = $impl->list_solr_genomes({
            solr_core => "Genomes_prod",
            complete => 1
        });
    };
    ok(!$@,"list_solr_genomes command successful");
    if ($@) {
        print "ERROR:".$@;
    } else {
        print "Number of records:".@{$sgret}."\n";
        print "First record:\n";
        print Dumper($sgret->[0])."\n";
    }
    ok(defined($sgret->[0]),"list_solr_genomes command returned at least one genome");
=cut

=begin 
    #Testing list_solr_taxa function
    my $stret;
    eval {
        $stret = $impl->list_solr_taxa({
            solr_core => "taxonomy_ci",
            group_option => "taxonomy_id"
        });
    };
    ok(!$@,"list_solr_taxa command successful");
    if ($@) {
        print "ERROR:".$@;
    } else {
        print "Number of records:".@{$stret}."\n";
        print "First record:\n";
        print Data::Dumper->Dump([$stret->[0]])."\n";
    }
    ok(defined($stret->[0]),"list_solr_taxa command returned at least one genome");
=cut

=begin list and load NCBI genomes
    #Testing the list_reference_genomes function
    my $refret;
    eval {
        $refret = $impl->list_reference_genomes({
            refseq => 1,
            domain => "bacteria,archaea,plant,fungi",
            update_only => 0 
        });
    };

    ok(!$@,"list_reference_Genomes command successful");
    if ($@) {
        print "ERROR:".$@;
    } else {
        print "Number of records:".@{$refret}."\n";
        print "First record:\n";
        print Data::Dumper->Dump([$refret->[0]])."\n";
        #print Data::Dumper->Dump([$refret->[@{$refret} - 1]])."\n";
    }
    ok(defined($refret->[0]),"list_reference_Genomes command returned at least one genome");
=cut

=begin testing _checkGenomeStatus    
    #Testing _checkGenomeStatus function
    my $gnstatusret;
    eval {
        $gnstatusret = $impl->_checkGenomeStatus($refret->[0], "GenomeFeatures_prod");
        #$gnstatusret = $impl->_checkGenomeStatus($refret->[@{$refret} - 1], "GenomeFeatures_prod");
    };
    ok(!$@, "_checkGenomeStatus command successful");
    if ($@) { 
         print "ERROR:".$@;
     } else {
         print "Result status: " .$gnstatusret."\n";
     }
     ok(defined($gnstatusret), "_checkGenomeStatus command returneds a value");
=cut

=begin testing _checkTaxonStatus    
    #Testing _checkTaxonStatus function
    my $txstatusret;
    eval {
        $txstatusret = $impl->_checkTaxonStatus($refret->[0], "taxonomy_ci");
        #$txstatusret = $impl->_checkTaxonStatus($refret->[@{$refret} - 1], "taxonomy_ci");
    };
    ok(!$@, "_checkTaxonStatus command successful");
    if ($@) { 
         print "ERROR:".$@;
     } else {
         print "Result status: " .$txstatusret."\n";
     }
     ok(defined($txstatusret), "_checkTaxonStatus command returneds a value");
=cut

=begin testing _updateGenomesCore    
    #Testing _updateGenomesCore function
    my $updret;
    eval {
        $updret = $impl->_updateGenomesCore("GenomeFeatures_ci", "Genomes_ci","KBaseGenomes.Genome-12.3");
    };
    ok(!$@, "_updateGenomesCore command successful");
    if ($@) { 
         print "ERROR:".$@;
    } else {
         print "Result status: " .$updret."\n";
    }
    ok(defined($updret), "_updateGenomesCore command returneds a value:" . $updret);
=cut

=begin test load_genomes
    #Testing load_genomes function
    my $ret;
    eval {
        $ret = $impl->load_genomes({
            genomes => $refret,
            index_in_solr => 0 
        });
    };
    ok(!$@,"load_genomes command successful");
    if ($@) {
        print "ERROR:".$@;
        my $err = $@;
        print "Error type: " . ref($err) . "\n";
        print "Error message: " . $err->{message} . "\n";
        print "Error error: " . $err->{error} . "\n";
        print "Error data: " .$err->{data} . "\n";
    } else {
        print "Loaded " . scalar @{$ret} . " genomes:\n";
        print Data::Dumper->Dump([$ret->[@{$ret}-1]])."\n";
    }
    ok(defined($ret->[0]),"load_genomes command returned at least one genome");

#=end of "list and load NCBI genomes
=cut

=begin test load_refgenomes
    #Testing load_refgenomes function
    my $rret;
    eval {
        $rret = $impl->load_refgenomes({
                refseq=>1,
                index_in_solr=>0,
                start=>80000
        });
    };
    ok(!$@,"load_refgenomes command successful");
    if ($@) {
        print "ERROR:".$@;
        my $err = $@;
        print "Error type: " . ref($err) . "\n";
        print "Error message: " . $err->{message} . "\n";
        print "Error error: " . $err->{error} . "\n";
        print "Error data: " .$err->{data} . "\n";
    } else {
        print "Loaded " . scalar @{$rret} . " genomes:\n";
        print Data::Dumper->Dump([$rret->[@{$rret}-1]])."\n";
    }
    ok(defined($rret->[0]),"load_refgenomes command returned at least one genome");
#=cut

=begin test delete solr documents
    #Delete docs or wipe out the whole $delcore's content----USE CAUTION!
    my $delcore = "QZtest";
    my $ds = {
         #'workspace_name' => "QZtest",
         #'domain' => "Eukaryota"
         #'genome_id' => 'kb|g.0' 
    };
    #$impl->_deleteRecords($delcore, $ds);
=cut

=begin indexing genome features

    #Testing list_loaded_genomes
    my $wsret;
    eval {
        $wsret = $impl->list_loaded_genomes({
            refseq => 1,
	    phytozome => 0,
            genome_ver => 2,
	    ensembl => 0	
	});
    };
    ok(!$@,"list_loaded_genomes command successful");
    if ($@) {
        print "ERROR:".$@;
    } else {
        print "Number of records:".@{$wsret}."\n";
        print "First record:\n";
        print Data::Dumper->Dump([$wsret->[@{$wsret} -1]])."\n";
        #print Data::Dumper->Dump([$wsret->[0]])."\n";
    }
    ok(defined($wsret->[0]),"list_loaded_genomes command returned at least one genome");
=cut

=begin testing index_genomes_in_solr
    #Testing index_genomes_in_solr
    my $slrcore = "GenomeFeatures_prod";
    my $ret;
    eval {
        $ret = $impl->index_genomes_in_solr({
             #genomes => $wsret,#[@{$wsret}[(@{$wsret} - 2)..(@{$wsret} - 1)]],#$wsret, #[@{$wsret}[0..1]],
             solr_core => $slrcore,
             genome_ver => 1,
             start_offset => 60000
        });
    };
    ok(!$@,"index_genomes_in_solr command successful");
    if ($@) {
        print "ERROR:".$@;
        #my $err = $@;
        #print "Error type: " . ref($err) . "\n";
        #print "Error message: " . $err->{message} . "\n";
        #print "Error error: " . $err->{error} . "\n";
        #print "Error data: " .$err->{data} . "\n";
    } else {
        print "Number of records:".@{$ret}."\n";
        print "First record:\n";
        print Data::Dumper->Dump([$ret->[0]])."\n";
   }
    ok(defined($ret->[0]),"\nindex_genomes_in_solr command returned at least one genome");
#=end of test indexing genome features    
=cut

=begin index taxa
    #Testing list_loaded_taxa
    my $taxon_ret;
    eval {
        $taxon_ret = $impl->list_loaded_taxa({ 
            workspace_name => "ReferenceTaxons",
            create_report => 0
    });
    };
    ok(!$@,"list_loaded_taxa command successful");
    if ($@) {
		my $err = $@;
                print "Error occurred with error type: " . ref($err) . "\n";
                #print "Error message: " . $err->{message} . "\n";
                #print "Error error: " . $err->{error} . "\n";
                #print "Error data: " .$err->{data} . "\n";
    } else {
        print "Number of records:".@{$taxon_ret}."\n";
        print "First record:\n";
        print Data::Dumper->Dump([$taxon_ret->[0]])."\n";
    }
    ok(defined($taxon_ret->[0]),"list_loaded_taxa command returned at least one taxon");
=cut

=begin
    #Testing index_taxa_in_solr
    my $solr_ret;
    eval {
        $solr_ret = $impl->index_taxa_in_solr({ 
                taxa => $taxon_ret,
                solr_core => "taxonomy_ci",
                create_report => 0
        });
    };
    ok(!$@,"index_taxa_in_solr command successful");
    if ($@) {
	my $err = $@;
        #print "Error type: " . ref($err) . "\n";
        #print "Error message: " . $err->{message} . "\n";
        #print "Error error: " . $err->{error} . "\n";
        #print "Error data: " .$err->{data} . "\n";
    } else {
        print "Number of records:".@{$solr_ret}."\n";
        print "First record:\n";
        print Data::Dumper->Dump([$solr_ret->[0]])."\n";
    }
    ok(defined($solr_ret->[0]),"index_taxa_in_solr command returned at least one taxon");
=cut
    
=begin   
    #Test _exists() function
    my $exist_ret;
    #my $crit = 'parent_taxon_ref:"1779/116411/1",rank:"species",scientific_lineage:"cellular organisms; Bacteria; Proteobacteria; Alphaproteobacteria; Rhizobiales; Bradyrhizobiaceae; Bradyrhizobium",scientific_name:"Bradyrhizobium sp. rp3", domain:"Bacteria"';
    my $searchCriteria = {
        parent_taxon_ref => '1779/116411/1',
        rank => 'species',
        scientific_lineage => 'cellular organisms; Bacteria; Proteobacteria; Alphaproteobacteria; Rhizobiales; Bradyrhizobiaceae; Bradyrhizobium',
        scientific_name => 'Bradyrhizobium sp. rp3',
        domain => 'Bacteria'
    };
    eval {
        $exist_ret = $impl->_exists("GenomeFeatures_ci", $searchCriteria);
    };
    ok(!$@, "_exists() command successful");
    if ($@) { 
         print "ERROR:".$@;
    } else {
         print "Return result=" . $exist_ret;
    }
    ok(defined($exist_ret),"_exists command returned a value"); 

=end passed tests
=cut
    done_testing(2);
};

my $err = undef;
if ($@) {
    $err = $@;
}
if (defined($err)) {
    if(ref($err) eq "Bio::KBase::Exceptions::KBaseException") {
        die("Error while running tests: " . $err->trace->as_string);
    } else {
        die $err;
    }
}

{
    package LocalCallContext;
    use strict;
    sub new {
        my($class,$token,$user) = @_;
        my $self = {
            token => $token,
            user_id => $user
        };
        return bless $self, $class;
    }
    sub user_id {
        my($self) = @_;
        return $self->{user_id};
    }
    sub token {
        my($self) = @_;
        return $self->{token};
    }
    sub provenance {
        my($self) = @_;
        return [{'service' => 'ReferenceDataManager', 'method' => 'please_never_use_it_in_production', 'method_params' => []}];
    }
    sub authenticated {
        return 1;
    }
    sub log_debug {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
    sub log_info {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
    sub method {
        my($self) = @_;
        return "TEST_METHOD";
    }
}
