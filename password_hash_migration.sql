-- Run once on an existing database before deploying password hashing code.
ALTER TABLE `User`
    MODIFY COLUMN `Password` VARCHAR(255) NOT NULL;

-- Existing plaintext passwords remain usable temporarily. After a successful
-- login, UserDAO verifies the legacy value and replaces it with a salted
-- PBKDF2-HMAC-SHA256 hash automatically.
-- To migrate every existing password immediately, build the project and run:
-- java -cp "build/web/WEB-INF/classes;build/web/WEB-INF/lib/*" util.PasswordHashMigration
