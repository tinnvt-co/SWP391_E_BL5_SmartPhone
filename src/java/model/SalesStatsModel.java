package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class SalesStatsModel implements Serializable {
    private String period;
    private BigDecimal revenue;
    private int orderCount;
    private int productSold;
    private Timestamp fromDate;
    private Timestamp toDate;

    public SalesStatsModel() {}
    public SalesStatsModel(String period, BigDecimal revenue, int orderCount, int productSold) {
        this.period = period;
        this.revenue = revenue;
        this.orderCount = orderCount;
        this.productSold = productSold;
    }

    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }
    public BigDecimal getRevenue() { return revenue; }
    public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
    public int getOrderCount() { return orderCount; }
    public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    public int getProductSold() { return productSold; }
    public void setProductSold(int productSold) { this.productSold = productSold; }
    public Timestamp getFromDate() { return fromDate; }
    public void setFromDate(Timestamp fromDate) { this.fromDate = fromDate; }
    public Timestamp getToDate() { return toDate; }
    public void setToDate(Timestamp toDate) { this.toDate = toDate; }
}