
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
 * <p>Original spec-file type: ReferenceGenomeData</p>
 * <pre>
 * Struct containing data for a single genome output by the list_reference_genomes function
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "accession",
    "version_status",
    "asm_name",
    "ftp_dir",
    "file",
    "id",
    "version",
    "source",
    "domain",
    "refseq_category",
    "tax_id",
    "assembly_level"
})
public class ReferenceGenomeData {

    @JsonProperty("accession")
    private String accession;
    @JsonProperty("version_status")
    private String versionStatus;
    @JsonProperty("asm_name")
    private String asmName;
    @JsonProperty("ftp_dir")
    private String ftpDir;
    @JsonProperty("file")
    private String file;
    @JsonProperty("id")
    private String id;
    @JsonProperty("version")
    private String version;
    @JsonProperty("source")
    private String source;
    @JsonProperty("domain")
    private String domain;
    @JsonProperty("refseq_category")
    private String refseqCategory;
    @JsonProperty("tax_id")
    private String taxId;
    @JsonProperty("assembly_level")
    private String assemblyLevel;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("accession")
    public String getAccession() {
        return accession;
    }

    @JsonProperty("accession")
    public void setAccession(String accession) {
        this.accession = accession;
    }

    public ReferenceGenomeData withAccession(String accession) {
        this.accession = accession;
        return this;
    }

    @JsonProperty("version_status")
    public String getVersionStatus() {
        return versionStatus;
    }

    @JsonProperty("version_status")
    public void setVersionStatus(String versionStatus) {
        this.versionStatus = versionStatus;
    }

    public ReferenceGenomeData withVersionStatus(String versionStatus) {
        this.versionStatus = versionStatus;
        return this;
    }

    @JsonProperty("asm_name")
    public String getAsmName() {
        return asmName;
    }

    @JsonProperty("asm_name")
    public void setAsmName(String asmName) {
        this.asmName = asmName;
    }

    public ReferenceGenomeData withAsmName(String asmName) {
        this.asmName = asmName;
        return this;
    }

    @JsonProperty("ftp_dir")
    public String getFtpDir() {
        return ftpDir;
    }

    @JsonProperty("ftp_dir")
    public void setFtpDir(String ftpDir) {
        this.ftpDir = ftpDir;
    }

    public ReferenceGenomeData withFtpDir(String ftpDir) {
        this.ftpDir = ftpDir;
        return this;
    }

    @JsonProperty("file")
    public String getFile() {
        return file;
    }

    @JsonProperty("file")
    public void setFile(String file) {
        this.file = file;
    }

    public ReferenceGenomeData withFile(String file) {
        this.file = file;
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

    public ReferenceGenomeData withId(String id) {
        this.id = id;
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

    public ReferenceGenomeData withVersion(String version) {
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

    public ReferenceGenomeData withSource(String source) {
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

    public ReferenceGenomeData withDomain(String domain) {
        this.domain = domain;
        return this;
    }

    @JsonProperty("refseq_category")
    public String getRefseqCategory() {
        return refseqCategory;
    }

    @JsonProperty("refseq_category")
    public void setRefseqCategory(String refseqCategory) {
        this.refseqCategory = refseqCategory;
    }

    public ReferenceGenomeData withRefseqCategory(String refseqCategory) {
        this.refseqCategory = refseqCategory;
        return this;
    }

    @JsonProperty("tax_id")
    public String getTaxId() {
        return taxId;
    }

    @JsonProperty("tax_id")
    public void setTaxId(String taxId) {
        this.taxId = taxId;
    }

    public ReferenceGenomeData withTaxId(String taxId) {
        this.taxId = taxId;
        return this;
    }

    @JsonProperty("assembly_level")
    public String getAssemblyLevel() {
        return assemblyLevel;
    }

    @JsonProperty("assembly_level")
    public void setAssemblyLevel(String assemblyLevel) {
        this.assemblyLevel = assemblyLevel;
    }

    public ReferenceGenomeData withAssemblyLevel(String assemblyLevel) {
        this.assemblyLevel = assemblyLevel;
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
        return ((((((((((((((((((((((((((("ReferenceGenomeData"+" [accession=")+ accession)+", versionStatus=")+ versionStatus)+", asmName=")+ asmName)+", ftpDir=")+ ftpDir)+", file=")+ file)+", id=")+ id)+", version=")+ version)+", source=")+ source)+", domain=")+ domain)+", refseqCategory=")+ refseqCategory)+", taxId=")+ taxId)+", assemblyLevel=")+ assemblyLevel)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
