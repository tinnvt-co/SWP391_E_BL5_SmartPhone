package model;

import java.math.BigDecimal;

public class ChannelSlice {

    private String channel;
    private BigDecimal revenue;
    private int orderCount;
    private double percentage;

    public ChannelSlice() {
    }

    public ChannelSlice(String channel, BigDecimal revenue, int orderCount) {
        this.channel = channel;
        this.revenue = revenue;
        this.orderCount = orderCount;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public void setRevenue(BigDecimal revenue) {
        this.revenue = revenue;
    }

    public int getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(int orderCount) {
        this.orderCount = orderCount;
    }

    public double getPercentage() {
        return percentage;
    }

    public void setPercentage(double percentage) {
        this.percentage = percentage;
    }
}
