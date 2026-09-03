package validation;

import java.text.Normalizer;
import java.util.Locale;
import java.util.ArrayList;
import java.util.List;

public final class ProductBrandValidator {

    // Ngăn tạo object vì lớp này chỉ cung cấp các hàm static phục vụ validation.
    private ProductBrandValidator() {
    }

    // Trả true khi tên product chứa một brand khác nhưng không chứa brand đang chọn.
    public static boolean isMismatch(String productName, String brandName) {
        String detectedBrand = detectBrand(productName);
        return detectedBrand != null
                && !normalize(detectedBrand).equals(normalize(brandName));
    }

    // Trả về brand đầu tiên phát hiện trong tên product, hoặc null nếu không tìm thấy.
    public static String detectBrand(String productName) {
        List<String> detectedBrands = detectBrands(productName);
        return detectedBrands.size() == 1 ? detectedBrands.get(0) : null;
    }

    // Phát hiện tất cả tên brand xuất hiện như một từ hoàn chỉnh trong tên product.
    public static List<String> detectBrands(String productName) {
        String product = normalize(productName);
        List<String> detectedBrands = new ArrayList<>();

        if (containsWord(product, "iphone")) {
            detectedBrands.add("Apple");
        }
        if (containsWord(product, "samsung")
                || containsWord(product, "galaxy")) {
            detectedBrands.add("Samsung");
        }
        if (containsWord(product, "xiaomi")
                || containsWord(product, "redmi")
                || containsWord(product, "poco")) {
            detectedBrands.add("Xiaomi");
        }
        if (containsWord(product, "oppo")) {
            detectedBrands.add("Oppo");
        }
        return detectedBrands;
    }

    // Kiểm tra một từ có xuất hiện độc lập, tránh nhận nhầm brand nằm trong từ dài hơn.
    private static boolean containsWord(String text, String word) {
        return text.matches(".*(^|[^a-z0-9])" + word
                + "([^a-z0-9]|$).*");
    }

    // Chuẩn hóa chữ thường, bỏ dấu và ký tự đặc biệt để so sánh tên ổn định hơn.
    private static String normalize(String value) {
        if (value == null) {
            return "";
        }
        return Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT)
                .trim()
                .replaceAll("\\s+", " ");
    }
}
