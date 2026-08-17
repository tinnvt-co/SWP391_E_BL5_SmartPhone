package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Customer-facing refund (return) request backed by the `ReturnRequest` table.
 *
 * Lifecycle status values (stored in ReturnRequest.Status): - ACTIVE : customer
 * just submitted, waiting for manager review - APPROVED : manager approved,
 * items will be returned / refunded - REJECTED : manager rejected the refund
 *
 * Customer-side fields (image uploads) reuse the existing ReturnRequest.Image /
 * BackImage columns so we don't have to alter the schema. Only Image is used by
 * the customer flow; BackImage stays reserved for future use.
 */
public class ReturnRequestModel implements Serializable {

    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_APPROVED = "APPROVED";
    public static final String STATUS_REJECTED = "REJECTED";

    private int id;
    private String status;
    private String description;
    private String image;
    private String backImage;
    private Timestamp updatedAt;
    private Timestamp createdAt;
    private int userId;
    private String userName;
    private int transactionId;
    private String reviewedByName;
    private Timestamp reviewedAt;
    private String bankName;
    private String bankAccountNumber;
    private String bankAccountHolder;

    private int itemCount;
    private List<ReturnRequestItemModel> items = new ArrayList<>();

    public ReturnRequestModel() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getBackImage() {
        return backImage;
    }

    public void setBackImage(String backImage) {
        this.backImage = backImage;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
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

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public String getReviewedByName() {
        return reviewedByName;
    }

    public void setReviewedByName(String reviewedByName) {
        this.reviewedByName = reviewedByName;
    }

    public Timestamp getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(Timestamp reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getBankAccountNumber() {
        return bankAccountNumber;
    }

    public void setBankAccountNumber(String bankAccountNumber) {
        this.bankAccountNumber = bankAccountNumber;
    }

    public String getBankAccountHolder() {
        return bankAccountHolder;
    }

    public void setBankAccountHolder(String bankAccountHolder) {
        this.bankAccountHolder = bankAccountHolder;
    }

    public boolean isHasBankInfo() {
        return bankName != null && !bankName.isBlank()
                && bankAccountNumber != null && !bankAccountNumber.isBlank()
                && bankAccountHolder != null && !bankAccountHolder.isBlank();
    }

    public int getItemCount() {
        return itemCount;
    }

    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
    }

    public List<ReturnRequestItemModel> getItems() {
        return items;
    }

    public void setItems(List<ReturnRequestItemModel> items) {
        this.items = items;
    }

    public boolean isPending() {
        return STATUS_ACTIVE.equalsIgnoreCase(status);
    }

    public boolean isApproved() {
        return STATUS_APPROVED.equalsIgnoreCase(status);
    }

    public boolean isRejected() {
        return STATUS_REJECTED.equalsIgnoreCase(status);
    }

    public String getStatusLabel() {
        if (status == null) {
            return "UNKNOWN";
        }
        switch (status.toUpperCase()) {
            case STATUS_ACTIVE:
                return "Pending review";
            case STATUS_APPROVED:
                return "Approved";
            case STATUS_REJECTED:
                return "Rejected";
            default:
                return status;
        }
    }
}
