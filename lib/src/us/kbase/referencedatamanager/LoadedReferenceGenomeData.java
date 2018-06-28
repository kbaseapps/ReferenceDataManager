
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
 * <p>Original spec-file type: LoadedReferenceGenomeData</p>
 * <pre>
 * Struct containing data for a single genome output by the list_loaded_genomes function
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "ref",
    "id",
    "workspace_name",
    "source_id",
    "accession",
    "name",
    "version",
    "source",
    "domain",
    "type",
    "save_date",
    "contig_count",
    "feature_count",
    "size_bytes",
    "ftp_url",
    "gc"
})
public class LoadedReferenceGenomeData {

    @JsonProperty("ref")
    private String ref;
    @JsonProperty("id")
    private String id;
    @JsonProperty("workspace_name")
    private String workspaceName;
    @JsonProperty("source_id")
    private String sourceId;
    @JsonProperty("accession")
    private String accession;
    @JsonProperty("name")
    private String name;
    @JsonProperty("version")
    private String version;
    @JsonProperty("source")
    private String source;
    @JsonProperty("domain")
    private String domain;
    @JsonProperty("type")
    private String type;
    @JsonProperty("save_date")
    private String saveDate;
    @JsonProperty("contig_count")
    private Long contigCount;
    @JsonProperty("feature_count")
    private Long featureCount;
    @JsonProperty("size_bytes")
    private Long sizeBytes;
    @JsonProperty("ftp_url")
    private String ftpUrl;
    @JsonProperty("gc")
    private Double gc;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("ref")
    public String getRef() {
        return ref;
    }

    @JsonProperty("ref")
    public void setRef(String ref) {
        this.ref = ref;
    }

    public LoadedReferenceGenomeData withRef(String ref) {
        this.ref = ref;
        return this;
    }

    @JsonProperty("id")
    public String getId() {
        return id;
    }

    @JsonProperty("id")
    public void setId(String id) {
        this.id = id;
    }

    public LoadedReferenceGenomeData withId(String id) {
        this.id = id;
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

    public LoadedReferenceGenomeData withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
        return this;
    }

    @JsonProperty("source_id")
    public String getSourceId() {
        return sourceId;
    }

    @JsonProperty("source_id")
    public void setSourceId(String sourceId) {
        this.sourceId = sourceId;
    }

    public LoadedReferenceGenomeData withSourceId(String sourceId) {
        this.sourceId = sourceId;
        return this;
    }

    @JsonProperty("accession")
    public String getAccession() {
        return accession;
    }

    @JsonProperty("accession")
    public void setAccession(String accession) {
        this.accession = accession;
    }

    public LoadedReferenceGenomeData withAccession(String accession) {
        this.accession = accession;
        return this;
    }

    @JsonProperty("name")
    public String getName() {
        return name;
    }

    @JsonProperty("name")
    public void setName(String name) {
        this.name = name;
    }

    public LoadedReferenceGenomeData withName(String name) {
        this.name = name;
        return this;
    }

    @JsonProperty("version")
    public String getVersion() {
        return version;
    }

    @JsonProperty("version")
    public void setVersion(String version) {
        this.version = version;
    }

    public LoadedReferenceGenomeData withVersion(String version) {
        this.version = version;
        return this;
    }

    @JsonProperty("source")
    public String getSource() {
        return source;
    }

    @JsonProperty("source")
    public void setSource(String source) {
        this.source = source;
    }

    public LoadedReferenceGenomeData withSource(String source) {
        this.source = source;
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

    public LoadedReferenceGenomeData withDomain(String domain) {
        this.domain = domain;
        return this;
    }

    @JsonProperty("type")
    public String getType() {
        return type;
    }

    @JsonProperty("type")
    public void setType(String type) {
        this.type = type;
    }

    public LoadedReferenceGenomeData withType(String type) {
        this.type = type;
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

    public LoadedReferenceGenomeData withSaveDate(String saveDate) {
        this.saveDate = saveDate;
        return this;
    }

    @JsonProperty("contig_count")
    public Long getContigCount() {
        return contigCount;
    }

    @JsonProperty("contig_count")
    public void setContigCount(Long contigCount) {
        this.contigCount = contigCount;
    }

    public LoadedReferenceGenomeData withContigCount(Long contigCount) {
        this.contigCount = contigCount;
        return this;
    }

    @JsonProperty("feature_count")
    public Long getFeatureCount() {
        return featureCount;
    }

    @JsonProperty("feature_count")
    public void setFeatureCount(Long featureCount) {
        this.featureCount = featureCount;
    }

    public LoadedReferenceGenomeData withFeatureCount(Long featureCount) {
        this.featureCount = featureCount;
        return this;
    }

    @JsonProperty("size_bytes")
    public Long getSizeBytes() {
        return sizeBytes;
    }

    @JsonProperty("size_bytes")
    public void setSizeBytes(Long sizeBytes) {
        this.sizeBytes = sizeBytes;
    }

    public LoadedReferenceGenomeData withSizeBytes(Long sizeBytes) {
        this.sizeBytes = sizeBytes;
        return this;
    }

    @JsonProperty("ftp_url")
    public String getFtpUrl() {
        return ftpUrl;
    }

    @JsonProperty("ftp_url")
    public void setFtpUrl(String ftpUrl) {
        this.ftpUrl = ftpUrl;
    }

    public LoadedReferenceGenomeData withFtpUrl(String ftpUrl) {
        this.ftpUrl = ftpUrl;
        return this;
    }

    @JsonProperty("gc")
    public Double getGc() {
        return gc;
    }

    @JsonProperty("gc")
    public void setGc(Double gc) {
        this.gc = gc;
    }

    public LoadedReferenceGenomeData withGc(Double gc) {
        this.gc = gc;
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
        return ((((((((((((((((((((((((((((((((((("LoadedReferenceGenomeData"+" [ref=")+ ref)+", id=")+ id)+", workspaceName=")+ workspaceName)+", sourceId=")+ sourceId)+", accession=")+ accession)+", name=")+ name)+", version=")+ version)+", source=")+ source)+", domain=")+ domain)+", type=")+ type)+", saveDate=")+ saveDate)+", contigCount=")+ contigCount)+", featureCount=")+ featureCount)+", sizeBytes=")+ sizeBytes)+", ftpUrl=")+ ftpUrl)+", gc=")+ gc)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
