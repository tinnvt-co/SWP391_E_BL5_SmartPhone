/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 *
 * @author Admin
 */
public class ProductModel {

    private int id;
    private String name;
    private String description;
    private Integer releaseYear;
    private BigDecimal rating;
    private int warrantyMonths;
    private String barcode;
    private String sku;
    private BigDecimal sellingPrice;
    private BigDecimal latestCost;
    private String image;
    private String categoryName;
    private String brandName;
    private int inventoryAmount;
    private BigDecimal soldAmount;
    private String status;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getReleaseYear() {
        return releaseYear;
    }

    public void setReleaseYear(Integer releaseYear) {
        this.releaseYear = releaseYear;
    }

    public BigDecimal getRating() {
        return rating;
    }

    public void setRating(BigDecimal rating) {
        this.rating = rating;
    }

    public int getWarrantyMonths() {
        return warrantyMonths;
    }

    public void setWarrantyMonths(int warrantyMonths) {
        this.warrantyMonths = warrantyMonths;
    }

    public String getBarcode() {
        return barcode;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public BigDecimal getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(BigDecimal sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public BigDecimal getLatestCost() {
        return latestCost;
    }

    public void setLatestCost(BigDecimal latestCost) {
        this.latestCost = latestCost;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public int getInventoryAmount() {
        return inventoryAmount;
    }

    public void setInventoryAmount(int inventoryAmount) {
        this.inventoryAmount = inventoryAmount;
    }

    public BigDecimal getSoldAmount() {
        return soldAmount;
    }

    public void setSoldAmount(BigDecimal soldAmount) {
        this.soldAmount = soldAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getInitial() {
        if (name == null || name.isBlank()) {
            return "P";
        }
        return name.trim().substring(0, 1).toUpperCase();
    }

    public BigDecimal getOriginalPrice() {
        if (sellingPrice == null) {
            return BigDecimal.ZERO;
        }
        return sellingPrice.multiply(new BigDecimal("1.03")).setScale(0, RoundingMode.HALF_UP);
    }

    public int getDiscountPercent() {
        return 3;
    }

    public String getDisplayRating() {
        return rating == null ? "0.0" : rating.setScale(1, RoundingMode.HALF_UP).toPlainString();
    }

    public String getSoldText() {
        if (soldAmount == null || soldAmount.compareTo(BigDecimal.ZERO) <= 0) {
            return "99,2k";
        }
        if (soldAmount.compareTo(new BigDecimal("1000")) >= 0) {
            BigDecimal thousands = soldAmount.divide(new BigDecimal("1000"), 1, RoundingMode.HALF_UP);
            return thousands.toPlainString().replace(".", ",") + "k";
        }
        return soldAmount.setScale(0, RoundingMode.HALF_UP).toPlainString();
    }

    public String getSecondSpec() {
        if (releaseYear != null && releaseYear >= 2024) {
            return "6.7\"";
        }
        return "6.57\"";
    }
}
