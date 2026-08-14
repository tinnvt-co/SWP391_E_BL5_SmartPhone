/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DTO;

import java.math.BigDecimal;

/**
 *
 * @author admin
 */
public class WishlistViewDTO {
    private int UserID;
    private int ProductVariantID;
    private int ProductID;
    private String name;
    private String imageName;
    private BigDecimal sellingPrice;
    private int ram;
    private int storage;

    public WishlistViewDTO() {
    }

    public WishlistViewDTO(int UserID, int ProductVariantID, int ProductIDl, String name, String imageName, BigDecimal sellingPrice, int ram, int storage) {
        this.UserID = UserID;
        this.ProductVariantID = ProductVariantID;
        this.ProductID = ProductIDl;
        this.name = name;
        this.imageName = imageName;
        this.sellingPrice = sellingPrice;
        this.ram = ram;
        this.storage = storage;
    }

    public int getUserID() {
        return UserID;
    }

    public void setUserID(int UserID) {
        this.UserID = UserID;
    }

    public int getProductVariantID() {
        return ProductVariantID;
    }

    public void setProductVariantID(int ProductVariantID) {
        this.ProductVariantID = ProductVariantID;
    }

    public int getProductID() {
        return ProductID;
    }

    public void setProductID(int ProductIDl) {
        this.ProductID = ProductIDl;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getImageName() {
        return imageName;
    }

    public void setImageName(String imageName) {
        this.imageName = imageName;
    }

    public BigDecimal getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(BigDecimal sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public int getRam() {
        return ram;
    }

    public void setRam(int ram) {
        this.ram = ram;
    }

    public int getStorage() {
        return storage;
    }

    public void setStorage(int storage) {
        this.storage = storage;
    }
    
    
}
