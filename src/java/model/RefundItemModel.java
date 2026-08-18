package model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Lightweight DTO for one item of a return request.
 * ReturnRequest_ProductVariant is the backing table; we add the lookup fields
 * so the JSP can render without extra joins.
 */
public class RefundItemModel implements Serializable {

    private int returnRequestId;
    private int productVariantId;
    private String productName;
    private String variantLabel;
    private String variantImage;
    private Integer amount;
    private BigDecimal unitPrice;

    public RefundItemModel() {
    }

    public int getReturnRequestId() {
        return returnRequestId;
    }

    public void setReturnRequestId(int returnRequestId) {
        this.returnRequestId = returnRequestId;
    }

    public int getProductVariantId() {
        return productVariantId;
    }

    public void setProductVariantId(int productVariantId) {
        this.productVariantId = productVariantId;
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

    public String getVariantImage() {
        return variantImage;
    }

    public void setVariantImage(String variantImage) {
        this.variantImage = variantImage;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
}
