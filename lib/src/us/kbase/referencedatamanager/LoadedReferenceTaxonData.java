
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
 * <p>Original spec-file type: LoadedReferenceTaxonData</p>
 * <pre>
 * Struct containing data for a single output by the list_loaded_taxa function
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "taxon",
    "ws_ref"
})
public class LoadedReferenceTaxonData {

    /**
     * <p>Original spec-file type: KBaseReferenceTaxonData</p>
     * <pre>
     * Struct containing data for a single taxon element output by the list_loaded_taxa function
     * </pre>
     * 
     */
    @JsonProperty("taxon")
    private KBaseReferenceTaxonData taxon;
    @JsonProperty("ws_ref")
    private String wsRef;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    /**
     * <p>Original spec-file type: KBaseReferenceTaxonData</p>
     * <pre>
     * Struct containing data for a single taxon element output by the list_loaded_taxa function
     * </pre>
     * 
     */
    @JsonProperty("taxon")
    public KBaseReferenceTaxonData getTaxon() {
        return taxon;
    }

    /**
     * <p>Original spec-file type: KBaseReferenceTaxonData</p>
     * <pre>
     * Struct containing data for a single taxon element output by the list_loaded_taxa function
     * </pre>
     * 
     */
    @JsonProperty("taxon")
    public void setTaxon(KBaseReferenceTaxonData taxon) {
        this.taxon = taxon;
    }

    public LoadedReferenceTaxonData withTaxon(KBaseReferenceTaxonData taxon) {
        this.taxon = taxon;
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

    public LoadedReferenceTaxonData withWsRef(String wsRef) {
        this.wsRef = wsRef;
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
        return ((((((("LoadedReferenceTaxonData"+" [taxon=")+ taxon)+", wsRef=")+ wsRef)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
