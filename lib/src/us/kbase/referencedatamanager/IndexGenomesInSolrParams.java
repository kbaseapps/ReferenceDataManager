
package us.kbase.referencedatamanager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: IndexGenomesInSolrParams</p>
 * <pre>
 * Arguments for the index_genomes_in_solr function
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "genomes",
    "solr_core",
    "workspace_name",
    "start_offset",
    "genome_count",
    "genome_source",
    "genome_ws",
    "index_features",
    "genome_ver",
    "save_date",
    "create_report"
})
public class IndexGenomesInSolrParams {

    @JsonProperty("genomes")
    private List<KBaseReferenceGenomeData> genomes;
    @JsonProperty("solr_core")
    private String solrCore;
    @JsonProperty("workspace_name")
    private String workspaceName;
    @JsonProperty("start_offset")
    private Long startOffset;
    @JsonProperty("genome_count")
    private Long genomeCount;
    @JsonProperty("genome_source")
    private String genomeSource;
    @JsonProperty("genome_ws")
    private String genomeWs;
    @JsonProperty("index_features")
    private Long indexFeatures;
    @JsonProperty("genome_ver")
    private Long genomeVer;
    @JsonProperty("save_date")
    private String saveDate;
    @JsonProperty("create_report")
    private Long createReport;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("genomes")
    public List<KBaseReferenceGenomeData> getGenomes() {
        return genomes;
    }

    @JsonProperty("genomes")
    public void setGenomes(List<KBaseReferenceGenomeData> genomes) {
        this.genomes = genomes;
    }

    public IndexGenomesInSolrParams withGenomes(List<KBaseReferenceGenomeData> genomes) {
        this.genomes = genomes;
        return this;
    }

    @JsonProperty("solr_core")
    public String getSolrCore() {
        return solrCore;
    }

    @JsonProperty("solr_core")
    public void setSolrCore(String solrCore) {
        this.solrCore = solrCore;
    }

    public IndexGenomesInSolrParams withSolrCore(String solrCore) {
        this.solrCore = solrCore;
        return this;
    }

    @JsonProperty("workspace_name")
    public String getWorkspaceName() {
        return workspaceName;
    }

    @JsonProperty("workspace_name")
    public void setWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
    }

    public IndexGenomesInSolrParams withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
        return this;
    }

    @JsonProperty("start_offset")
    public Long getStartOffset() {
        return startOffset;
    }

    @JsonProperty("start_offset")
    public void setStartOffset(Long startOffset) {
        this.startOffset = startOffset;
    }

    public IndexGenomesInSolrParams withStartOffset(Long startOffset) {
        this.startOffset = startOffset;
        return this;
    }

    @JsonProperty("genome_count")
    public Long getGenomeCount() {
        return genomeCount;
    }

    @JsonProperty("genome_count")
    public void setGenomeCount(Long genomeCount) {
        this.genomeCount = genomeCount;
    }

    public IndexGenomesInSolrParams withGenomeCount(Long genomeCount) {
        this.genomeCount = genomeCount;
        return this;
    }

    @JsonProperty("genome_source")
    public String getGenomeSource() {
        return genomeSource;
    }

    @JsonProperty("genome_source")
    public void setGenomeSource(String genomeSource) {
        this.genomeSource = genomeSource;
    }

    public IndexGenomesInSolrParams withGenomeSource(String genomeSource) {
        this.genomeSource = genomeSource;
        return this;
    }

    @JsonProperty("genome_ws")
    public String getGenomeWs() {
        return genomeWs;
    }

    @JsonProperty("genome_ws")
    public void setGenomeWs(String genomeWs) {
        this.genomeWs = genomeWs;
    }

    public IndexGenomesInSolrParams withGenomeWs(String genomeWs) {
        this.genomeWs = genomeWs;
        return this;
    }

    @JsonProperty("index_features")
    public Long getIndexFeatures() {
        return indexFeatures;
    }

    @JsonProperty("index_features")
    public void setIndexFeatures(Long indexFeatures) {
        this.indexFeatures = indexFeatures;
    }

    public IndexGenomesInSolrParams withIndexFeatures(Long indexFeatures) {
        this.indexFeatures = indexFeatures;
        return this;
    }

    @JsonProperty("genome_ver")
    public Long getGenomeVer() {
        return genomeVer;
    }

    @JsonProperty("genome_ver")
    public void setGenomeVer(Long genomeVer) {
        this.genomeVer = genomeVer;
    }

    public IndexGenomesInSolrParams withGenomeVer(Long genomeVer) {
        this.genomeVer = genomeVer;
        return this;
    }

    @JsonProperty("save_date")
    public String getSaveDate() {
        return saveDate;
    }

    @JsonProperty("save_date")
    public void setSaveDate(String saveDate) {
        this.saveDate = saveDate;
    }

    public IndexGenomesInSolrParams withSaveDate(String saveDate) {
        this.saveDate = saveDate;
        return this;
    }

    @JsonProperty("create_report")
    public Long getCreateReport() {
        return createReport;
    }

    @JsonProperty("create_report")
    public void setCreateReport(Long createReport) {
        this.createReport = createReport;
    }

    public IndexGenomesInSolrParams withCreateReport(Long createReport) {
        this.createReport = createReport;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((((((((((((((((((((("IndexGenomesInSolrParams"+" [genomes=")+ genomes)+", solrCore=")+ solrCore)+", workspaceName=")+ workspaceName)+", startOffset=")+ startOffset)+", genomeCount=")+ genomeCount)+", genomeSource=")+ genomeSource)+", genomeWs=")+ genomeWs)+", indexFeatures=")+ indexFeatures)+", genomeVer=")+ genomeVer)+", saveDate=")+ saveDate)+", createReport=")+ createReport)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
