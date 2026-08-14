package model;

import java.io.Serializable;

public class CartItemModel implements Serializable {
    private int userId;
    private int productVariantId;
    private int productId;
    private String productName;
    private String brandName;
    private String image;
    private int ramGb;
    private int storageGb;
    private String colorName;
    private int sellingPrice;
    private int amount;
    private int stock;

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getProductVariantId() { return productVariantId; }
    public void setProductVariantId(int productVariantId) { this.productVariantId = productVariantId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public int getRamGb() { return ramGb; }
    public void setRamGb(int ramGb) { this.ramGb = ramGb; }
    public int getStorageGb() { return storageGb; }
    public void setStorageGb(int storageGb) { this.storageGb = storageGb; }
    public String getColorName() { return colorName; }
    public void setColorName(String colorName) { this.colorName = colorName; }
    public int getSellingPrice() { return sellingPrice; }
    public void setSellingPrice(int sellingPrice) { this.sellingPrice = sellingPrice; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    public String getImageUrl() {
        if (image == null || image.isBlank()) {
            return "/assets/images/product-placeholder.svg";
        }
        return "/assets/images/products/" + image;
    }

    public String getStorageLabel() {
        return storageGb == 1024 ? "1TB" : storageGb + "GB";
    }

    public String getVariantLabel() {
        return ramGb + "GB - " + getStorageLabel() + " / " + colorName;
    }

    public int getLineTotal() {
        return sellingPrice * amount;
    }
}
