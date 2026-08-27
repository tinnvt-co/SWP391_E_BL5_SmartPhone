package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Represents a single chat message in a support conversation
 * between a customer and staff/manager.
 */
public class ChatMessageModel implements Serializable {

    public static final String ROLE_CUSTOMER = "CUSTOMER";
    public static final String ROLE_STAFF = "STAFF";
    public static final String ROLE_MANAGER = "MANAGER";
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_SYSTEM = "SYSTEM";

    private int id;
    private int conversationId;
    private int senderId;
    private String senderRole;
    private String content;
    private Timestamp createdAt;
    private String senderName;

    public ChatMessageModel() {}

    public ChatMessageModel(int conversationId, int senderId, String senderRole, String content) {
        this.conversationId = conversationId;
        this.senderId = senderId;
        this.senderRole = senderRole;
        this.content = content;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getConversationId() { return conversationId; }
    public void setConversationId(int conversationId) { this.conversationId = conversationId; }

    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }

    public String getSenderRole() { return senderRole; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public boolean isFromCustomer() {
        return ROLE_CUSTOMER.equalsIgnoreCase(senderRole);
    }

    public boolean isFromStaffSide() {
        return ROLE_STAFF.equalsIgnoreCase(senderRole)
                || ROLE_MANAGER.equalsIgnoreCase(senderRole)
                || ROLE_ADMIN.equalsIgnoreCase(senderRole);
    }
}
