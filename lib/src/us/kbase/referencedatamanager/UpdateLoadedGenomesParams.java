
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
 * <p>Original spec-file type: UpdateLoadedGenomesParams</p>
 * <pre>
 * Arguments for the update_loaded_genomes function
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "ensembl",
    "refseq",
    "phytozome",
    "update_only",
    "workspace_name",
    "domain",
    "start_offset",
    "index_in_solr",
    "kb_env"
})
public class UpdateLoadedGenomesParams {

    @JsonProperty("ensembl")
    private Long ensembl;
    @JsonProperty("refseq")
    private Long refseq;
    @JsonProperty("phytozome")
    private Long phytozome;
    @JsonProperty("update_only")
    private Long updateOnly;
    @JsonProperty("workspace_name")
    private String workspaceName;
    @JsonProperty("domain")
    private String domain;
    @JsonProperty("start_offset")
    private Long startOffset;
    @JsonProperty("index_in_solr")
    private Long indexInSolr;
    @JsonProperty("kb_env")
    private String kbEnv;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("ensembl")
    public Long getEnsembl() {
        return ensembl;
    }

    @JsonProperty("ensembl")
    public void setEnsembl(Long ensembl) {
        this.ensembl = ensembl;
    }

    public UpdateLoadedGenomesParams withEnsembl(Long ensembl) {
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

    public UpdateLoadedGenomesParams withRefseq(Long refseq) {
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

    public UpdateLoadedGenomesParams withPhytozome(Long phytozome) {
        this.phytozome = phytozome;
        return this;
    }

    @JsonProperty("update_only")
    public Long getUpdateOnly() {
        return updateOnly;
    }

    @JsonProperty("update_only")
    public void setUpdateOnly(Long updateOnly) {
        this.updateOnly = updateOnly;
    }

    public UpdateLoadedGenomesParams withUpdateOnly(Long updateOnly) {
        this.updateOnly = updateOnly;
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

    public UpdateLoadedGenomesParams withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
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

    public UpdateLoadedGenomesParams withDomain(String domain) {
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

    public UpdateLoadedGenomesParams withStartOffset(Long startOffset) {
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

    public UpdateLoadedGenomesParams withIndexInSolr(Long indexInSolr) {
        this.indexInSolr = indexInSolr;
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

    public UpdateLoadedGenomesParams withKbEnv(String kbEnv) {
        this.kbEnv = kbEnv;
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
        return ((((((((((((((((((((("UpdateLoadedGenomesParams"+" [ensembl=")+ ensembl)+", refseq=")+ refseq)+", phytozome=")+ phytozome)+", updateOnly=")+ updateOnly)+", workspaceName=")+ workspaceName)+", domain=")+ domain)+", startOffset=")+ startOffset)+", indexInSolr=")+ indexInSolr)+", kbEnv=")+ kbEnv)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
