package us.kbase.referencedatamanager;

import com.fasterxml.jackson.core.type.TypeReference;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import us.kbase.auth.AuthToken;
import us.kbase.common.service.JsonClientCaller;
import us.kbase.common.service.JsonClientException;
import us.kbase.common.service.RpcContext;
import us.kbase.common.service.UnauthorizedException;

/**
 * <p>Original spec-file module name: ReferenceDataManager</p>
 * <pre>
 * A KBase module: ReferenceDataManager
 * </pre>
 */
public class ReferenceDataManagerClient {
    private JsonClientCaller caller;
    private String serviceVersion = null;


    /** Constructs a client with a custom URL and no user credentials.
     * @param url the URL of the service.
     */
    public ReferenceDataManagerClient(URL url) {
        caller = new JsonClientCaller(url);
    }
    /** Constructs a client with a custom URL.
     * @param url the URL of the service.
     * @param token the user's authorization token.
     * @throws UnauthorizedException if the token is not valid.
     * @throws IOException if an IOException occurs when checking the token's
     * validity.
     */
    public ReferenceDataManagerClient(URL url, AuthToken token) throws UnauthorizedException, IOException {
        caller = new JsonClientCaller(url, token);
    }

    /** Constructs a client with a custom URL.
     * @param url the URL of the service.
     * @param user the user name.
     * @param password the password for the user name.
     * @throws UnauthorizedException if the credentials are not valid.
     * @throws IOException if an IOException occurs when checking the user's
     * credentials.
     */
    public ReferenceDataManagerClient(URL url, String user, String password) throws UnauthorizedException, IOException {
        caller = new JsonClientCaller(url, user, password);
    }

    /** Constructs a client with a custom URL
     * and a custom authorization service URL.
     * @param url the URL of the service.
     * @param user the user name.
     * @param password the password for the user name.
     * @param auth the URL of the authorization server.
     * @throws UnauthorizedException if the credentials are not valid.
     * @throws IOException if an IOException occurs when checking the user's
     * credentials.
     */
    public ReferenceDataManagerClient(URL url, String user, String password, URL auth) throws UnauthorizedException, IOException {
        caller = new JsonClientCaller(url, user, password, auth);
    }

    /** Get the token this client uses to communicate with the server.
     * @return the authorization token.
     */
    public AuthToken getToken() {
        return caller.getToken();
    }

    /** Get the URL of the service with which this client communicates.
     * @return the service URL.
     */
    public URL getURL() {
        return caller.getURL();
    }

    /** Set the timeout between establishing a connection to a server and
     * receiving a response. A value of zero or null implies no timeout.
     * @param milliseconds the milliseconds to wait before timing out when
     * attempting to read from a server.
     */
    public void setConnectionReadTimeOut(Integer milliseconds) {
        this.caller.setConnectionReadTimeOut(milliseconds);
    }

    /** Check if this client allows insecure http (vs https) connections.
     * @return true if insecure connections are allowed.
     */
    public boolean isInsecureHttpConnectionAllowed() {
        return caller.isInsecureHttpConnectionAllowed();
    }

    /** Deprecated. Use isInsecureHttpConnectionAllowed().
     * @deprecated
     */
    public boolean isAuthAllowedForHttp() {
        return caller.isAuthAllowedForHttp();
    }

    /** Set whether insecure http (vs https) connections should be allowed by
     * this client.
     * @param allowed true to allow insecure connections. Default false
     */
    public void setIsInsecureHttpConnectionAllowed(boolean allowed) {
        caller.setInsecureHttpConnectionAllowed(allowed);
    }

    /** Deprecated. Use setIsInsecureHttpConnectionAllowed().
     * @deprecated
     */
    public void setAuthAllowedForHttp(boolean isAuthAllowedForHttp) {
        caller.setAuthAllowedForHttp(isAuthAllowedForHttp);
    }

    /** Set whether all SSL certificates, including self-signed certificates,
     * should be trusted.
     * @param trustAll true to trust all certificates. Default false.
     */
    public void setAllSSLCertificatesTrusted(final boolean trustAll) {
        caller.setAllSSLCertificatesTrusted(trustAll);
    }
    
    /** Check if this client trusts all SSL certificates, including
     * self-signed certificates.
     * @return true if all certificates are trusted.
     */
    public boolean isAllSSLCertificatesTrusted() {
        return caller.isAllSSLCertificatesTrusted();
    }
    /** Sets streaming mode on. In this case, the data will be streamed to
     * the server in chunks as it is read from disk rather than buffered in
     * memory. Many servers are not compatible with this feature.
     * @param streamRequest true to set streaming mode on, false otherwise.
     */
    public void setStreamingModeOn(boolean streamRequest) {
        caller.setStreamingModeOn(streamRequest);
    }

    /** Returns true if streaming mode is on.
     * @return true if streaming mode is on.
     */
    public boolean isStreamingModeOn() {
        return caller.isStreamingModeOn();
    }

    public void _setFileForNextRpcResponse(File f) {
        caller.setFileForNextRpcResponse(f);
    }

    public String getServiceVersion() {
        return this.serviceVersion;
    }

    public void setServiceVersion(String newValue) {
        this.serviceVersion = newValue;
    }

    /**
     * <p>Original spec-file function name: list_reference_genomes</p>
     * <pre>
     * Lists genomes present in selected reference databases (ensembl, phytozome, refseq)
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.ListReferenceGenomesParams ListReferenceGenomesParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.ReferenceGenomeData ReferenceGenomeData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<ReferenceGenomeData> listReferenceGenomes(ListReferenceGenomesParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<ReferenceGenomeData>>> retType = new TypeReference<List<List<ReferenceGenomeData>>>() {};
        List<List<ReferenceGenomeData>> res = caller.jsonrpcCall("ReferenceDataManager.list_reference_genomes", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: list_loaded_genomes</p>
     * <pre>
     * Lists genomes loaded into KBase from selected reference sources (ensembl, phytozome, refseq)
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.ListLoadedGenomesParams ListLoadedGenomesParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.LoadedReferenceGenomeData LoadedReferenceGenomeData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<LoadedReferenceGenomeData> listLoadedGenomes(ListLoadedGenomesParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<LoadedReferenceGenomeData>>> retType = new TypeReference<List<List<LoadedReferenceGenomeData>>>() {};
        List<List<LoadedReferenceGenomeData>> res = caller.jsonrpcCall("ReferenceDataManager.list_loaded_genomes", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: list_solr_genomes</p>
     * <pre>
     * Lists genomes indexed in SOLR
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.ListSolrDocsParams ListSolrDocsParams}
     * @return   parameter "output" of list of original type "solrdoc" (Solr doc data for search requests. Arbitrary key-value pairs returned by the solr.) &rarr; mapping from String to String
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<Map<String,String>> listSolrGenomes(ListSolrDocsParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<Map<String,String>>>> retType = new TypeReference<List<List<Map<String,String>>>>() {};
        List<List<Map<String,String>>> res = caller.jsonrpcCall("ReferenceDataManager.list_solr_genomes", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: index_genomes_in_solr</p>
     * <pre>
     * Index specified genomes in SOLR from KBase workspace
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.IndexGenomesInSolrParams IndexGenomesInSolrParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.SolrGenomeFeatureData SolrGenomeFeatureData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<SolrGenomeFeatureData> indexGenomesInSolr(IndexGenomesInSolrParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<SolrGenomeFeatureData>>> retType = new TypeReference<List<List<SolrGenomeFeatureData>>>() {};
        List<List<SolrGenomeFeatureData>> res = caller.jsonrpcCall("ReferenceDataManager.index_genomes_in_solr", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: list_loaded_taxa</p>
     * <pre>
     * Lists taxa loaded into KBase for a given workspace
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.ListLoadedTaxaParams ListLoadedTaxaParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.LoadedReferenceTaxonData LoadedReferenceTaxonData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<LoadedReferenceTaxonData> listLoadedTaxa(ListLoadedTaxaParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<LoadedReferenceTaxonData>>> retType = new TypeReference<List<List<LoadedReferenceTaxonData>>>() {};
        List<List<LoadedReferenceTaxonData>> res = caller.jsonrpcCall("ReferenceDataManager.list_loaded_taxa", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: list_solr_taxa</p>
     * <pre>
     * Lists taxa indexed in SOLR
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.ListSolrDocsParams ListSolrDocsParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.SolrTaxonData SolrTaxonData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<SolrTaxonData> listSolrTaxa(ListSolrDocsParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<SolrTaxonData>>> retType = new TypeReference<List<List<SolrTaxonData>>>() {};
        List<List<SolrTaxonData>> res = caller.jsonrpcCall("ReferenceDataManager.list_solr_taxa", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: load_taxa</p>
     * <pre>
     * Loads specified taxa into KBase workspace and indexes in SOLR on demand
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.LoadTaxonsParams LoadTaxonsParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.SolrTaxonData SolrTaxonData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<SolrTaxonData> loadTaxa(LoadTaxonsParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<SolrTaxonData>>> retType = new TypeReference<List<List<SolrTaxonData>>>() {};
        List<List<SolrTaxonData>> res = caller.jsonrpcCall("ReferenceDataManager.load_taxa", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: index_taxa_in_solr</p>
     * <pre>
     * Index specified taxa in SOLR from KBase workspace
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.IndexTaxaInSolrParams IndexTaxaInSolrParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.SolrTaxonData SolrTaxonData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<SolrTaxonData> indexTaxaInSolr(IndexTaxaInSolrParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<SolrTaxonData>>> retType = new TypeReference<List<List<SolrTaxonData>>>() {};
        List<List<SolrTaxonData>> res = caller.jsonrpcCall("ReferenceDataManager.index_taxa_in_solr", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: load_genomes</p>
     * <pre>
     * Loads specified genomes into KBase workspace and indexes in SOLR on demand
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.LoadGenomesParams LoadGenomesParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.KBaseReferenceGenomeData KBaseReferenceGenomeData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<KBaseReferenceGenomeData> loadGenomes(LoadGenomesParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<KBaseReferenceGenomeData>>> retType = new TypeReference<List<List<KBaseReferenceGenomeData>>>() {};
        List<List<KBaseReferenceGenomeData>> res = caller.jsonrpcCall("ReferenceDataManager.load_genomes", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: load_refgenomes</p>
     * <pre>
     * Loads NCBI RefSeq genomes into KBase workspace with or without SOLR indexing
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.LoadRefGenomesParams LoadRefGenomesParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.KBaseReferenceGenomeData KBaseReferenceGenomeData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<KBaseReferenceGenomeData> loadRefgenomes(LoadRefGenomesParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<KBaseReferenceGenomeData>>> retType = new TypeReference<List<List<KBaseReferenceGenomeData>>>() {};
        List<List<KBaseReferenceGenomeData>> res = caller.jsonrpcCall("ReferenceDataManager.load_refgenomes", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: update_loaded_genomes</p>
     * <pre>
     * Updates the loaded genomes in KBase for the specified source databases
     * </pre>
     * @param   params   instance of type {@link us.kbase.referencedatamanager.UpdateLoadedGenomesParams UpdateLoadedGenomesParams}
     * @return   parameter "output" of list of type {@link us.kbase.referencedatamanager.KBaseReferenceGenomeData KBaseReferenceGenomeData}
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public List<KBaseReferenceGenomeData> updateLoadedGenomes(UpdateLoadedGenomesParams params, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(params);
        TypeReference<List<List<KBaseReferenceGenomeData>>> retType = new TypeReference<List<List<KBaseReferenceGenomeData>>>() {};
        List<List<KBaseReferenceGenomeData>> res = caller.jsonrpcCall("ReferenceDataManager.update_loaded_genomes", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    public Map<String, Object> status(RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        TypeReference<List<Map<String, Object>>> retType = new TypeReference<List<Map<String, Object>>>() {};
        List<Map<String, Object>> res = caller.jsonrpcCall("ReferenceDataManager.status", args, retType, true, false, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }
}
