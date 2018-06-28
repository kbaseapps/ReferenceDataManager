
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
 * <p>Original spec-file type: ListSolrDocsParams</p>
 * <pre>
 * Arguments for the list_solr_genomes and list_solr_taxa functions
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "solr_core",
    "row_start",
    "row_count",
    "group_option",
    "create_report",
    "domain",
    "complete",
    "workspace_name"
})
public class ListSolrDocsParams {

    @JsonProperty("solr_core")
    private String solrCore;
    @JsonProperty("row_start")
    private Long rowStart;
    @JsonProperty("row_count")
    private Long rowCount;
    @JsonProperty("group_option")
    private String groupOption;
    @JsonProperty("create_report")
    private Long createReport;
    @JsonProperty("domain")
    private String domain;
    @JsonProperty("complete")
    private Long complete;
    @JsonProperty("workspace_name")
    private String workspaceName;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("solr_core")
    public String getSolrCore() {
        return solrCore;
    }

    @JsonProperty("solr_core")
    public void setSolrCore(String solrCore) {
        this.solrCore = solrCore;
    }

    public ListSolrDocsParams withSolrCore(String solrCore) {
        this.solrCore = solrCore;
        return this;
    }

    @JsonProperty("row_start")
    public Long getRowStart() {
        return rowStart;
    }

    @JsonProperty("row_start")
    public void setRowStart(Long rowStart) {
        this.rowStart = rowStart;
    }

    public ListSolrDocsParams withRowStart(Long rowStart) {
        this.rowStart = rowStart;
        return this;
    }

    @JsonProperty("row_count")
    public Long getRowCount() {
        return rowCount;
    }

    @JsonProperty("row_count")
    public void setRowCount(Long rowCount) {
        this.rowCount = rowCount;
    }

    public ListSolrDocsParams withRowCount(Long rowCount) {
        this.rowCount = rowCount;
        return this;
    }

    @JsonProperty("group_option")
    public String getGroupOption() {
        return groupOption;
    }

    @JsonProperty("group_option")
    public void setGroupOption(String groupOption) {
        this.groupOption = groupOption;
    }

    public ListSolrDocsParams withGroupOption(String groupOption) {
        this.groupOption = groupOption;
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

    public ListSolrDocsParams withCreateReport(Long createReport) {
        this.createReport = createReport;
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

    public ListSolrDocsParams withDomain(String domain) {
        this.domain = domain;
        return this;
    }

    @JsonProperty("complete")
    public Long getComplete() {
        return complete;
    }

    @JsonProperty("complete")
    public void setComplete(Long complete) {
        this.complete = complete;
    }

    public ListSolrDocsParams withComplete(Long complete) {
        this.complete = complete;
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

    public ListSolrDocsParams withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
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
        return ((((((((((((((((((("ListSolrDocsParams"+" [solrCore=")+ solrCore)+", rowStart=")+ rowStart)+", rowCount=")+ rowCount)+", groupOption=")+ groupOption)+", createReport=")+ createReport)+", domain=")+ domain)+", complete=")+ complete)+", workspaceName=")+ workspaceName)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
