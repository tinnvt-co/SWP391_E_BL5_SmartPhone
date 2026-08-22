package model;

import java.sql.Timestamp;

public class UserVoucherModel {

    private int userId;
    private int voucherId;
    private int usedCount;
    private Timestamp savedAt;
    private Timestamp usedAt;
    
    // Additional fields for convenience
    private VoucherModel voucher;

    public UserVoucherModel() {
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public Timestamp getSavedAt() {
        return savedAt;
    }

    public void setSavedAt(Timestamp savedAt) {
        this.savedAt = savedAt;
    }

    public Timestamp getUsedAt() {
        return usedAt;
    }

    public void setUsedAt(Timestamp usedAt) {
        this.usedAt = usedAt;
    }

    public VoucherModel getVoucher() {
        return voucher;
    }

    public void setVoucher(VoucherModel voucher) {
        this.voucher = voucher;
    }
}
