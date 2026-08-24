package util;

import java.util.regex.Pattern;

public final class PasswordPolicy {

    public static final int MIN_LENGTH = 6;
    public static final int MAX_LENGTH = 20;
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9\\s])\\S{6,20}$");

    public static boolean hasRequiredCharacterTypes(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }

    private PasswordPolicy() {
    }
}
