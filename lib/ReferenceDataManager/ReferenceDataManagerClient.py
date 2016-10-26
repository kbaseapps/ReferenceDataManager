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
           type "bool" (A boolean.), parameter "updated_only" of type "bool"
           (A boolean.), parameter "workspace_name" of String, parameter
           "create_report" of type "bool" (A boolean.)
        :returns: instance of list of type "ReferenceGenomeData" (Struct
           containing data for a single genome output by the
           list_reference_genomes function) -> structure: parameter
           "accession" of String, parameter "status" of String, parameter
           "name" of String, parameter "ftp_dir" of String, parameter "file"
           of String, parameter "id" of String, parameter "version" of
           String, parameter "source" of String, parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.list_reference_genomes',
            [params], self._service_ver, context)

    def list_loaded_genomes(self, params, context=None):
        """
        Lists genomes loaded into KBase from selected reference sources (ensembl, phytozome, refseq)
        :param params: instance of type "ListLoadedGenomesParams" (Arguments
           for the list_loaded_genomes function) -> structure: parameter
           "ensembl" of type "bool" (A boolean.), parameter "refseq" of type
           "bool" (A boolean.), parameter "phytozome" of type "bool" (A
           boolean.), parameter "workspace_name" of String, parameter
           "create_report" of type "bool" (A boolean.)
        :returns: instance of list of type "KBaseReferenceGenomeData" (Struct
           containing data for a single genome output by the
           list_loaded_genomes function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "ftp_dir" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.list_loaded_genomes',
            [params], self._service_ver, context)

    def list_loaded_taxons(self, params, context=None):
        """
        Lists taxons loaded into KBase for a given workspace
        :param params: instance of type "ListLoadedTaxonsParams" (Argument(s)
           for the the lists_loaded_taxons function) -> structure: parameter
           "workspace_name" of String, parameter "create_report" of type
           "bool" (A boolean.)
        :returns: instance of list of type "KBaseReferenceTaxonData" (Struct
           containing data for a single taxon output by the
           list_loaded_taxons function) -> structure: parameter "taxonomy_id"
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
           "division_id" of Long, parameter "comments" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.list_loaded_taxons',
            [params], self._service_ver, context)

    def load_genomes(self, params, context=None):
        """
        Loads specified genomes into KBase workspace and indexes in SOLR on demand
        :param params: instance of type "LoadGenomesParams" (Arguments for
           the load_genomes function) -> structure: parameter "data" of
           String, parameter "genomes" of list of type "ReferenceGenomeData"
           (Struct containing data for a single genome output by the
           list_reference_genomes function) -> structure: parameter
           "accession" of String, parameter "status" of String, parameter
           "name" of String, parameter "ftp_dir" of String, parameter "file"
           of String, parameter "id" of String, parameter "version" of
           String, parameter "source" of String, parameter "domain" of
           String, parameter "index_in_solr" of type "bool" (A boolean.),
           parameter "workspace_name" of String, parameter "create_report" of
           type "bool" (A boolean.)
        :returns: instance of list of type "KBaseReferenceGenomeData" (Struct
           containing data for a single genome output by the
           list_loaded_genomes function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "ftp_dir" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.load_genomes',
            [params], self._service_ver, context)

    def load_taxons(self, params, context=None):
        """
        Loads specified genomes into KBase workspace and indexes in SOLR on demand
        :param params: instance of type "LoadTaxonsParams" (Arguments for the
           load_taxons function) -> structure: parameter "data" of String,
           parameter "taxons" of list of type "ReferenceTaxonData" (Struct
           containing data for a single taxon output by the
           list_loaded_taxons function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "ftp_dir" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String, parameter "index_in_solr" of type
           "bool" (A boolean.), parameter "workspace_name" of String,
           parameter "create_report" of type "bool" (A boolean.)
        :returns: instance of list of type "ReferenceTaxonData" (Struct
           containing data for a single taxon output by the
           list_loaded_taxons function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "ftp_dir" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.load_taxons',
            [params], self._service_ver, context)

    def index_genomes_in_solr(self, params, context=None):
        """
        Index specified genomes in SOLR from KBase workspace
        :param params: instance of type "IndexGenomesInSolrParams" (Arguments
           for the index_genomes_in_solr function) -> structure: parameter
           "genomes" of list of type "KBaseReferenceGenomeData" (Struct
           containing data for a single genome output by the
           list_loaded_genomes function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "ftp_dir" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String, parameter "workspace_name" of
           String, parameter "create_report" of type "bool" (A boolean.)
        :returns: instance of list of type "KBaseReferenceGenomeData" (Struct
           containing data for a single genome output by the
           list_loaded_genomes function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "ftp_dir" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.index_genomes_in_solr',
            [params], self._service_ver, context)

    def update_loaded_genomes(self, params, context=None):
        """
        Updates the loaded genomes in KBase for the specified source databases
        :param params: instance of type "UpdateLoadedGenomesParams"
           (Arguments for the update_loaded_genomes function) -> structure:
           parameter "ensembl" of type "bool" (A boolean.), parameter
           "refseq" of type "bool" (A boolean.), parameter "phytozome" of
           type "bool" (A boolean.), parameter "workspace_name" of String,
           parameter "create_report" of type "bool" (A boolean.)
        :returns: instance of list of type "KBaseReferenceGenomeData" (Struct
           containing data for a single genome output by the
           list_loaded_genomes function) -> structure: parameter "ref" of
           String, parameter "id" of String, parameter "workspace_name" of
           String, parameter "source_id" of String, parameter "accession" of
           String, parameter "name" of String, parameter "ftp_dir" of String,
           parameter "version" of String, parameter "source" of String,
           parameter "domain" of String
        """
        return self._client.call_method(
            'ReferenceDataManager.update_loaded_genomes',
            [params], self._service_ver, context)

    def status(self, context=None):
        return self._client.call_method('ReferenceDataManager.status',
                                        [], self._service_ver, context)
