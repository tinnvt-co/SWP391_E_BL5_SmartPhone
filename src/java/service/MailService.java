package service;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class MailService {

    private final Properties fileProperties = loadFileProperties();
    private final String host = firstNonBlank(
            System.getProperty("smartphone.mail.host"),
            System.getenv("SMARTPHONE_MAIL_HOST"),
            fileProperties.getProperty("smartphone.mail.host"),
            "smtp.gmail.com");
    private final String port = firstNonBlank(
            System.getProperty("smartphone.mail.port"),
            System.getenv("SMARTPHONE_MAIL_PORT"),
            fileProperties.getProperty("smartphone.mail.port"),
            "587");
    private final String username = firstNonBlank(
            System.getProperty("smartphone.mail.user"),
            System.getenv("SMARTPHONE_MAIL_USER"),
            fileProperties.getProperty("smartphone.mail.user"),
            "");
    private final String password = firstNonBlank(
            System.getProperty("smartphone.mail.password"),
            System.getenv("SMARTPHONE_MAIL_PASSWORD"),
            fileProperties.getProperty("smartphone.mail.password"),
            "");
    private final String from = firstNonBlank(
            System.getProperty("smartphone.mail.from"),
            System.getenv("SMARTPHONE_MAIL_FROM"),
            fileProperties.getProperty("smartphone.mail.from"),
            username);

    public void sendPasswordReset(String to, String name, String resetLink)
            throws MessagingException {
        if (username.isBlank() || password.isBlank() || from.isBlank()) {
            throw new MessagingException("SMTP email is not configured.");
        }

        Message message = new MimeMessage(session());
        message.setFrom(new InternetAddress(from, false));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
        message.setSubject("SmartPhone store password reset");
        message.setContent(htmlBody(name, resetLink), "text/html; charset=UTF-8");
        Transport.send(message);
    }

    public void sendRefundPaymentNotification(String to, String name, int refundId,
            int orderId, String amount, String bankName, String accountNumber,
            String accountHolder, String vnpayTransactionNo) throws MessagingException {
        if (username.isBlank() || password.isBlank() || from.isBlank()) {
            throw new MessagingException("SMTP email is not configured.");
        }

        Message message = new MimeMessage(session());
        message.setFrom(new InternetAddress(from, false));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
        message.setSubject("SmartPhone store refund payment confirmation");
        message.setContent(refundHtmlBody(name, refundId, orderId, amount,
                bankName, accountNumber, accountHolder, vnpayTransactionNo),
                "text/html; charset=UTF-8");
        Transport.send(message);
    }

    private Session session() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.ssl.trust", host);

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
    }

    private String htmlBody(String name, String resetLink) {
        String displayName = escape(name == null || name.isBlank() ? "customer" : name);
        String safeLink = escape(resetLink);
        return "<div style=\"font-family:Arial,sans-serif;line-height:1.6;color:#17202a\">"
                + "<h2>Reset your SmartPhone store password</h2>"
                + "<p>Hello " + displayName + ",</p>"
                + "<p>We received a request to reset your password. Click the button below to create a new password.</p>"
                + "<p><a href=\"" + safeLink + "\" style=\"display:inline-block;background:#1665d8;color:#fff;"
                + "padding:12px 18px;border-radius:8px;text-decoration:none;font-weight:700\">Reset password</a></p>"
                + "<p>This link will expire in 30 minutes. If you did not request this, you can ignore this email.</p>"
                + "<p style=\"color:#657486;font-size:13px\">If the button does not work, copy this link:<br>"
                + safeLink + "</p>"
                + "</div>";
    }

    private String refundHtmlBody(String name, int refundId, int orderId,
            String amount, String bankName, String accountNumber,
            String accountHolder, String vnpayTransactionNo) {
        String displayName = escape(name == null || name.isBlank() ? "customer" : name);
        return "<div style=\"font-family:Arial,sans-serif;line-height:1.6;color:#17202a\">"
                + "<h2>Refund payment simulated successfully</h2>"
                + "<p>Hello " + displayName + ",</p>"
                + "<p>Your refund request <b>#" + refundId + "</b> for order <b>#" + orderId
                + "</b> has been approved and processed through VNPay sandbox.</p>"
                + "<table style=\"border-collapse:collapse;width:100%;max-width:560px\">"
                + row("Refund amount", amount)
                + row("Bank", bankName)
                + row("Account number", accountNumber)
                + row("Account holder", accountHolder)
                + row("VNPay transaction", vnpayTransactionNo == null || vnpayTransactionNo.isBlank()
                        ? "Sandbox confirmation" : vnpayTransactionNo)
                + "</table>"
                + "<p style=\"color:#657486;font-size:13px\">This is a sandbox payment notification for the SWP project.</p>"
                + "</div>";
    }

    private String row(String label, String value) {
        return "<tr><td style=\"padding:8px;border:1px solid #e5e7eb;background:#f8fafc\"><b>"
                + escape(label) + "</b></td><td style=\"padding:8px;border:1px solid #e5e7eb\">"
                + escape(value == null ? "" : value) + "</td></tr>";
    }

    private String escape(String value) {
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.trim();
            }
        }
        return "";
    }

    private Properties loadFileProperties() {
        Properties properties = new Properties();
        try (InputStream input = MailService.class.getClassLoader()
                .getResourceAsStream("mail.properties")) {
            if (input != null) {
                properties.load(input);
            }
        } catch (IOException ignored) {
            // Email can still be configured by environment variables or system properties.
        }
        return properties;
    }
}
