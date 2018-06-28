
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
 * <p>Original spec-file type: SolrGenomeFeatureData</p>
 * <pre>
 * Struct containing data for a single genome element output by the list_solr_genomes and index_genomes_in_solr functions
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "genome_feature_id",
    "genome_id",
    "feature_id",
    "ws_ref",
    "feature_type",
    "aliases",
    "scientific_name",
    "domain",
    "functions",
    "genome_source",
    "go_ontology_description",
    "go_ontology_domain",
    "gene_name",
    "object_name",
    "location_contig",
    "location_strand",
    "taxonomy",
    "workspace_name",
    "genetic_code",
    "md5",
    "tax_id",
    "assembly_ref",
    "taxonomy_ref",
    "ontology_namespaces",
    "ontology_ids",
    "ontology_names",
    "ontology_lineages",
    "dna_sequence_length",
    "genome_dna_size",
    "location_begin",
    "location_end",
    "num_cds",
    "num_contigs",
    "protein_translation_length",
    "gc_content",
    "complete",
    "refseq_category",
    "save_date"
})
public class SolrGenomeFeatureData {

    @JsonProperty("genome_feature_id")
    private String genomeFeatureId;
    @JsonProperty("genome_id")
    private String genomeId;
    @JsonProperty("feature_id")
    private String featureId;
    @JsonProperty("ws_ref")
    private String wsRef;
    @JsonProperty("feature_type")
    private String featureType;
    @JsonProperty("aliases")
    private String aliases;
    @JsonProperty("scientific_name")
    private String scientificName;
    @JsonProperty("domain")
    private String domain;
    @JsonProperty("functions")
    private String functions;
    @JsonProperty("genome_source")
    private String genomeSource;
    @JsonProperty("go_ontology_description")
    private String goOntologyDescription;
    @JsonProperty("go_ontology_domain")
    private String goOntologyDomain;
    @JsonProperty("gene_name")
    private String geneName;
    @JsonProperty("object_name")
    private String objectName;
    @JsonProperty("location_contig")
    private String locationContig;
    @JsonProperty("location_strand")
    private String locationStrand;
    @JsonProperty("taxonomy")
    private String taxonomy;
    @JsonProperty("workspace_name")
    private String workspaceName;
    @JsonProperty("genetic_code")
    private String geneticCode;
    @JsonProperty("md5")
    private String md5;
    @JsonProperty("tax_id")
    private String taxId;
    @JsonProperty("assembly_ref")
    private String assemblyRef;
    @JsonProperty("taxonomy_ref")
    private String taxonomyRef;
    @JsonProperty("ontology_namespaces")
    private String ontologyNamespaces;
    @JsonProperty("ontology_ids")
    private String ontologyIds;
    @JsonProperty("ontology_names")
    private String ontologyNames;
    @JsonProperty("ontology_lineages")
    private String ontologyLineages;
    @JsonProperty("dna_sequence_length")
    private Long dnaSequenceLength;
    @JsonProperty("genome_dna_size")
    private Long genomeDnaSize;
    @JsonProperty("location_begin")
    private Long locationBegin;
    @JsonProperty("location_end")
    private Long locationEnd;
    @JsonProperty("num_cds")
    private Long numCds;
    @JsonProperty("num_contigs")
    private Long numContigs;
    @JsonProperty("protein_translation_length")
    private Long proteinTranslationLength;
    @JsonProperty("gc_content")
    private Double gcContent;
    @JsonProperty("complete")
    private Long complete;
    @JsonProperty("refseq_category")
    private String refseqCategory;
    @JsonProperty("save_date")
    private String saveDate;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("genome_feature_id")
    public String getGenomeFeatureId() {
        return genomeFeatureId;
    }

    @JsonProperty("genome_feature_id")
    public void setGenomeFeatureId(String genomeFeatureId) {
        this.genomeFeatureId = genomeFeatureId;
    }

    public SolrGenomeFeatureData withGenomeFeatureId(String genomeFeatureId) {
        this.genomeFeatureId = genomeFeatureId;
        return this;
    }

    @JsonProperty("genome_id")
    public String getGenomeId() {
        return genomeId;
    }

    @JsonProperty("genome_id")
    public void setGenomeId(String genomeId) {
        this.genomeId = genomeId;
    }

    public SolrGenomeFeatureData withGenomeId(String genomeId) {
        this.genomeId = genomeId;
        return this;
    }

    @JsonProperty("feature_id")
    public String getFeatureId() {
        return featureId;
    }

    @JsonProperty("feature_id")
    public void setFeatureId(String featureId) {
        this.featureId = featureId;
    }

    public SolrGenomeFeatureData withFeatureId(String featureId) {
        this.featureId = featureId;
        return this;
    }

    @JsonProperty("ws_ref")
    public String getWsRef() {
        return wsRef;
    }

    @JsonProperty("ws_ref")
    public void setWsRef(String wsRef) {
        this.wsRef = wsRef;
    }

    public SolrGenomeFeatureData withWsRef(String wsRef) {
        this.wsRef = wsRef;
        return this;
    }

    @JsonProperty("feature_type")
    public String getFeatureType() {
        return featureType;
    }

    @JsonProperty("feature_type")
    public void setFeatureType(String featureType) {
        this.featureType = featureType;
    }

    public SolrGenomeFeatureData withFeatureType(String featureType) {
        this.featureType = featureType;
        return this;
    }

    @JsonProperty("aliases")
    public String getAliases() {
        return aliases;
    }

    @JsonProperty("aliases")
    public void setAliases(String aliases) {
        this.aliases = aliases;
    }

    public SolrGenomeFeatureData withAliases(String aliases) {
        this.aliases = aliases;
        return this;
    }

    @JsonProperty("scientific_name")
    public String getScientificName() {
        return scientificName;
    }

    @JsonProperty("scientific_name")
    public void setScientificName(String scientificName) {
        this.scientificName = scientificName;
    }

    public SolrGenomeFeatureData withScientificName(String scientificName) {
        this.scientificName = scientificName;
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

    public SolrGenomeFeatureData withDomain(String domain) {
        this.domain = domain;
        return this;
    }

    @JsonProperty("functions")
    public String getFunctions() {
        return functions;
    }

    @JsonProperty("functions")
    public void setFunctions(String functions) {
        this.functions = functions;
    }

    public SolrGenomeFeatureData withFunctions(String functions) {
        this.functions = functions;
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

    public SolrGenomeFeatureData withGenomeSource(String genomeSource) {
        this.genomeSource = genomeSource;
        return this;
    }

    @JsonProperty("go_ontology_description")
    public String getGoOntologyDescription() {
        return goOntologyDescription;
    }

    @JsonProperty("go_ontology_description")
    public void setGoOntologyDescription(String goOntologyDescription) {
        this.goOntologyDescription = goOntologyDescription;
    }

    public SolrGenomeFeatureData withGoOntologyDescription(String goOntologyDescription) {
        this.goOntologyDescription = goOntologyDescription;
        return this;
    }

    @JsonProperty("go_ontology_domain")
    public String getGoOntologyDomain() {
        return goOntologyDomain;
    }

    @JsonProperty("go_ontology_domain")
    public void setGoOntologyDomain(String goOntologyDomain) {
        this.goOntologyDomain = goOntologyDomain;
    }

    public SolrGenomeFeatureData withGoOntologyDomain(String goOntologyDomain) {
        this.goOntologyDomain = goOntologyDomain;
        return this;
    }

    @JsonProperty("gene_name")
    public String getGeneName() {
        return geneName;
    }

    @JsonProperty("gene_name")
    public void setGeneName(String geneName) {
        this.geneName = geneName;
    }

    public SolrGenomeFeatureData withGeneName(String geneName) {
        this.geneName = geneName;
        return this;
    }

    @JsonProperty("object_name")
    public String getObjectName() {
        return objectName;
    }

    @JsonProperty("object_name")
    public void setObjectName(String objectName) {
        this.objectName = objectName;
    }

    public SolrGenomeFeatureData withObjectName(String objectName) {
        this.objectName = objectName;
        return this;
    }

    @JsonProperty("location_contig")
    public String getLocationContig() {
        return locationContig;
    }

    @JsonProperty("location_contig")
    public void setLocationContig(String locationContig) {
        this.locationContig = locationContig;
    }

    public SolrGenomeFeatureData withLocationContig(String locationContig) {
        this.locationContig = locationContig;
        return this;
    }

    @JsonProperty("location_strand")
    public String getLocationStrand() {
        return locationStrand;
    }

    @JsonProperty("location_strand")
    public void setLocationStrand(String locationStrand) {
        this.locationStrand = locationStrand;
    }

    public SolrGenomeFeatureData withLocationStrand(String locationStrand) {
        this.locationStrand = locationStrand;
        return this;
    }

    @JsonProperty("taxonomy")
    public String getTaxonomy() {
        return taxonomy;
    }

    @JsonProperty("taxonomy")
    public void setTaxonomy(String taxonomy) {
        this.taxonomy = taxonomy;
    }

    public SolrGenomeFeatureData withTaxonomy(String taxonomy) {
        this.taxonomy = taxonomy;
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

    public SolrGenomeFeatureData withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
        return this;
    }

    @JsonProperty("genetic_code")
    public String getGeneticCode() {
        return geneticCode;
    }

    @JsonProperty("genetic_code")
    public void setGeneticCode(String geneticCode) {
        this.geneticCode = geneticCode;
    }

    public SolrGenomeFeatureData withGeneticCode(String geneticCode) {
        this.geneticCode = geneticCode;
        return this;
    }

    @JsonProperty("md5")
    public String getMd5() {
        return md5;
    }

    @JsonProperty("md5")
    public void setMd5(String md5) {
        this.md5 = md5;
    }

    public SolrGenomeFeatureData withMd5(String md5) {
        this.md5 = md5;
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

    public SolrGenomeFeatureData withTaxId(String taxId) {
        this.taxId = taxId;
        return this;
    }

    @JsonProperty("assembly_ref")
    public String getAssemblyRef() {
        return assemblyRef;
    }

    @JsonProperty("assembly_ref")
    public void setAssemblyRef(String assemblyRef) {
        this.assemblyRef = assemblyRef;
    }

    public SolrGenomeFeatureData withAssemblyRef(String assemblyRef) {
        this.assemblyRef = assemblyRef;
        return this;
    }

    @JsonProperty("taxonomy_ref")
    public String getTaxonomyRef() {
        return taxonomyRef;
    }

    @JsonProperty("taxonomy_ref")
    public void setTaxonomyRef(String taxonomyRef) {
        this.taxonomyRef = taxonomyRef;
    }

    public SolrGenomeFeatureData withTaxonomyRef(String taxonomyRef) {
        this.taxonomyRef = taxonomyRef;
        return this;
    }

    @JsonProperty("ontology_namespaces")
    public String getOntologyNamespaces() {
        return ontologyNamespaces;
    }

    @JsonProperty("ontology_namespaces")
    public void setOntologyNamespaces(String ontologyNamespaces) {
        this.ontologyNamespaces = ontologyNamespaces;
    }

    public SolrGenomeFeatureData withOntologyNamespaces(String ontologyNamespaces) {
        this.ontologyNamespaces = ontologyNamespaces;
        return this;
    }

    @JsonProperty("ontology_ids")
    public String getOntologyIds() {
        return ontologyIds;
    }

    @JsonProperty("ontology_ids")
    public void setOntologyIds(String ontologyIds) {
        this.ontologyIds = ontologyIds;
    }

    public SolrGenomeFeatureData withOntologyIds(String ontologyIds) {
        this.ontologyIds = ontologyIds;
        return this;
    }

    @JsonProperty("ontology_names")
    public String getOntologyNames() {
        return ontologyNames;
    }

    @JsonProperty("ontology_names")
    public void setOntologyNames(String ontologyNames) {
        this.ontologyNames = ontologyNames;
    }

    public SolrGenomeFeatureData withOntologyNames(String ontologyNames) {
        this.ontologyNames = ontologyNames;
        return this;
    }

    @JsonProperty("ontology_lineages")
    public String getOntologyLineages() {
        return ontologyLineages;
    }

    @JsonProperty("ontology_lineages")
    public void setOntologyLineages(String ontologyLineages) {
        this.ontologyLineages = ontologyLineages;
    }

    public SolrGenomeFeatureData withOntologyLineages(String ontologyLineages) {
        this.ontologyLineages = ontologyLineages;
        return this;
    }

    @JsonProperty("dna_sequence_length")
    public Long getDnaSequenceLength() {
        return dnaSequenceLength;
    }

    @JsonProperty("dna_sequence_length")
    public void setDnaSequenceLength(Long dnaSequenceLength) {
        this.dnaSequenceLength = dnaSequenceLength;
    }

    public SolrGenomeFeatureData withDnaSequenceLength(Long dnaSequenceLength) {
        this.dnaSequenceLength = dnaSequenceLength;
        return this;
    }

    @JsonProperty("genome_dna_size")
    public Long getGenomeDnaSize() {
        return genomeDnaSize;
    }

    @JsonProperty("genome_dna_size")
    public void setGenomeDnaSize(Long genomeDnaSize) {
        this.genomeDnaSize = genomeDnaSize;
    }

    public SolrGenomeFeatureData withGenomeDnaSize(Long genomeDnaSize) {
        this.genomeDnaSize = genomeDnaSize;
        return this;
    }

    @JsonProperty("location_begin")
    public Long getLocationBegin() {
        return locationBegin;
    }

    @JsonProperty("location_begin")
    public void setLocationBegin(Long locationBegin) {
        this.locationBegin = locationBegin;
    }

    public SolrGenomeFeatureData withLocationBegin(Long locationBegin) {
        this.locationBegin = locationBegin;
        return this;
    }

    @JsonProperty("location_end")
    public Long getLocationEnd() {
        return locationEnd;
    }

    @JsonProperty("location_end")
    public void setLocationEnd(Long locationEnd) {
        this.locationEnd = locationEnd;
    }

    public SolrGenomeFeatureData withLocationEnd(Long locationEnd) {
        this.locationEnd = locationEnd;
        return this;
    }

    @JsonProperty("num_cds")
    public Long getNumCds() {
        return numCds;
    }

    @JsonProperty("num_cds")
    public void setNumCds(Long numCds) {
        this.numCds = numCds;
    }

    public SolrGenomeFeatureData withNumCds(Long numCds) {
        this.numCds = numCds;
        return this;
    }

    @JsonProperty("num_contigs")
    public Long getNumContigs() {
        return numContigs;
    }

    @JsonProperty("num_contigs")
    public void setNumContigs(Long numContigs) {
        this.numContigs = numContigs;
    }

    public SolrGenomeFeatureData withNumContigs(Long numContigs) {
        this.numContigs = numContigs;
        return this;
    }

    @JsonProperty("protein_translation_length")
    public Long getProteinTranslationLength() {
        return proteinTranslationLength;
    }

    @JsonProperty("protein_translation_length")
    public void setProteinTranslationLength(Long proteinTranslationLength) {
        this.proteinTranslationLength = proteinTranslationLength;
    }

    public SolrGenomeFeatureData withProteinTranslationLength(Long proteinTranslationLength) {
        this.proteinTranslationLength = proteinTranslationLength;
        return this;
    }

    @JsonProperty("gc_content")
    public Double getGcContent() {
        return gcContent;
    }

    @JsonProperty("gc_content")
    public void setGcContent(Double gcContent) {
        this.gcContent = gcContent;
    }

    public SolrGenomeFeatureData withGcContent(Double gcContent) {
        this.gcContent = gcContent;
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

    public SolrGenomeFeatureData withComplete(Long complete) {
        this.complete = complete;
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

    public SolrGenomeFeatureData withRefseqCategory(String refseqCategory) {
        this.refseqCategory = refseqCategory;
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

    public SolrGenomeFeatureData withSaveDate(String saveDate) {
        this.saveDate = saveDate;
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
        return ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((("SolrGenomeFeatureData"+" [genomeFeatureId=")+ genomeFeatureId)+", genomeId=")+ genomeId)+", featureId=")+ featureId)+", wsRef=")+ wsRef)+", featureType=")+ featureType)+", aliases=")+ aliases)+", scientificName=")+ scientificName)+", domain=")+ domain)+", functions=")+ functions)+", genomeSource=")+ genomeSource)+", goOntologyDescription=")+ goOntologyDescription)+", goOntologyDomain=")+ goOntologyDomain)+", geneName=")+ geneName)+", objectName=")+ objectName)+", locationContig=")+ locationContig)+", locationStrand=")+ locationStrand)+", taxonomy=")+ taxonomy)+", workspaceName=")+ workspaceName)+", geneticCode=")+ geneticCode)+", md5=")+ md5)+", taxId=")+ taxId)+", assemblyRef=")+ assemblyRef)+", taxonomyRef=")+ taxonomyRef)+", ontologyNamespaces=")+ ontologyNamespaces)+", ontologyIds=")+ ontologyIds)+", ontologyNames=")+ ontologyNames)+", ontologyLineages=")+ ontologyLineages)+", dnaSequenceLength=")+ dnaSequenceLength)+", genomeDnaSize=")+ genomeDnaSize)+", locationBegin=")+ locationBegin)+", locationEnd=")+ locationEnd)+", numCds=")+ numCds)+", numContigs=")+ numContigs)+", proteinTranslationLength=")+ proteinTranslationLength)+", gcContent=")+ gcContent)+", complete=")+ complete)+", refseqCategory=")+ refseqCategory)+", saveDate=")+ saveDate)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
