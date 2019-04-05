# ReferenceDataManager (RDM)
This module is built to periodically check and load reference data into KBase. Currently, RDM can handle genomes and taxons.

### Genomes:
1. RefSeq genomes are loaded into _RefseqGenomesWS_
2. ~~Ensembl genomes are loaded into~~
3. Phytozome genomes are loaded into _Phytozome_Genomes_

### Taxons:
NCBI Taxons are loaded into _ReferenceTaxons_

# Technical flow
1. Module ReferenceDataManager calls GenomeFileUtil.genbank_to_genome(params) to load the RefSeq genomes.
   The params structure is defined as:
       typedef structure {
        File file;
        string genome_name;
        string workspace_name;
        string source;
        string taxon_wsname;
        string taxon_reference;
        string release;
        string generate_ids_if_needed;
        int    genetic_code;
        usermeta metadata;
        boolean generate_missing_genes;
        string use_existing_assembly;
    } GenbankToGenomeParams;
    which does not include the 'scientific_name' parameter.  Note 'genome_name' is the accession name started with 'GCF_'.

2. GenomeFileUtil.genbank_to_genome(params) calls GenbankToGenome.refactored_import(ctx, params) which, in turn, calls
   GenbankToGenome.parse_genbank() that parses the organism into the scientific_name at:
   https://github.com/kbaseapps/GenomeFileUtil/blob/644c545ebfdd99fd78f6f1214e7953e9609164e7/lib/GenomeFileUtil/core/GenbankToGenome.py#L270
   