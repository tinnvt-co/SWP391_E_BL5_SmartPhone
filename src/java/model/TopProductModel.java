package model;

import java.io.Serializable;
import java.math.BigDecimal;

public class TopProductModel implements Serializable {

    private int productId;
    private int variantId;
    private String productName;
    private String variantLabel;
    private String brandName;
    private int soldQuantity;
    private BigDecimal revenue;

    public TopProductModel() {
    }

    public TopProductModel(int productId, int variantId, String productName, String variantLabel,
            String brandName, int soldQuantity, BigDecimal revenue) {
        this.productId = productId;
        this.variantId = variantId;
        this.productName = productName;
        this.variantLabel = variantLabel;
        this.brandName = brandName;
        this.soldQuantity = soldQuantity;
        this.revenue = revenue;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getVariantLabel() {
        return variantLabel;
    }

    public void setVariantLabel(String variantLabel) {
        this.variantLabel = variantLabel;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public int getSoldQuantity() {
        return soldQuantity;
    }

    public void setSoldQuantity(int soldQuantity) {
        this.soldQuantity = soldQuantity;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public void setRevenue(BigDecimal revenue) {
        this.revenue = revenue;
    }
}
