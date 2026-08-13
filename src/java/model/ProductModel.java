package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


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
    private List<ProductVariantModel> variants = new ArrayList<>();
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
    public List<ProductVariantModel> getVariants() { return variants; }
    public void setVariants(List<ProductVariantModel> variants) { this.variants = variants; }
    public List<ProductVariantModel> getMemoryOptions() {
        List<ProductVariantModel> result = new ArrayList<>();
        for (ProductVariantModel variant : variants) {
            boolean exists = result.stream().anyMatch(item -> item.getMemoryKey().equals(variant.getMemoryKey()));
            if (!exists) result.add(variant);
        }
        return result;
    }
    public List<ProductVariantModel> getColorOptions() {
        List<ProductVariantModel> result = new ArrayList<>();
        for (ProductVariantModel variant : variants) {
            boolean exists = result.stream().anyMatch(item -> item.getColorName().equals(variant.getColorName()));
            if (!exists) result.add(variant);
        }
        return result;
    }
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
    public int getInventoryAmount() { return stock; }
    public int getOriginalPrice() {
        int finalPrice = getFinalPrice();
        return finalPrice + (finalPrice * 3 / 100);
    }
    public int getDiscountPercent() { return discount > 0 ? discount : 3; }
    public String getDisplayRating() { return String.format("%.1f", (double) rating); }
    public String getSoldText() {
        if (reviewCount >= 1000) {
            return String.format("%.1fk", reviewCount / 1000.0).replace(".", ",");
        }
        return reviewCount > 0 ? String.valueOf(reviewCount) : "99,2k";
    }
    public String getSecondSpec() {
        if (releaseYear != null && releaseYear >= 2024) {
            return "6.7\"";
        }
        return "6.57\"";
    }
}
