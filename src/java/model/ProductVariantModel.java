package model;

import java.io.Serializable;

public class ProductVariantModel implements Serializable {
    private int id;
    private int productId;
    private int ramGb;
    private int storageGb;
    private String colorName;
    private String colorHex;
    private int sellingPrice;
    private String image;
    private int stock;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public int getRamGb() { return ramGb; }
    public void setRamGb(int ramGb) { this.ramGb = ramGb; }
    public int getStorageGb() { return storageGb; }
    public void setStorageGb(int storageGb) { this.storageGb = storageGb; }
    public String getColorName() { return colorName; }
    public void setColorName(String colorName) { this.colorName = colorName; }
    public String getColorHex() { return colorHex; }
    public void setColorHex(String colorHex) { this.colorHex = colorHex; }
    public int getSellingPrice() { return sellingPrice; }
    public void setSellingPrice(int sellingPrice) { this.sellingPrice = sellingPrice; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public String getMemoryKey() { return ramGb + "-" + storageGb; }
    public String getMemoryLabel() { return ramGb + "GB - " + (storageGb == 1024 ? "1TB" : storageGb + "GB"); }
}
