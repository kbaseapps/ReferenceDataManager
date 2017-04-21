use strict;
use Data::Dumper;
use Test::More;
use Config::Simple;
use Time::HiRes qw(time);
use Bio::KBase::AuthToken;
use Workspace::WorkspaceClient;
use ReferenceDataManager::ReferenceDataManagerImpl;

use Config::IniFiles;

local $| = 1;
my $token = $ENV{'KB_AUTH_TOKEN'};
my $config_file = $ENV{'KB_DEPLOYMENT_CONFIG'};
my $config = new Config::Simple($config_file)->get_block('ReferenceDataManager');
my $ws_url = $config->{"workspace-url"};
my $ws_name = undef;
my $ws_client = new Workspace::WorkspaceClient($ws_url,token => $token);
my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1, auth_svc=>$config->{'auth-service-url'});
print("ws url:".$config->{'workspace-url'} . "\n");
print("auth url:".$config->{'auth-service-url'} . "\n");
my $ctx = LocalCallContext->new($token, $auth_token->user_id);
$ReferenceDataManager::ReferenceDataManagerServer::CallContext = $ctx;
my $impl = new ReferenceDataManager::ReferenceDataManagerImpl();

sub get_ws_name {
    if (!defined($ws_name)) {
        my $suffix = int(time * 1000);
        $ws_name = 'test_RAST_SDK_' . $suffix;
        $ws_client->create_workspace({workspace => $ws_name});
    }
    return $ws_name;
}

sub check_genome_obj {
    my($genome_obj) = @_;
    ok(defined($genome_obj->{features}), "Features array is present");
    ok(scalar @{ $genome_obj->{features} } eq 1, "Number of features");
    ok(defined($genome_obj->{cdss}), "CDSs array is present");
    ok(scalar @{ $genome_obj->{cdss} } eq 1, "Number of CDSs");
    ok(defined($genome_obj->{mrnas}), "mRNAs array is present");
    ok(scalar @{ $genome_obj->{mrnas} } eq 1, "Number of mRNAs");
}

sub test_rast_genomes {
    my($genomes) = @_;
    my $params={
             genomes=>$genomes,
             workspace_name=>get_ws_name()
           };
    my $ret = $impl->rast_genomes($params);
}

eval {
#=begin
     #Testing list_solr_genomes function
    my $sgret;
    eval {
        $sgret = $impl->list_solr_genomes({
            solr_core => "Genomes_ci",
            domain => "Bacteria"
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
#=cut
    eval {
        test_rast_genomes($sgret);
    };  
    ok(!$@, "test_rast_genomes ran successfully.");
    if( $@) {
        print "ERROR:".$@;
    } else {
        print "Number of records:".@{$sgret}."\n";
        print "First record:\n";
        print Dumper($sgret->[0])."\n";
    }
  
    done_testing(3);
};

=begin old testings
eval {
    #Altering workspace map
    $impl->{_workspace_map}->{refseq} = "ReferenceDataManager";
    #$impl->{_workspace_map}->{refseq} = "Phytozome_Genomes";
    #$impl->{_workspace_map}->{refseq} = "RefSeq_Genomes";
    #$impl->{_workspace_map}->{refseq} = "KBasePublicRichGenomesV5";

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
    
    #Testing _listGenomesInSolr
    my $solrret;
    eval {i
        #$solrret = $impl->_listGenomesInSolr("Genomes_ci", "*",0,0,"KBaseGenomes.Genome-12.3");
        $solrret = $impl->_listGenomesInSolr("Genomes_prod", "*",0,0,"KBaseGenomes.Genome-8.2");
    };
    ok(!$@, "_listGenomesInSolr command successful");
    if ($@) { 
         print "ERROR:".$@;
     } else {
         print "List Genomes in Solr results:";
         print $solrret->{response}->{response}->{numFound}."\n";
     }
     ok(defined($solrret),"_listGenomesInSolr command returned at least one genome");

     #Testing rast_genomes function
     my $rgret;
     eval {
        $rgret = $impl->rast_genomes({});
     };
     ok(!$@,"rast_genomes command successful");
     if ($@) {
        print "ERROR:".$@;
     } else {
        print "Number of records:".@{$rgret}."\n";
        print "First record:\n";
        print Dumper($rgret->[0])."\n";
     }
     ok(defined($rgret->[0]),"rast_genomes command returned at least one genome");

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

    #Delete docs or wipe out the whole $delcore's content----USE CAUTION!
    my $delcore = "QZtest";
    my $ds = {
         #'workspace_name' => "QZtest",
         #'domain' => "Eukaryota"
         #'genome_id' => 'kb|g.0' 
    };
    #$impl->_deleteRecords($delcore, $ds);


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

    #Testing index_genomes_in_solr
    my $slrcore = "GenomeFeatures_ci";
    my $ret;
    eval {
        $ret = $impl->index_genomes_in_solr({
             #genomes => $wsret,#[@{$wsret}[(@{$wsret} - 2)..(@{$wsret} - 1)]],#$wsret, #[@{$wsret}[0..1]],
             solr_core => $slrcore,
             genome_ver => 1,
             start_offset => 0
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

    done_testing(2);
};
=cut old testings.

my $err = undef;
if ($@) {
    $err = $@;
}
eval {
    if (defined($ws_name)) {
        #$ws_client->delete_workspace({workspace => $ws_name});
        #print("Test workspace was deleted\n");
        print("Test workspace was named ". $ws_name . "\n");
        my $wsinfo = $ws_client->get_workspace_info({
                    workspace => $ws_name
                });
            my $maxid = $wsinfo->[4];
            print "\nMax genome object id=$maxid\n";
            eval {                                                                                             
                  my $wsoutput = $ws_client->list_objects({
                          workspaces => [$ws_name],
                          minObjectID => 0,
                          type => "KBaseGenomes.Genome-",
                          maxObjectID => $maxid,
                          includeMetadata => 1
                      });
		      print "Genome object count=" . @{$wsoutput}. "\n";
            };

        $ws_client->delete_workspace({workspace => $ws_name});
        print("Test workspace was deleted\n");
    }
};
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
