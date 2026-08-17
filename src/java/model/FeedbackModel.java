package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class FeedbackModel implements Serializable {

    private int id;
    private int rating;
    private String content;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean deleted;
    private int userId;
    private String userName;
    private String userImage;
    private int productVariantId;
    private int transactionId;
    private int productId;
    private String productName;
    private String variantLabel;
    private String variantImage;
    private int replyCount;
    private Timestamp latestReplyAt;

    private static final long EDIT_WINDOW_DAYS = 15;

    public FeedbackModel() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
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

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserImage() {
        return userImage;
    }

    public void setUserImage(String userImage) {
        this.userImage = userImage;
    }

    public int getProductVariantId() {
        return productVariantId;
    }

    public void setProductVariantId(int productVariantId) {
        this.productVariantId = productVariantId;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getVariantLabel() {
        return variantLabel;
    }

    public void setVariantLabel(String variantLabel) {
        this.variantLabel = variantLabel;
    }

    public String getVariantImage() {
        return variantImage;
    }

    public void setVariantImage(String variantImage) {
        this.variantImage = variantImage;
    }

    public int getReplyCount() {
        return replyCount;
    }

    public void setReplyCount(int replyCount) {
        this.replyCount = replyCount;
    }

    public Timestamp getLatestReplyAt() {
        return latestReplyAt;
    }

    public void setLatestReplyAt(Timestamp latestReplyAt) {
        this.latestReplyAt = latestReplyAt;
    }

    /**
     * Returns true while the customer is still within the 15-day edit window.
     * The window is anchored to CreatedAt, not UpdatedAt, so editing does not
     * extend it.
     */
    public boolean isWithinEditWindow() {
        if (createdAt == null) {
            return false;
        }
        long now = System.currentTimeMillis();
        long elapsed = now - createdAt.getTime();
        long windowMs = EDIT_WINDOW_DAYS * 24L * 60L * 60L * 1000L;
        return elapsed <= windowMs;
    }

    public long getEditWindowRemainingDays() {
        if (createdAt == null) {
            return 0;
        }
        long now = System.currentTimeMillis();
        long deadline = createdAt.getTime() + EDIT_WINDOW_DAYS * 24L * 60L * 60L * 1000L;
        long diff = deadline - now;
        if (diff <= 0) {
            return 0;
        }
        return (diff + 24L * 60L * 60L * 1000L - 1) / (24L * 60L * 60L * 1000L);
    }

    public boolean isEdited() {
        return updatedAt != null && createdAt != null && updatedAt.getTime() - createdAt.getTime() > 1000;
    }

    public boolean isManagerReplyAllowed() {
        if (!isEdited()) {
            return false;
        }
        return latestReplyAt == null || updatedAt.after(latestReplyAt);
    }

    public String getRatingStars() {
        int r = Math.max(1, Math.min(5, rating));
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 5; i++) {
            sb.append(i < r ? '\u2605' : '\u2606');
        }
        return sb.toString();
    }
}
