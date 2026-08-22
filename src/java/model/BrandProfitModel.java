package model;

import java.math.BigDecimal;

public class BrandProfitModel {

    private String month;
    private int brandId;
    private String brandName;
    private int soldQuantity;
    private BigDecimal revenue;
    private BigDecimal capital;
    private BigDecimal refund;
    private BigDecimal profit;

    public BrandProfitModel() {
    }

    public BrandProfitModel(String month, int brandId, String brandName, int soldQuantity,
                            BigDecimal revenue, BigDecimal capital, BigDecimal refund, BigDecimal profit) {
        this.month = month;
        this.brandId = brandId;
        this.brandName = brandName;
        this.soldQuantity = soldQuantity;
        this.revenue = revenue;
        this.capital = capital;
        this.refund = refund;
        this.profit = profit;
    }

    public String getMonth() {
        return month;
    }

    public void setMonth(String month) {
        this.month = month;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public int getSoldQuantity() {
        return soldQuantity;
    }

    public void setSoldQuantity(int soldQuantity) {
        this.soldQuantity = soldQuantity;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public void setRevenue(BigDecimal revenue) {
        this.revenue = revenue;
    }

    public BigDecimal getCapital() {
        return capital;
    }

    public void setCapital(BigDecimal capital) {
        this.capital = capital;
    }

    public BigDecimal getRefund() {
        return refund;
    }

    public void setRefund(BigDecimal refund) {
        this.refund = refund;
    }

    public BigDecimal getProfit() {
        return profit;
    }

    public void setProfit(BigDecimal profit) {
        this.profit = profit;
    }
}
