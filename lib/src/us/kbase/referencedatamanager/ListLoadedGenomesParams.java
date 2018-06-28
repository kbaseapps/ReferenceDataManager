
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
 * <p>Original spec-file type: ListLoadedGenomesParams</p>
 * <pre>
 * Arguments for the list_loaded_genomes function
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "workspace_name",
    "data_source",
    "genome_ws",
    "genome_ver",
    "save_date",
    "create_report"
})
public class ListLoadedGenomesParams {

    @JsonProperty("workspace_name")
    private String workspaceName;
    @JsonProperty("data_source")
    private String dataSource;
    @JsonProperty("genome_ws")
    private String genomeWs;
    @JsonProperty("genome_ver")
    private Long genomeVer;
    @JsonProperty("save_date")
    private String saveDate;
    @JsonProperty("create_report")
    private Long createReport;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("workspace_name")
    public String getWorkspaceName() {
        return workspaceName;
    }

    @JsonProperty("workspace_name")
    public void setWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
    }

    public ListLoadedGenomesParams withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
        return this;
    }

    @JsonProperty("data_source")
    public String getDataSource() {
        return dataSource;
    }

    @JsonProperty("data_source")
    public void setDataSource(String dataSource) {
        this.dataSource = dataSource;
    }

    public ListLoadedGenomesParams withDataSource(String dataSource) {
        this.dataSource = dataSource;
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

    public ListLoadedGenomesParams withGenomeWs(String genomeWs) {
        this.genomeWs = genomeWs;
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

    public ListLoadedGenomesParams withGenomeVer(Long genomeVer) {
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

    public ListLoadedGenomesParams withSaveDate(String saveDate) {
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

    public ListLoadedGenomesParams withCreateReport(Long createReport) {
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
        return ((((((((((((((("ListLoadedGenomesParams"+" [workspaceName=")+ workspaceName)+", dataSource=")+ dataSource)+", genomeWs=")+ genomeWs)+", genomeVer=")+ genomeVer)+", saveDate=")+ saveDate)+", createReport=")+ createReport)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
