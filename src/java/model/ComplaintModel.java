package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Represents a customer complaint filed after an order is delivered.
 * The complaint has a status (OPEN, IN_PROGRESS, RESOLVED, CLOSED, REJECTED)
 * and a resolution (REFUND, REPLACE, OTHER).
 */
public class ComplaintModel implements Serializable {

    public static final String STATUS_OPEN = "OPEN";
    public static final String STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String STATUS_RESOLVED = "RESOLVED";
    public static final String STATUS_CLOSED = "CLOSED";
    public static final String STATUS_REJECTED = "REJECTED";

    public static final String RESOLUTION_REFUND = "REFUND";
    public static final String RESOLUTION_REPLACE = "REPLACE";
    public static final String RESOLUTION_OTHER = "OTHER";

    public static final String CATEGORY_NOT_RECEIVED = "NOT_RECEIVED";
    public static final String CATEGORY_WRONG_ITEM = "WRONG_ITEM";
    public static final String CATEGORY_DAMAGED = "DAMAGED";
    public static final String CATEGORY_DEFECTIVE = "DEFECTIVE";
    public static final String CATEGORY_LATE_DELIVERY = "LATE_DELIVERY";
    public static final String CATEGORY_OTHER = "OTHER";

    private int id;
    private int transactionId;
    private int userId;
    private String category;
    private String customReason;
    private String description;
    private String status;
    private String resolution;
    private String resolutionNote;
    private Integer assignedTo;
    private String assignedToName;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp closedAt;
    private Integer closedBy;
    private String closedByName;

    // Convenience fields populated by JOINs in the DAO.
    private String customerName;
    private String customerUsername;
    private String orderCode;
    private String orderStatus;
    private java.math.BigDecimal orderTotal;
    private int messageCount;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getCustomReason() {
        return customReason;
    }

    public void setCustomReason(String customReason) {
        this.customReason = customReason;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResolution() {
        return resolution;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
    }

    public String getResolutionNote() {
        return resolutionNote;
    }

    public void setResolutionNote(String resolutionNote) {
        this.resolutionNote = resolutionNote;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getAssignedToName() {
        return assignedToName;
    }

    public void setAssignedToName(String assignedToName) {
        this.assignedToName = assignedToName;
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

    public Timestamp getClosedAt() {
        return closedAt;
    }

    public void setClosedAt(Timestamp closedAt) {
        this.closedAt = closedAt;
    }

    public Integer getClosedBy() {
        return closedBy;
    }

    public void setClosedBy(Integer closedBy) {
        this.closedBy = closedBy;
    }

    public String getClosedByName() {
        return closedByName;
    }

    public void setClosedByName(String closedByName) {
        this.closedByName = closedByName;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerUsername() {
        return customerUsername;
    }

    public void setCustomerUsername(String customerUsername) {
        this.customerUsername = customerUsername;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public java.math.BigDecimal getOrderTotal() {
        return orderTotal;
    }

    public void setOrderTotal(java.math.BigDecimal orderTotal) {
        this.orderTotal = orderTotal;
    }

    public int getMessageCount() {
        return messageCount;
    }

    public void setMessageCount(int messageCount) {
        this.messageCount = messageCount;
    }

    public boolean isOpen() {
        return STATUS_OPEN.equalsIgnoreCase(status) || STATUS_IN_PROGRESS.equalsIgnoreCase(status);
    }

    public boolean isClosed() {
        return STATUS_CLOSED.equalsIgnoreCase(status)
                || STATUS_RESOLVED.equalsIgnoreCase(status)
                || STATUS_REJECTED.equalsIgnoreCase(status);
    }

    public String getDisplayCategory() {
        if (category == null) {
            return "";
        }
        switch (category) {
            case CATEGORY_NOT_RECEIVED:
                return "Product not received";
            case CATEGORY_WRONG_ITEM:
                return "Wrong item delivered";
            case CATEGORY_DAMAGED:
                return "Damaged on arrival";
            case CATEGORY_DEFECTIVE:
                return "Defective / not working";
            case CATEGORY_LATE_DELIVERY:
                return "Delivery too late";
            case CATEGORY_OTHER:
                return "Other";
            default:
                return category;
        }
    }

    public String getDisplayStatus() {
        if (status == null) {
            return "";
        }
        switch (status) {
            case STATUS_OPEN:
                return "Open";
            case STATUS_IN_PROGRESS:
                return "In progress";
            case STATUS_RESOLVED:
                return "Resolved";
            case STATUS_CLOSED:
                return "Closed";
            case STATUS_REJECTED:
                return "Rejected";
            default:
                return status;
        }
    }

    public String getDisplayResolution() {
        if (resolution == null) {
            return "";
        }
        switch (resolution) {
            case RESOLUTION_REFUND:
                return "Refund";
            case RESOLUTION_REPLACE:
                return "Replacement";
            case RESOLUTION_OTHER:
                return "Other";
            default:
                return resolution;
        }
    }
}
