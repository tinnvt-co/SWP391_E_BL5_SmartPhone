package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class VoucherModel {

    private int id;
    private String code;
    private String discountType;
    private BigDecimal value;
    private BigDecimal maxDiscount;
    private BigDecimal minOrderValue;
    private int maxUsesPerUser = 1;
    private Integer usageLimit;
    private int usedCount;
    private Timestamp startDate;
    private Timestamp endDate;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public VoucherModel() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getValue() {
        return value;
    }

    public void setValue(BigDecimal value) {
        this.value = value;
    }

    public BigDecimal getMaxDiscount() {
        return maxDiscount;
    }

    public void setMaxDiscount(BigDecimal maxDiscount) {
        this.maxDiscount = maxDiscount;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public int getMaxUsesPerUser() {
        return maxUsesPerUser;
    }

    public void setMaxUsesPerUser(int maxUsesPerUser) {
        this.maxUsesPerUser = maxUsesPerUser;
    }

    public Integer getUsageLimit() {
        return usageLimit;
    }

    public void setUsageLimit(Integer usageLimit) {
        this.usageLimit = usageLimit;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public boolean isValid() {
        Timestamp now = new Timestamp(System.currentTimeMillis());
        return "ACTIVE".equalsIgnoreCase(this.status)
                && now.after(this.startDate)
                && now.before(this.endDate)
                && (this.usageLimit == null || this.usedCount < this.usageLimit);
    }
}
