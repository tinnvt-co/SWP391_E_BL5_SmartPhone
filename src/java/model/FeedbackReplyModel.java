package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class FeedbackReplyModel implements Serializable {

    private int id;
    private int feedbackId;
    private String content;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int userId;
    private String userName;
    private String userRole;
    private String userImage;

    public FeedbackReplyModel() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getFeedbackId() { return feedbackId; }
    public void setFeedbackId(int feedbackId) { this.feedbackId = feedbackId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }

    public String getUserImage() { return userImage; }
    public void setUserImage(String userImage) { this.userImage = userImage; }

    public boolean isManager() {
        return "MANAGER".equalsIgnoreCase(userRole) || "ADMIN".equalsIgnoreCase(userRole);
    }

    public boolean isEdited() {
        return updatedAt != null && createdAt != null && updatedAt.getTime() - createdAt.getTime() > 1000;
    }
}
