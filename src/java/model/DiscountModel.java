package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class DiscountModel implements Serializable {
    private int id;
    private String name;
    private String description;
    private double rate;
    private Timestamp start;
    private Timestamp end;
    private int productCount;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    /** Product IDs that this discount applies to (empty = applies to all). */
    private List<Integer> productIds = new ArrayList<>();

    public DiscountModel() {}

    public DiscountModel(int id, String name, String description, double rate,
                         Timestamp start, Timestamp end,
                         int productCount) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.rate = rate;
        this.start = start;
        this.end = end;
        this.productCount = productCount;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public double getRate() { return rate; }
    public void setRate(double rate) { this.rate = rate; }
    public Timestamp getStart() { return start; }
    public void setStart(Timestamp start) { this.start = start; }
    public Timestamp getEnd() { return end; }
    public void setEnd(Timestamp end) { this.end = end; }
    public int getProductCount() { return productCount; }
    public void setProductCount(int productCount) { this.productCount = productCount; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public List<Integer> getProductIds() { return productIds; }
    public void setProductIds(List<Integer> productIds) {
        this.productIds = productIds == null ? new ArrayList<>() : productIds;
    }

    public String getInitial() {
        return name == null || name.isBlank() ? "?" : name.substring(0, 1).toUpperCase();
    }

    /**
     * Realtime computed status - no DB column, no manual switch.
     *   now < start  -> Scheduled (chưa tới đợt)
     *   start..end   -> Active    (đang chạy)
     *   now > end    -> Expired   (đã kết thúc)
     */
    public String getComputedStatus() {
        long now = System.currentTimeMillis();
        if (start != null && now < start.getTime()) return "Scheduled";
        if (end != null && now > end.getTime()) return "Expired";
        return "Active";
    }

    public boolean isLiveNow() {
        return "Active".equals(getComputedStatus());
    }

    public String getStatusClass() {
        return switch (getComputedStatus()) {
            case "Active"    -> "status-pill status-active";
            case "Scheduled" -> "status-pill status-scheduled";
            default          -> "status-pill status-expired";
        };
    }
}
