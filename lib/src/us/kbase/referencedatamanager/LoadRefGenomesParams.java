
package us.kbase.referencedatamanager;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: LoadRefGenomesParams</p>
 * <pre>
 * Arguments for the load_refgenomes function
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "ensembl",
    "refseq",
    "phytozome",
    "domain",
    "start_offset",
    "index_in_solr",
    "workspace_name",
    "kb_env",
    "cut_off_date",
    "genome_type"
})
public class LoadRefGenomesParams {

    @JsonProperty("ensembl")
    private Long ensembl;
    @JsonProperty("refseq")
    private Long refseq;
    @JsonProperty("phytozome")
    private Long phytozome;
    @JsonProperty("domain")
    private String domain;
    @JsonProperty("start_offset")
    private Long startOffset;
    @JsonProperty("index_in_solr")
    private Long indexInSolr;
    @JsonProperty("workspace_name")
    private String workspaceName;
    @JsonProperty("kb_env")
    private String kbEnv;
    @JsonProperty("cut_off_date")
    private String cutOffDate;
    @JsonProperty("genome_type")
    private String genomeType;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("ensembl")
    public Long getEnsembl() {
        return ensembl;
    }

    @JsonProperty("ensembl")
    public void setEnsembl(Long ensembl) {
        this.ensembl = ensembl;
    }

    public LoadRefGenomesParams withEnsembl(Long ensembl) {
        this.ensembl = ensembl;
        return this;
    }

    @JsonProperty("refseq")
    public Long getRefseq() {
        return refseq;
    }

    @JsonProperty("refseq")
    public void setRefseq(Long refseq) {
        this.refseq = refseq;
    }

    public LoadRefGenomesParams withRefseq(Long refseq) {
        this.refseq = refseq;
        return this;
    }

    @JsonProperty("phytozome")
    public Long getPhytozome() {
        return phytozome;
    }

    @JsonProperty("phytozome")
    public void setPhytozome(Long phytozome) {
        this.phytozome = phytozome;
    }

    public LoadRefGenomesParams withPhytozome(Long phytozome) {
        this.phytozome = phytozome;
        return this;
    }

    @JsonProperty("domain")
    public String getDomain() {
        return domain;
    }

    @JsonProperty("domain")
    public void setDomain(String domain) {
        this.domain = domain;
    }

    public LoadRefGenomesParams withDomain(String domain) {
        this.domain = domain;
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

    public LoadRefGenomesParams withStartOffset(Long startOffset) {
        this.startOffset = startOffset;
        return this;
    }

    @JsonProperty("index_in_solr")
    public Long getIndexInSolr() {
        return indexInSolr;
    }

    @JsonProperty("index_in_solr")
    public void setIndexInSolr(Long indexInSolr) {
        this.indexInSolr = indexInSolr;
    }

    public LoadRefGenomesParams withIndexInSolr(Long indexInSolr) {
        this.indexInSolr = indexInSolr;
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

    public LoadRefGenomesParams withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
        return this;
    }

    @JsonProperty("kb_env")
    public String getKbEnv() {
        return kbEnv;
    }

    @JsonProperty("kb_env")
    public void setKbEnv(String kbEnv) {
        this.kbEnv = kbEnv;
    }

    public LoadRefGenomesParams withKbEnv(String kbEnv) {
        this.kbEnv = kbEnv;
        return this;
    }

    @JsonProperty("cut_off_date")
    public String getCutOffDate() {
        return cutOffDate;
    }

    @JsonProperty("cut_off_date")
    public void setCutOffDate(String cutOffDate) {
        this.cutOffDate = cutOffDate;
    }

    public LoadRefGenomesParams withCutOffDate(String cutOffDate) {
        this.cutOffDate = cutOffDate;
        return this;
    }

    @JsonProperty("genome_type")
    public String getGenomeType() {
        return genomeType;
    }

    @JsonProperty("genome_type")
    public void setGenomeType(String genomeType) {
        this.genomeType = genomeType;
    }

    public LoadRefGenomesParams withGenomeType(String genomeType) {
        this.genomeType = genomeType;
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
        return ((((((((((((((((((((((("LoadRefGenomesParams"+" [ensembl=")+ ensembl)+", refseq=")+ refseq)+", phytozome=")+ phytozome)+", domain=")+ domain)+", startOffset=")+ startOffset)+", indexInSolr=")+ indexInSolr)+", workspaceName=")+ workspaceName)+", kbEnv=")+ kbEnv)+", cutOffDate=")+ cutOffDate)+", genomeType=")+ genomeType)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
