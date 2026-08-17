package model;

import java.io.Serializable;
import java.math.BigDecimal;

public class OrderItemModel implements Serializable {

    private int transactionId;
    private int variantId;
    private int amount;
    private BigDecimal unitPrice;
    private BigDecimal discountRate;
    private BigDecimal discountAmount;
    private BigDecimal total;
    private String productName;
    private String productImage;
    private String brandName;
    private String memoryLabel;
    private String colorName;

    public OrderItemModel() {
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getDiscountRate() {
        return discountRate;
    }

    public void setDiscountRate(BigDecimal discountRate) {
        this.discountRate = discountRate;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductImage() {
        return productImage;
    }

    public void setProductImage(String productImage) {
        this.productImage = productImage;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getMemoryLabel() {
        return memoryLabel;
    }

    public void setMemoryLabel(String memoryLabel) {
        this.memoryLabel = memoryLabel;
    }

    public String getColorName() {
        return colorName;
    }

    public void setColorName(String colorName) {
        this.colorName = colorName;
    }

    public String getVariantLabel() {
        StringBuilder sb = new StringBuilder();
        if (memoryLabel != null && !memoryLabel.isBlank()) {
            sb.append(memoryLabel);
        }
        if (colorName != null && !colorName.isBlank()) {
            if (sb.length() > 0) {
                sb.append(" • ");
            }
            sb.append(colorName);
        }
        return sb.toString();
    }
}
