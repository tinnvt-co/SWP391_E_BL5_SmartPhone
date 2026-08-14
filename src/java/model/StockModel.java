package model;

import java.io.Serializable;

public class StockModel implements Serializable {

    private int variantId;
    private int productId;
    private String productName;
    private String brandName;
    private String categoryName;
    private String memoryLabel;
    private String colorName;
    private String productImage;
    private int stock;
    private int sellingPrice;
    private int importPrice;
    private boolean active;
    private int lowStockThreshold = 5;

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
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

    public String getProductImage() {
        return productImage;
    }

    public void setProductImage(String productImage) {
        this.productImage = productImage;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public int getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(int sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public int getImportPrice() {
        return importPrice;
    }

    public void setImportPrice(int importPrice) {
        this.importPrice = importPrice;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public int getLowStockThreshold() {
        return lowStockThreshold;
    }

    public void setLowStockThreshold(int lowStockThreshold) {
        this.lowStockThreshold = lowStockThreshold;
    }

    public boolean isLowStock() {
        return stock <= lowStockThreshold;
    }

    public boolean isOutOfStock() {
        return stock <= 0;
    }

    public long getStockValue() {
        return (long) stock * importPrice;
    }

    public String getStockStatus() {
        if (stock <= 0) {
            return "OUT";
        }
        if (stock <= lowStockThreshold) {
            return "LOW";
        }
        return "OK";
    }

    public int getMinAmount() {
        return lowStockThreshold;
    }

    public void setMinAmount(int v) {
        this.lowStockThreshold = v;
    }

    public Integer getMaxAmount() {
        return null;
    }
}
