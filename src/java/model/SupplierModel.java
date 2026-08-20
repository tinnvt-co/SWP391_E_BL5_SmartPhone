package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SupplierModel {

    private int id;
    private String name;
    private String address;
    private String phone;
    private String description;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String status;
    
    private int productVariantCount;
    private List<Integer> productVariantIds = new ArrayList<>();
    
    public SupplierModel() {
    }

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

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getProductVariantCount() {
        return productVariantCount;
    }

    public void setProductVariantCount(
            int productVariantCount) {

        this.productVariantCount
                = productVariantCount;
    }

    public List<Integer> getProductVariantIds() {
        return productVariantIds;
    }

    public void setProductVariantIds(List<Integer> productVariantIds) {
        this.productVariantIds = productVariantIds;
    }
    
}
