# -*- coding: utf-8 -*-
############################################################
#
# Autogenerated by the KBase type compiler -
# any changes made here will be overwritten
#
############################################################

from __future__ import print_function
# the following is a hack to get the baseclient to import whether we're in a
# package or not. This makes pep8 unhappy hence the annotations.
try:
    # baseclient and this client are in a package
    from .baseclient import BaseClient as _BaseClient  # @UnusedImport
except:
    # no they aren't
    from baseclient import BaseClient as _BaseClient  # @Reimport


class ReferenceDataManager(object):

    def __init__(
            self, url=None, timeout=30 * 60, user_id=None,
            password=None, token=None, ignore_authrc=False,
            trust_all_ssl_certificates=False,
            auth_svc='https://kbase.us/services/authorization/Sessions/Login'):
        if url is None:
            raise ValueError('A url is required')
        self._service_ver = None
        self._client = _BaseClient(
            url, timeout=timeout, user_id=user_id, password=password,
            token=token, ignore_authrc=ignore_authrc,
            trust_all_ssl_certificates=trust_all_ssl_certificates,
            auth_svc=auth_svc)

    def list_reference_genomes(self, params, context=None):
        """
        Lists genomes present in selected reference databases (ensembl, phytozome, refseq)
        :param params: instance of type "ListReferenceGenomesParams"
           (Arguments for the list_reference_genomes function) -> structure:
           parameter "ensembl" of type "bool" (A boolean.), parameter
           "refseq" of type "bool" (A boolean.), parameter "phytozome" of
           type "bool" (A boolean.), parameter "domain" of String, parameter
           "workspace_name" of String, parameter "create_report" of type
           "bool" (A boolean.)
        :returns: instance of list of type "ReferenceGenomeData" (Struct
           containing data for a single genome output by the
           list_reference_genomes function) -> structure: parameter
           "accession" of String, parameter "version_status" of String,
           parameter "asm_name" of String, parameter "ftp_dir" of String,
           parameter "file" of String, parameter "id" of String, parameter
           "version" of String, parameter "source" of String, parameter
           "domain" of String, parameter "refseq_category" of String,
           parameter "tax_id" of String, parameter "assembly_level" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.list_reference_genomes',
            [params], self._service_ver, context)

    def list_loaded_genomes(self, params, context=None):
        """
        Lists genomes loaded into KBase from selected reference sources (ensembl, phytozome, refseq)
        :param params: instance of type "ListLoadedGenomesParams" (Arguments
           for the list_loaded_genomes function) -> structure: parameter
           "workspace_name" of String, parameter "data_source" of String,
           parameter "genome_ws" of String, parameter "genome_ver" of Long,
           parameter "save_date" of String, parameter "create_report" of type
           "bool" (A boolean.)
        :returns: instance of list of type "LoadedReferenceGenomeData"
           (Struct containing data for a single genome output by the
           list_loaded_genomes function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "version" of String,
           parameter "source" of String, parameter "domain" of String,
           parameter "type" of String, parameter "save_date" of String,
           parameter "contig_count" of Long, parameter "feature_count" of
           Long, parameter "size_bytes" of Long, parameter "ftp_url" of
           String, parameter "gc" of Double
        """
        return self._client.call_method(
            'ReferenceDataManager.list_loaded_genomes',
            [params], self._service_ver, context)

    def list_solr_genomes(self, params, context=None):
        """
        Lists genomes indexed in SOLR
        :param params: instance of type "ListSolrDocsParams" (Arguments for
           the list_solr_genomes and list_solr_taxa functions) -> structure:
           parameter "solr_core" of String, parameter "row_start" of Long,
           parameter "row_count" of Long, parameter "group_option" of String,
           parameter "create_report" of type "bool" (A boolean.), parameter
           "domain" of String, parameter "complete" of type "bool" (A
           boolean.), parameter "workspace_name" of String
        :returns: instance of list of type "solrdoc" (Solr doc data for
           search requests. Arbitrary key-value pairs returned by the solr.)
           -> mapping from String to String
        """
        return self._client.call_method(
            'ReferenceDataManager.list_solr_genomes',
            [params], self._service_ver, context)

    def index_genomes_in_solr(self, params, context=None):
        """
        Index specified genomes in SOLR from KBase workspace
        :param params: instance of type "IndexGenomesInSolrParams" (Arguments
           for the index_genomes_in_solr function) -> structure: parameter
           "genomes" of list of type "KBaseReferenceGenomeData" (Structure of
           a single KBase genome in the list returned by the load_genomes and
           update_loaded_genomes functions) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "version" of String,
           parameter "source" of String, parameter "domain" of String,
           parameter "solr_core" of String, parameter "workspace_name" of
           String, parameter "start_offset" of Long, parameter "genome_count"
           of Long, parameter "genome_source" of String, parameter
           "genome_ws" of String, parameter "index_features" of type "bool"
           (A boolean.), parameter "genome_ver" of Long, parameter
           "save_date" of String, parameter "create_report" of type "bool" (A
           boolean.)
        :returns: instance of list of type "SolrGenomeFeatureData" (Struct
           containing data for a single genome element output by the
           list_solr_genomes and index_genomes_in_solr functions) ->
           structure: parameter "genome_feature_id" of String, parameter
           "genome_id" of String, parameter "feature_id" of String, parameter
           "ws_ref" of String, parameter "feature_type" of String, parameter
           "aliases" of String, parameter "scientific_name" of String,
           parameter "domain" of String, parameter "functions" of String,
           parameter "genome_source" of String, parameter
           "go_ontology_description" of String, parameter
           "go_ontology_domain" of String, parameter "gene_name" of String,
           parameter "object_name" of String, parameter "location_contig" of
           String, parameter "location_strand" of String, parameter
           "taxonomy" of String, parameter "workspace_name" of String,
           parameter "genetic_code" of String, parameter "md5" of String,
           parameter "tax_id" of String, parameter "assembly_ref" of String,
           parameter "taxonomy_ref" of String, parameter
           "ontology_namespaces" of String, parameter "ontology_ids" of
           String, parameter "ontology_names" of String, parameter
           "ontology_lineages" of String, parameter "dna_sequence_length" of
           Long, parameter "genome_dna_size" of Long, parameter
           "location_begin" of Long, parameter "location_end" of Long,
           parameter "num_cds" of Long, parameter "num_contigs" of Long,
           parameter "protein_translation_length" of Long, parameter
           "gc_content" of Double, parameter "complete" of type "bool" (A
           boolean.), parameter "refseq_category" of String, parameter
           "save_date" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.index_genomes_in_solr',
            [params], self._service_ver, context)

    def list_loaded_taxa(self, params, context=None):
        """
        Lists taxa loaded into KBase for a given workspace
        :param params: instance of type "ListLoadedTaxaParams" (Argument(s)
           for the the lists_loaded_taxa function) -> structure: parameter
           "workspace_name" of String, parameter "create_report" of type
           "bool" (A boolean.)
        :returns: instance of list of type "LoadedReferenceTaxonData" (Struct
           containing data for a single output by the list_loaded_taxa
           function) -> structure: parameter "taxon" of type
           "KBaseReferenceTaxonData" (Struct containing data for a single
           taxon element output by the list_loaded_taxa function) ->
           structure: parameter "taxonomy_id" of Long, parameter
           "scientific_name" of String, parameter "scientific_lineage" of
           String, parameter "rank" of String, parameter "kingdom" of String,
           parameter "domain" of String, parameter "aliases" of list of
           String, parameter "genetic_code" of Long, parameter
           "parent_taxon_ref" of String, parameter "embl_code" of String,
           parameter "inherited_div_flag" of Long, parameter
           "inherited_GC_flag" of Long, parameter
           "mitochondrial_genetic_code" of Long, parameter
           "inherited_MGC_flag" of Long, parameter "GenBank_hidden_flag" of
           Long, parameter "hidden_subtree_flag" of Long, parameter
           "division_id" of Long, parameter "comments" of String, parameter
           "ws_ref" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.list_loaded_taxa',
            [params], self._service_ver, context)

    def list_solr_taxa(self, params, context=None):
        """
        Lists taxa indexed in SOLR
        :param params: instance of type "ListSolrDocsParams" (Arguments for
           the list_solr_genomes and list_solr_taxa functions) -> structure:
           parameter "solr_core" of String, parameter "row_start" of Long,
           parameter "row_count" of Long, parameter "group_option" of String,
           parameter "create_report" of type "bool" (A boolean.), parameter
           "domain" of String, parameter "complete" of type "bool" (A
           boolean.), parameter "workspace_name" of String
        :returns: instance of list of type "SolrTaxonData" (Struct containing
           data for a single taxon element output by the list_solr_taxa
           function) -> structure: parameter "taxonomy_id" of Long, parameter
           "scientific_name" of String, parameter "scientific_lineage" of
           String, parameter "rank" of String, parameter "kingdom" of String,
           parameter "domain" of String, parameter "ws_ref" of String,
           parameter "aliases" of list of String, parameter "genetic_code" of
           Long, parameter "parent_taxon_ref" of String, parameter
           "embl_code" of String, parameter "inherited_div_flag" of Long,
           parameter "inherited_GC_flag" of Long, parameter
           "mitochondrial_genetic_code" of Long, parameter
           "inherited_MGC_flag" of Long, parameter "GenBank_hidden_flag" of
           Long, parameter "hidden_subtree_flag" of Long, parameter
           "division_id" of Long, parameter "comments" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.list_solr_taxa',
            [params], self._service_ver, context)

    def load_taxa(self, params, context=None):
        """
        Loads specified taxa into KBase workspace and indexes in SOLR on demand
        :param params: instance of type "LoadTaxonsParams" (Arguments for the
           load_taxa function) -> structure: parameter "data" of String,
           parameter "taxons" of list of type "KBaseReferenceTaxonData"
           (Struct containing data for a single taxon element output by the
           list_loaded_taxa function) -> structure: parameter "taxonomy_id"
           of Long, parameter "scientific_name" of String, parameter
           "scientific_lineage" of String, parameter "rank" of String,
           parameter "kingdom" of String, parameter "domain" of String,
           parameter "aliases" of list of String, parameter "genetic_code" of
           Long, parameter "parent_taxon_ref" of String, parameter
           "embl_code" of String, parameter "inherited_div_flag" of Long,
           parameter "inherited_GC_flag" of Long, parameter
           "mitochondrial_genetic_code" of Long, parameter
           "inherited_MGC_flag" of Long, parameter "GenBank_hidden_flag" of
           Long, parameter "hidden_subtree_flag" of Long, parameter
           "division_id" of Long, parameter "comments" of String, parameter
           "index_in_solr" of type "bool" (A boolean.), parameter
           "workspace_name" of String, parameter "create_report" of type
           "bool" (A boolean.)
        :returns: instance of list of type "SolrTaxonData" (Struct containing
           data for a single taxon element output by the list_solr_taxa
           function) -> structure: parameter "taxonomy_id" of Long, parameter
           "scientific_name" of String, parameter "scientific_lineage" of
           String, parameter "rank" of String, parameter "kingdom" of String,
           parameter "domain" of String, parameter "ws_ref" of String,
           parameter "aliases" of list of String, parameter "genetic_code" of
           Long, parameter "parent_taxon_ref" of String, parameter
           "embl_code" of String, parameter "inherited_div_flag" of Long,
           parameter "inherited_GC_flag" of Long, parameter
           "mitochondrial_genetic_code" of Long, parameter
           "inherited_MGC_flag" of Long, parameter "GenBank_hidden_flag" of
           Long, parameter "hidden_subtree_flag" of Long, parameter
           "division_id" of Long, parameter "comments" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.load_taxa',
            [params], self._service_ver, context)

    def index_taxa_in_solr(self, params, context=None):
        """
        Index specified taxa in SOLR from KBase workspace
        :param params: instance of type "IndexTaxaInSolrParams" (Arguments
           for the index_taxa_in_solr function) -> structure: parameter
           "taxa" of list of type "LoadedReferenceTaxonData" (Struct
           containing data for a single output by the list_loaded_taxa
           function) -> structure: parameter "taxon" of type
           "KBaseReferenceTaxonData" (Struct containing data for a single
           taxon element output by the list_loaded_taxa function) ->
           structure: parameter "taxonomy_id" of Long, parameter
           "scientific_name" of String, parameter "scientific_lineage" of
           String, parameter "rank" of String, parameter "kingdom" of String,
           parameter "domain" of String, parameter "aliases" of list of
           String, parameter "genetic_code" of Long, parameter
           "parent_taxon_ref" of String, parameter "embl_code" of String,
           parameter "inherited_div_flag" of Long, parameter
           "inherited_GC_flag" of Long, parameter
           "mitochondrial_genetic_code" of Long, parameter
           "inherited_MGC_flag" of Long, parameter "GenBank_hidden_flag" of
           Long, parameter "hidden_subtree_flag" of Long, parameter
           "division_id" of Long, parameter "comments" of String, parameter
           "ws_ref" of String, parameter "solr_core" of String, parameter
           "workspace_name" of String, parameter "create_report" of type
           "bool" (A boolean.), parameter "start_offset" of Long
        :returns: instance of list of type "SolrTaxonData" (Struct containing
           data for a single taxon element output by the list_solr_taxa
           function) -> structure: parameter "taxonomy_id" of Long, parameter
           "scientific_name" of String, parameter "scientific_lineage" of
           String, parameter "rank" of String, parameter "kingdom" of String,
           parameter "domain" of String, parameter "ws_ref" of String,
           parameter "aliases" of list of String, parameter "genetic_code" of
           Long, parameter "parent_taxon_ref" of String, parameter
           "embl_code" of String, parameter "inherited_div_flag" of Long,
           parameter "inherited_GC_flag" of Long, parameter
           "mitochondrial_genetic_code" of Long, parameter
           "inherited_MGC_flag" of Long, parameter "GenBank_hidden_flag" of
           Long, parameter "hidden_subtree_flag" of Long, parameter
           "division_id" of Long, parameter "comments" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.index_taxa_in_solr',
            [params], self._service_ver, context)

    def load_genomes(self, params, context=None):
        """
        Loads specified genomes into KBase workspace and indexes in SOLR on demand
        :param params: instance of type "LoadGenomesParams" (Arguments for
           the load_genomes function) -> structure: parameter "data" of
           String, parameter "genomes" of list of type "ReferenceGenomeData"
           (Struct containing data for a single genome output by the
           list_reference_genomes function) -> structure: parameter
           "accession" of String, parameter "version_status" of String,
           parameter "asm_name" of String, parameter "ftp_dir" of String,
           parameter "file" of String, parameter "id" of String, parameter
           "version" of String, parameter "source" of String, parameter
           "domain" of String, parameter "refseq_category" of String,
           parameter "tax_id" of String, parameter "assembly_level" of
           String, parameter "index_in_solr" of type "bool" (A boolean.),
           parameter "workspace_name" of String, parameter "kb_env" of String
        :returns: instance of list of type "KBaseReferenceGenomeData"
           (Structure of a single KBase genome in the list returned by the
           load_genomes and update_loaded_genomes functions) -> structure:
           parameter "ref" of String, parameter "id" of String, parameter
           "workspace_name" of String, parameter "source_id" of String,
           parameter "accession" of String, parameter "name" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.load_genomes',
            [params], self._service_ver, context)

    def load_refgenomes(self, params, context=None):
        """
        Loads NCBI RefSeq genomes into KBase workspace with or without SOLR indexing
        :param params: instance of type "LoadRefGenomesParams" (Arguments for
           the load_refgenomes function) -> structure: parameter "ensembl" of
           type "bool" (A boolean.), parameter "refseq" of type "bool" (A
           boolean.), parameter "phytozome" of type "bool" (A boolean.),
           parameter "start_offset" of Long, parameter "index_in_solr" of
           type "bool" (A boolean.), parameter "workspace_name" of String,
           parameter "kb_env" of String
        :returns: instance of list of type "KBaseReferenceGenomeData"
           (Structure of a single KBase genome in the list returned by the
           load_genomes and update_loaded_genomes functions) -> structure:
           parameter "ref" of String, parameter "id" of String, parameter
           "workspace_name" of String, parameter "source_id" of String,
           parameter "accession" of String, parameter "name" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.load_refgenomes',
            [params], self._service_ver, context)

    def update_loaded_genomes(self, params, context=None):
        """
        Updates the loaded genomes in KBase for the specified source databases
        :param params: instance of type "UpdateLoadedGenomesParams"
           (Arguments for the update_loaded_genomes function) -> structure:
           parameter "ensembl" of type "bool" (A boolean.), parameter
           "refseq" of type "bool" (A boolean.), parameter "phytozome" of
           type "bool" (A boolean.), parameter "update_only" of type "bool"
           (A boolean.), parameter "workspace_name" of String, parameter
           "domain" of String, parameter "start_offset" of Long, parameter
           "index_in_solr" of type "bool" (A boolean.), parameter "kb_env" of
           String
        :returns: instance of list of type "KBaseReferenceGenomeData"
           (Structure of a single KBase genome in the list returned by the
           load_genomes and update_loaded_genomes functions) -> structure:
           parameter "ref" of String, parameter "id" of String, parameter
           "workspace_name" of String, parameter "source_id" of String,
           parameter "accession" of String, parameter "name" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.update_loaded_genomes',
            [params], self._service_ver, context)

    def status(self, context=None):
        return self._client.call_method('ReferenceDataManager.status',
                                        [], self._service_ver, context)
