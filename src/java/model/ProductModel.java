package model;

import java.io.Serializable;


public class ProductModel implements Serializable {
    private int id;
    private String name;
    private String description;
    private Integer releaseYear;
    private int rating;
    private int warrantyMonths;
    private String barcode;
    private String sku;
    private int sellingPrice;
    private int latestCost;
    private String image;
    private int discount;
    private int categoryId;
    private String categoryName;
    private int brandId;
    private String brandName;
    private String status;
    private int stock;
    private int reviewCount;

    public ProductModel() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getReleaseYear() { return releaseYear; }
    public void setReleaseYear(Integer releaseYear) { this.releaseYear = releaseYear; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public int getWarrantyMonths() { return warrantyMonths; }
    public void setWarrantyMonths(int warrantyMonths) { this.warrantyMonths = warrantyMonths; }
    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public int getSellingPrice() { return sellingPrice; }
    public void setSellingPrice(int sellingPrice) { this.sellingPrice = sellingPrice; }
    public int getLatestCost() { return latestCost; }
    public void setLatestCost(int latestCost) { this.latestCost = latestCost; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public int getDiscount() { return discount; }
    public void setDiscount(int discount) { this.discount = discount; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }
    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public int getReviewCount() { return reviewCount; }
    public void setReviewCount(int reviewCount) { this.reviewCount = reviewCount; }
    public boolean isActive() { return "ACTIVE".equalsIgnoreCase(status); }
    public int getFinalPrice() { return sellingPrice - (sellingPrice * discount / 100); }
    public String getCode() { return String.format("P%03d", id); }
}
