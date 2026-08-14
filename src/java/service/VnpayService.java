package service;

import jakarta.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TimeZone;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class VnpayService {

    private final Properties properties = loadProperties();

    public String createPaymentUrl(HttpServletRequest request, int amount,
            String orderInfo) {
        return createPaymentUrl(request, amount, orderInfo, transactionReference());
    }

    public String createPaymentUrl(HttpServletRequest request, int amount,
            String orderInfo, String transactionReference) {
        validateConfigured();

        Map<String, String> params = new TreeMap<>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", required("vnpay.tmnCode"));
        params.put("vnp_Amount", String.valueOf(amount * 100L));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", transactionReference);
        params.put("vnp_OrderInfo", orderInfo);
        params.put("vnp_OrderType", property("vnpay.orderType", "other"));
        params.put("vnp_Locale", property("vnpay.locale", "vn"));
        params.put("vnp_ReturnUrl", required("vnpay.returnUrl"));
        params.put("vnp_IpAddr", clientIp(request));
        params.put("vnp_CreateDate", vnpDate(new Date()));

        String query = queryString(params);
        String secureHash = hmacSha512(required("vnpay.hashSecret"), query);
        return required("vnpay.payUrl") + "?" + query + "&vnp_SecureHash=" + secureHash;
    }

    public boolean isValidReturn(HttpServletRequest request) {
        Map<String, String> params = new TreeMap<>();
        Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            if (name.startsWith("vnp_") && !"vnp_SecureHash".equals(name)
                    && !"vnp_SecureHashType".equals(name)) {
                params.put(name, request.getParameter(name));
            }
        }

        String expected = hmacSha512(required("vnpay.hashSecret"), queryString(params));
        String actual = request.getParameter("vnp_SecureHash");
        return actual != null && actual.equalsIgnoreCase(expected);
    }

    public boolean isSuccess(HttpServletRequest request) {
        return "00".equals(request.getParameter("vnp_ResponseCode"))
                && "00".equals(request.getParameter("vnp_TransactionStatus"));
    }

    private String transactionReference() {
        return "SP" + System.currentTimeMillis();
    }

    private String vnpDate(Date date) {
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmss");
        format.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        return format.format(date);
    }

    private String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",", 2)[0].trim();
        }
        return request.getRemoteAddr();
    }

    private String queryString(Map<String, String> params) {
        List<String> pairs = new ArrayList<>();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            String value = entry.getValue();
            if (value != null && !value.isBlank()) {
                pairs.add(encode(entry.getKey()) + "=" + encode(value));
            }
        }
        return String.join("&", pairs);
    }

    private String encode(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.US_ASCII.toString());
        } catch (UnsupportedEncodingException exception) {
            throw new IllegalStateException(exception);
        }
    }

    private String hmacSha512(String key, String data) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA512");
            hmac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] bytes = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder result = new StringBuilder(bytes.length * 2);
            for (byte item : bytes) {
                result.append(String.format("%02x", item & 0xff));
            }
            return result.toString();
        } catch (Exception exception) {
            throw new IllegalStateException("Cannot sign VNPay request.", exception);
        }
    }

    private void validateConfigured() {
        required("vnpay.payUrl");
        required("vnpay.returnUrl");
        required("vnpay.tmnCode");
        required("vnpay.hashSecret");
    }

    private String required(String key) {
        String value = property(key, "");
        if (value.isBlank() || value.startsWith("YOUR_")) {
            throw new IllegalStateException("Missing VNPay config: " + key);
        }
        return value;
    }

    private String property(String key, String fallback) {
        String system = System.getProperty(key);
        if (system != null && !system.isBlank()) {
            return system.trim();
        }
        String env = System.getenv(key.toUpperCase().replace('.', '_'));
        if (env != null && !env.isBlank()) {
            return env.trim();
        }
        return properties.getProperty(key, fallback).trim();
    }

    private Properties loadProperties() {
        Properties result = new Properties();
        try (var input = Thread.currentThread().getContextClassLoader()
                .getResourceAsStream("vnpay.properties")) {
            if (input != null) {
                result.load(input);
            }
            return result;
        } catch (Exception exception) {
            return result;
        }
    }
}
