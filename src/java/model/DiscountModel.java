package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class DiscountModel implements Serializable {
    private int id;
    private String name;
    private String description;
    private double rate;
    private Timestamp start;
    private Timestamp end;
    private String status;
    private int productCount;
    private boolean active;

    public DiscountModel() {}

    public DiscountModel(int id, String name, String description, double rate,
                         Timestamp start, Timestamp end, String status,
                         int productCount, boolean active) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.rate = rate;
        this.start = start;
        this.end = end;
        this.status = status;
        this.productCount = productCount;
        this.active = active;
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
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getProductCount() { return productCount; }
    public void setProductCount(int productCount) { this.productCount = productCount; }
    public boolean isActive() { return active; }
    public boolean getActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getInitial() {
        return name == null || name.isBlank() ? "?" : name.substring(0, 1).toUpperCase();
    }
}
