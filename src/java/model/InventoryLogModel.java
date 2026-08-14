package model;

import java.io.Serializable;
import java.util.Date;

public class InventoryLogModel implements Serializable {

    private int id;
    private int variantId;
    private String changeType;   // IN, OUT, ADJUST
    private int quantity;
    private int stockBefore;
    private int stockAfter;
    private String note;
    private Integer createdBy;
    private Date createdAt;

    private String productName;
    private String memoryLabel;
    private String colorName;
    private String createdByName;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getStockBefore() {
        return stockBefore;
    }

    public void setStockBefore(int stockBefore) {
        this.stockBefore = stockBefore;
    }

    public int getStockAfter() {
        return stockAfter;
    }

    public void setStockAfter(int stockAfter) {
        this.stockAfter = stockAfter;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
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

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public String getChangeBadge() {
        if ("IN".equals(changeType)) {
            return "IN";
        }
        if ("OUT".equals(changeType)) {
            return "OUT";
        }
        if ("ADJUST".equals(changeType)) {
            return "ADJ";
        }
        return changeType;
    }

    public int getSignedQuantity() {
        if ("OUT".equals(changeType)) {
            return -quantity;
        }
        return quantity;
    }
}
