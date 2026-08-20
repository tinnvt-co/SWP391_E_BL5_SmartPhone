package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class OrderModel implements Serializable {

    private int id;
    private int userId;
    private String username;
    private String userName;
    private String userPhone;
    private String userEmail;
    private BigDecimal totalPrice;
    private BigDecimal paidAmount;
    private BigDecimal changeAmount;
    private String type;
    private String status;
    private String method;
    private Integer supplierId;
    private Integer updatedBy;
    private String updatedByName;
    private Timestamp updatedAt;
    private Timestamp createdAt;
    private Integer referenceTransactionId;
    private Integer deliveryInfoId;
    private String recipientName;
    private String recipientPhone;
    private String deliveryAddress;
    private int itemCount;
    private String note;
    private List<OrderItemModel> items = new ArrayList<>();
    private Boolean hasOpenRefund;
    private Boolean hasBlockingRefund;
    private Boolean hasCancelPending;
    private Integer shipperId;
    private String proofImage;

    public OrderModel() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserPhone() {
        return userPhone;
    }

    public void setUserPhone(String userPhone) {
        this.userPhone = userPhone;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }

    public BigDecimal getPaidAmount() {
        return paidAmount;
    }

    public void setPaidAmount(BigDecimal paidAmount) {
        this.paidAmount = paidAmount;
    }

    public BigDecimal getChangeAmount() {
        return changeAmount;
    }

    public void setChangeAmount(BigDecimal changeAmount) {
        this.changeAmount = changeAmount;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }

    public Integer getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(Integer updatedBy) {
        this.updatedBy = updatedBy;
    }

    public String getUpdatedByName() {
        return updatedByName;
    }

    public void setUpdatedByName(String updatedByName) {
        this.updatedByName = updatedByName;
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

    public Integer getReferenceTransactionId() {
        return referenceTransactionId;
    }

    public void setReferenceTransactionId(Integer referenceTransactionId) {
        this.referenceTransactionId = referenceTransactionId;
    }

    public Integer getDeliveryInfoId() {
        return deliveryInfoId;
    }

    public void setDeliveryInfoId(Integer deliveryInfoId) {
        this.deliveryInfoId = deliveryInfoId;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getRecipientPhone() {
        return recipientPhone;
    }

    public void setRecipientPhone(String recipientPhone) {
        this.recipientPhone = recipientPhone;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public int getItemCount() {
        return itemCount;
    }

    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
    }

    public Boolean getHasOpenRefund() {
        return hasOpenRefund;
    }

    public void setHasOpenRefund(Boolean hasOpenRefund) {
        this.hasOpenRefund = hasOpenRefund;
    }

    public Boolean getHasBlockingRefund() {
        return hasBlockingRefund;
    }

    public void setHasBlockingRefund(Boolean hasBlockingRefund) {
        this.hasBlockingRefund = hasBlockingRefund;
    }

    public Boolean getHasCancelPending() {
        return hasCancelPending;
    }

    public void setHasCancelPending(Boolean hasCancelPending) {
        this.hasCancelPending = hasCancelPending;
    }

    public Integer getShipperId() {
        return shipperId;
    }

    public void setShipperId(Integer shipperId) {
        this.shipperId = shipperId;
    }

    public List<OrderItemModel> getItems() {
        return items;
    }

    public void setItems(List<OrderItemModel> items) {
        this.items = items;
    }

    public BigDecimal getShippingFee() {
        return BigDecimal.ZERO;
    }

    public void setShippingFee(BigDecimal shippingFee) {
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getProofImage() {
        return proofImage;
    }

    public void setProofImage(String proofImage) {
        this.proofImage = proofImage;
    }

    public String getCode() {
        return String.format("ORD%04d", id);
    }

    public boolean isImport() {
        return "IMPORT".equalsIgnoreCase(type);
    }

    public boolean isOrder() {
        return "ORDER".equalsIgnoreCase(type);
    }

    public BigDecimal getTotalDiscount() {
        BigDecimal total = BigDecimal.ZERO;
        if (items != null) {
            for (OrderItemModel it : items) {
                BigDecimal disc = it != null && it.getDiscountAmount() != null ? it.getDiscountAmount() : BigDecimal.ZERO;
                Integer amount = it != null ? it.getAmount() : null;
                int qty = amount != null ? amount : 0;
                total = total.add(disc.multiply(BigDecimal.valueOf(qty)));
            }
        }
        return total;
    }
}
