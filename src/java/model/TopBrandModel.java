package model;

import java.math.BigDecimal;

public class TopBrandModel {
    private int brandId;
    private String brandName;
    private int soldQuantity;
    private BigDecimal revenue;
    private int orderCount;

    public TopBrandModel() {}

    public TopBrandModel(int brandId, String brandName, int soldQuantity, BigDecimal revenue, int orderCount) {
        this.brandId = brandId;
        this.brandName = brandName;
        this.soldQuantity = soldQuantity;
        this.revenue = revenue;
        this.orderCount = orderCount;
    }

    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }

    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }

    public int getSoldQuantity() { return soldQuantity; }
    public void setSoldQuantity(int soldQuantity) { this.soldQuantity = soldQuantity; }

    public BigDecimal getRevenue() { return revenue; }
    public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }

    public int getOrderCount() { return orderCount; }
    public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
}
