/*
A KBase module: ReferenceDataManager
*/

module ReferenceDataManager {
    /*
        A boolean.
    */
    typedef int bool;
    
    /*
        Arguments for the list_reference_genomes function
    */
    typedef structure {
        bool ensembl;
        bool refseq;
        bool phytozome;
        bool updated_only;
        string domain;
        string workspace_name;
        bool create_report;
        string solr_core; 
    } ListReferenceGenomesParams;

    /*
        Struct containing data for a single genome output by the list_reference_genomes function
    */
    typedef structure {
        string accession;
        string version_status;
        string asm_name;
        string ftp_dir;
        string file;
        string id;
        string version;
        string source;
        string domain;
        string refseq_category;
        string tax_id;
        string assembly_level;
    } ReferenceGenomeData;

    /*
        Lists genomes present in selected reference databases (ensembl, phytozome, refseq)
    */
    funcdef list_reference_genomes(ListReferenceGenomesParams params) returns (list<ReferenceGenomeData> output);
    
    /*
        Arguments for the list_loaded_genomes function
    */
    typedef structure {
	string workspace_name;
        string data_source;
        string genome_ws;
        int genome_ver;
	bool create_report;
    } ListLoadedGenomesParams;
    
    /*
        Struct containing data for a single genome output by the list_loaded_genomes function
    */

    typedef structure {
        string ref;
        string id;
        string workspace_name;
        string source_id;
        string accession;
        string name;
        string version;
        string source;
        string domain;
        string type;
        string save_date;
        int contig_count;
        int feature_count;
        int size_bytes;
	string ftp_url;
        float gc;
    } LoadedReferenceGenomeData;

    /*
        Lists genomes loaded into KBase from selected reference sources (ensembl, phytozome, refseq)
    */
    funcdef list_loaded_genomes(ListLoadedGenomesParams params) returns (list<LoadedReferenceGenomeData> output);


    /* Solr doc data for search requests.                                       
        Arbitrary key-value pairs returned by the solr.
    */  
    typedef mapping<string, string> solrdoc;

    /*
        Struct containing data for a single genome element output by the list_solr_genomes and index_genomes_in_solr functions 
    */
    typedef structure {
	string genome_feature_id;
	string genome_id;
        string feature_id;
	string ws_ref;
	string feature_type;
        string aliases;
	string scientific_name;	    
        string domain;      
        string functions;
	string genome_source;
        string go_ontology_description;
        string go_ontology_domain;
	string gene_name;
        string object_name;
	string location_contig;   
	string location_strand;    
        string taxonomy;
        string workspace_name;
	string genetic_code;
	string md5;
	string tax_id;
	string assembly_ref;
	string taxonomy_ref;
	string ontology_namespaces;
	string ontology_ids;
	string ontology_names;
	string ontology_lineages;	    
        int dna_sequence_length;     
        int genome_dna_size;
        int location_begin;
        int location_end;      
        int num_cds;
        int num_contigs;
        int protein_translation_length;	    
        float gc_content;
	bool complete;
        string refseq_category;  	    	 
        string save_date;
    } SolrGenomeFeatureData;

    /*
        Arguments for the list_solr_genomes and list_solr_taxa functions
    */

    typedef structure {
        string solr_core;
        int row_start;
        int row_count;
        string group_option;
	bool create_report;
        string domain;
        bool complete;
        string workspace_name;
    } ListSolrDocsParams;

    /* 
        Lists genomes indexed in SOLR
    */
    funcdef list_solr_genomes(ListSolrDocsParams params) returns (list<solrdoc> output) authentication required;

    /*  
        Structure of a single KBase genome in the list returned by the load_genomes and update_loaded_genomes functions
    */  
    typedef structure {
        string ref;
        string id;
        string workspace_name;
        string source_id;
        string accession;
        string name;
        string version;
        string source;
        string domain;
    } KBaseReferenceGenomeData;

    /*
        Arguments for the index_genomes_in_solr function
    */
    typedef structure {
        list<KBaseReferenceGenomeData> genomes;
        string solr_core;
        string workspace_name;
        int start_offset;
        int genome_count;
        string genome_source;
        string genome_ws;
        bool index_features;
        int genome_ver;
        bool create_report; 
    } IndexGenomesInSolrParams;
    
    /*
        Index specified genomes in SOLR from KBase workspace
    */
    funcdef index_genomes_in_solr(IndexGenomesInSolrParams params) returns (list<SolrGenomeFeatureData> output) authentication required;
    

    /*
        Argument(s) for the the lists_loaded_taxa function 
    */
    typedef structure {
        string workspace_name;
        bool create_report;
   } ListLoadedTaxaParams;
    
    /*
        Struct containing data for a single taxon element output by the list_loaded_taxa function
    */
    typedef structure {
        int taxonomy_id;
        string scientific_name;
        string scientific_lineage;
        string rank;
        string kingdom;
        string domain;
        list<string> aliases;
        int genetic_code;
        string parent_taxon_ref;
        string embl_code;
        int inherited_div_flag;
        int inherited_GC_flag;
        int mitochondrial_genetic_code;
        int inherited_MGC_flag;
        int GenBank_hidden_flag;
        int hidden_subtree_flag;
        int division_id;
        string comments;
    } KBaseReferenceTaxonData;


    /*
        Struct containing data for a single output by the list_loaded_taxa function
    */
    typedef structure {
        KBaseReferenceTaxonData taxon; 
        string ws_ref;
    } LoadedReferenceTaxonData;


    /*
        Lists taxa loaded into KBase for a given workspace 
    */
    funcdef list_loaded_taxa(ListLoadedTaxaParams params) returns (list<LoadedReferenceTaxonData> output);
   

    /*
        Struct containing data for a single taxon element output by the list_solr_taxa function
    */
    typedef structure {
        int taxonomy_id;
        string scientific_name;
        string scientific_lineage;
        string rank;
        string kingdom;
        string domain;
        string ws_ref;
        list<string> aliases;
        int genetic_code;
        string parent_taxon_ref;
        string embl_code;
        int inherited_div_flag;
        int inherited_GC_flag;
        int mitochondrial_genetic_code;
        int inherited_MGC_flag;
        int GenBank_hidden_flag;
        int hidden_subtree_flag;
        int division_id;
        string comments;
    } SolrTaxonData;

    /* 
        Lists taxa indexed in SOLR
    */
    funcdef list_solr_taxa(ListSolrDocsParams params) returns (list<SolrTaxonData> output) authentication required;

    /*
        Arguments for the load_taxa function
    */
    typedef structure {
        string data;
	list<KBaseReferenceTaxonData> taxons;
        bool index_in_solr;
	string workspace_name;
	bool create_report;
    } LoadTaxonsParams;

    /*
        Loads specified taxa into KBase workspace and indexes in SOLR on demand
    */
    funcdef load_taxa(LoadTaxonsParams params) returns (list<SolrTaxonData> output) authentication required;
    

    /*
        Arguments for the index_taxa_in_solr function
    */
    typedef structure {
        list<LoadedReferenceTaxonData> taxa;
        string solr_core;
        string workspace_name;
        bool create_report;
        int start_offset;
    } IndexTaxaInSolrParams;
    
    /*
        Index specified taxa in SOLR from KBase workspace
    */
    funcdef index_taxa_in_solr(IndexTaxaInSolrParams params) returns (list<SolrTaxonData> output) authentication required;
    
  
    /*
        Arguments for the load_genomes function
    */
    typedef structure {
        string data;
        list<ReferenceGenomeData> genomes;
        bool index_in_solr;
        string workspace_name;
        string kb_env;
    } LoadGenomesParams;
    
    /*
        Loads specified genomes into KBase workspace and indexes in SOLR on demand
    */
    funcdef load_genomes(LoadGenomesParams params) returns (list<KBaseReferenceGenomeData> output) authentication required;

    /*
        Arguments for the load_refgenomes function
    */
    typedef structure {
        bool ensembl;
        bool refseq;
        bool phytozome;
        int start_offset;
        bool index_in_solr;
        string workspace_name;
    } LoadRefGenomesParams;
    
    /*
        Loads Reference genomes into KBase workspace without indexing
    */
    funcdef load_refgenomes(LoadRefGenomesParams params) returns (list<KBaseReferenceGenomeData> output) authentication required;
   

    /*
        Arguments for the update_loaded_genomes function
    */
    typedef structure {
        bool ensembl;
        bool refseq;
        bool phytozome;
        bool update_only;
        string workspace_name;
        string domain;
        int start_offset;
        string kb_env;
    } UpdateLoadedGenomesParams;
    
    /*
        Updates the loaded genomes in KBase for the specified source databases
    */
    funcdef update_loaded_genomes(UpdateLoadedGenomesParams params) returns (list<KBaseReferenceGenomeData> output) authentication required;

};
