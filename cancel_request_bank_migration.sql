-- =====================================================
-- Cancel Order Request Flow — extension for paid orders
-- =====================================================
-- Customers cancelling PAID (VNPay) orders now have to
-- supply bank-account info so the manager can refund them
-- through VNPay sandbox, mirroring the refund flow.
-- =====================================================

ALTER TABLE `CancelRequest`
    ADD COLUMN `BankName`           VARCHAR(80)  NULL AFTER `CustomReason`,
    ADD COLUMN `BankAccountNumber`  VARCHAR(40)  NULL AFTER `BankName`,
    ADD COLUMN `BankAccountHolder`  VARCHAR(80)  NULL AFTER `BankAccountNumber`;