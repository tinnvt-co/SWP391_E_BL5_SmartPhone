package model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Represents a support conversation between a customer and staff/manager.
 * A customer can have at most one OPEN conversation at a time.
 */
public class ConversationModel implements Serializable {

    public static final String STATUS_OPEN = "OPEN";
    public static final String STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String STATUS_CLOSED = "CLOSED";

    private int id;
    private int userId;
    private String userName;
    private String userEmail;
    private String status;
    private String lastMessage;
    private Timestamp lastMessageAt;
    private Integer assignedTo;
    private String assignedToName;
    private Integer closedBy;
    private Timestamp closedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public ConversationModel() {}

    public ConversationModel(int id, int userId, String status) {
        this.id = id;
        this.userId = userId;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public Timestamp getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(Timestamp lastMessageAt) { this.lastMessageAt = lastMessageAt; }

    public Integer getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Integer assignedTo) { this.assignedTo = assignedTo; }

    public String getAssignedToName() { return assignedToName; }
    public void setAssignedToName(String assignedToName) { this.assignedToName = assignedToName; }

    public Integer getClosedBy() { return closedBy; }
    public void setClosedBy(Integer closedBy) { this.closedBy = closedBy; }

    public Timestamp getClosedAt() { return closedAt; }
    public void setClosedAt(Timestamp closedAt) { this.closedAt = closedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public boolean isOpen() { return STATUS_OPEN.equals(status) || STATUS_IN_PROGRESS.equals(status); }
    public boolean isClosed() { return STATUS_CLOSED.equals(status); }
}
