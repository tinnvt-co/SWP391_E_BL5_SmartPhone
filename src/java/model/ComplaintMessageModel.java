package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Represents a single chatbox message exchanged between a customer and
 * a manager while resolving a complaint.
 */
public class ComplaintMessageModel implements Serializable {

    public static final String ROLE_CUSTOMER = "CUSTOMER";
    public static final String ROLE_MANAGER = "MANAGER";
    public static final String ROLE_STAFF = "STAFF";
    public static final String ROLE_SYSTEM = "SYSTEM";

    private int id;
    private int complaintId;
    private int senderId;
    private String senderRole;
    private String content;
    private Timestamp createdAt;

    // Convenience: sender display name populated by JOIN.
    private String senderName;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getComplaintId() {
        return complaintId;
    }

    public void setComplaintId(int complaintId) {
        this.complaintId = complaintId;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public boolean isFromCustomer() {
        return ROLE_CUSTOMER.equalsIgnoreCase(senderRole);
    }

    public boolean isFromStaffSide() {
        return ROLE_MANAGER.equalsIgnoreCase(senderRole) || ROLE_STAFF.equalsIgnoreCase(senderRole);
    }
}
