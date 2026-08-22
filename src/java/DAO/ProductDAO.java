package DAO;

import config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import model.CategoryModel;
import model.ProductModel;
import model.ProductVariantModel;

public class ProductDAO {

    private static final String SELECT_PRODUCTS
            = "SELECT p.ID, p.Name, p.Description, p.Release_Year, "
            + "COALESCE((SELECT ROUND(AVG(f.Rating)) FROM Feedback f "
            + "          JOIN ProductVariant pv2 ON pv2.ID = f.ProductVariantID "
            + "          WHERE pv2.ProductID = p.ID), 0) AS Rating, "
            + "p.warranty_months, p.BrandID, b.Name AS BrandName, "
            + "p.Status, p.Created_at, "
            + "COALESCE((SELECT MIN(pv.Selling_price) FROM ProductVariant pv "
            + "WHERE pv.ProductID = p.ID AND pv.Status = 'ACTIVE'), 0) AS Selling_price, "
            + "COALESCE((SELECT MIN(pv.Latest_cost) FROM ProductVariant pv "
            + "WHERE pv.ProductID = p.ID AND pv.Status = 'ACTIVE'), 0) AS Latest_cost, "
            + "COALESCE((SELECT pv.Image FROM ProductVariant pv "
            + "WHERE pv.ProductID = p.ID AND pv.Status = 'ACTIVE' "
            + "ORDER BY pv.ID LIMIT 1), '') AS Image, "
            + "COALESCE((SELECT pv.SKU FROM ProductVariant pv "
            + "WHERE pv.ProductID = p.ID AND pv.Status = 'ACTIVE' "
            + "ORDER BY pv.ID LIMIT 1), '') AS SKU, "
            + "COALESCE((SELECT MAX(d.Rate) FROM Discount_Product dp "
            + "JOIN Discount d ON d.ID = dp.DiscountID "
            + "WHERE dp.ProductID = p.ID "
            + "AND CURRENT_TIMESTAMP BETWEEN d.Start AND d.End), 0) AS Discount, "
            + "COALESCE((SELECT SUM(i.Amount) FROM ProductVariant pv "
            + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
            + "WHERE pv.ProductID = p.ID AND pv.Status = 'ACTIVE'), 0) AS Stock, "
            + "(SELECT COUNT(*) FROM Feedback f "
            + "JOIN ProductVariant pv ON pv.ID = f.ProductVariantID "
            + "WHERE pv.ProductID = p.ID) AS ReviewCount "
            + "FROM Product p "
            + "JOIN Brand b ON b.ID = p.BrandID ";

    private static final String LOWEST_PRICE_SQL
            = "(SELECT MIN(pvf.Selling_price) FROM ProductVariant pvf "
            + "WHERE pvf.ProductID = p.ID AND pvf.Status = 'ACTIVE')";

    public List<ProductModel> findAll(String keyword, Integer brandId,
            Integer categoryId, String sort, boolean publicOnly) throws SQLException {
        return findAll(keyword, brandId, categoryId, null, sort,
                publicOnly, null, 0, 0);
    }

    public List<ProductModel> findAll(String keyword, Integer brandId,
            Integer categoryId, String sort, boolean publicOnly, int limit, int offset)
            throws SQLException {
        return findAll(keyword, brandId, categoryId, null, sort,
                publicOnly, null, limit, offset);
    }

    public List<ProductModel> findAll(String keyword, Integer brandId,
            Integer categoryId, String sort, boolean publicOnly,
            Collection<Integer> excludeIds) throws SQLException {
        return findAll(keyword, brandId, categoryId, null, sort,
                publicOnly, excludeIds, 0, 0);
    }

    public List<ProductModel> findAll(String keyword, Integer brandId,
            Integer categoryId, String priceRange, String sort, boolean publicOnly,
            int limit, int offset) throws SQLException {
        return findAll(keyword, brandId, categoryId, priceRange, sort,
                publicOnly, null, limit, offset);
    }

    private List<ProductModel> findAll(String keyword, Integer brandId,
            Integer categoryId, String priceRange, String sort, boolean publicOnly,
            Collection<Integer> excludeIds, int limit, int offset)
            throws SQLException {
        StringBuilder sql = new StringBuilder(SELECT_PRODUCTS);
        sql.append("WHERE 1 = 1 ");

        List<Object> parameters = new ArrayList<>();

        if (publicOnly) {
            sql.append("AND p.Status = 'ACTIVE' ");
            sql.append("AND b.Status = 'ACTIVE' ");
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND p.Name LIKE ? ESCAPE '\\\\' ");
            parameters.add("%" + escapeLike(keyword.trim()) + "%");
        }

        if (brandId != null) {
            sql.append("AND p.BrandID = ? ");
            parameters.add(brandId);
        }

        if (categoryId != null) {
            sql.append("AND EXISTS (SELECT 1 FROM Product_Category pcf "
                    + "JOIN Category cf ON cf.ID = pcf.CategoryID "
                    + "WHERE pcf.ProductID = p.ID AND pcf.CategoryID = ? ");
            if (publicOnly) {
                sql.append("AND cf.Status = 'ACTIVE' ");
            }
            sql.append(") ");
            parameters.add(categoryId);
        }

        appendPriceFilter(sql, parameters, priceRange);

        if (excludeIds != null && !excludeIds.isEmpty()) {
            sql.append("AND p.ID NOT IN (");
            for (int i = 0; i < excludeIds.size(); i++) {
                sql.append(i == 0 ? "?" : ",?");
            }
            sql.append(") ");
            parameters.addAll(excludeIds);
        }

        sql.append(getOrderBy(sort));
        if (limit > 0) {
            sql.append(" LIMIT ? OFFSET ?");
            parameters.add(limit);
            parameters.add(Math.max(0, offset));
        }

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {

            for (int index = 0; index < parameters.size(); index++) {
                statement.setObject(index + 1, parameters.get(index));
            }

            List<ProductModel> products = new ArrayList<>();
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    products.add(mapProduct(resultSet));
                }
            }

            loadVariants(connection, products);
            loadCategories(connection, products);
            return products;
        }
    }

    public int countAll(String keyword, Integer brandId,
            Integer categoryId, boolean publicOnly) throws SQLException {
        return countAll(keyword, brandId, categoryId, null, publicOnly);
    }

    public int countAll(String keyword, Integer brandId,
            Integer categoryId, String priceRange, boolean publicOnly) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Product p "
                + "JOIN Brand b ON b.ID = p.BrandID "
                + "WHERE 1 = 1 ");

        List<Object> parameters = new ArrayList<>();

        if (publicOnly) {
            sql.append("AND p.Status = 'ACTIVE' ");
            sql.append("AND b.Status = 'ACTIVE' ");
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append("AND p.Name LIKE ? ESCAPE '\\\\' ");
            parameters.add("%" + escapeLike(keyword.trim()) + "%");
        }

        if (brandId != null) {
            sql.append("AND p.BrandID = ? ");
            parameters.add(brandId);
        }

        if (categoryId != null) {
            sql.append("AND EXISTS (SELECT 1 FROM Product_Category pcf "
                    + "JOIN Category cf ON cf.ID = pcf.CategoryID "
                    + "WHERE pcf.ProductID = p.ID AND pcf.CategoryID = ? ");
            if (publicOnly) {
                sql.append("AND cf.Status = 'ACTIVE' ");
            }
            sql.append(") ");
            parameters.add(categoryId);
        }

        appendPriceFilter(sql, parameters, priceRange);

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int index = 0; index < parameters.size(); index++) {
                statement.setObject(index + 1, parameters.get(index));
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1);
            }
        }
    }

    public ProductModel findById(int id) throws SQLException {
        String sql = SELECT_PRODUCTS + "WHERE p.ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }

                ProductModel product = mapProduct(resultSet);
                List<ProductModel> products = new ArrayList<>();
                products.add(product);
                loadVariants(connection, products);
                loadCategories(connection, products);
                return product;
            }
        }
    }

    public boolean existsProductName(String name, int excludedProductId)
            throws SQLException {
        String sql = "SELECT 1 FROM Product "
                + "WHERE LOWER(TRIM(Name)) = LOWER(?) AND ID <> ? LIMIT 1";
        return exists(sql, name.trim(), excludedProductId);
    }

    public boolean existsVariantSku(String sku, int excludedVariantId)
            throws SQLException {
        String sql = "SELECT 1 FROM ProductVariant "
                + "WHERE LOWER(TRIM(SKU)) = LOWER(?) AND ID <> ? LIMIT 1";
        return exists(sql, sku.trim(), excludedVariantId);
    }

    public boolean existsFrontImage(String image, int excludedVariantId)
            throws SQLException {
        String sql = "SELECT 1 FROM ProductVariant "
                + "WHERE LOWER(TRIM(Image)) = LOWER(?) AND ID <> ? LIMIT 1";
        return exists(sql, image.trim(), excludedVariantId);
    }

    public boolean existsVariantOption(int productId, int ramGb, int storageGb,
            String colorName, int excludedVariantId) throws SQLException {
        String sql = "SELECT 1 FROM ProductVariant WHERE ProductID = ? "
                + "AND RAM_GB = ? AND Storage_GB = ? "
                + "AND LOWER(TRIM(ColorName)) = LOWER(?) AND ID <> ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            statement.setInt(2, ramGb);
            statement.setInt(3, storageGb);
            statement.setString(4, colorName.trim());
            statement.setInt(5, excludedVariantId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private boolean exists(String sql, String value, int excludedId)
            throws SQLException {
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, value);
            statement.setInt(2, excludedId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public List<ProductModel> findFeaturedProducts(int limit) throws SQLException {
        List<ProductModel> products = findAll(null, null, null, "newest", true);
        return products.size() <= limit
                ? products : new ArrayList<>(products.subList(0, limit));
    }

    public List<ProductModel> findPublicProducts(String keyword, String sort)
            throws SQLException {
        return findAll(keyword, null, null, sort, true);
    }

    public List<CategoryModel> findActiveCategories() throws SQLException {
        String sql = "SELECT c.ID, c.Name, c.Description, c.Status, "
                + "COUNT(DISTINCT p.ID) AS ProductCount FROM Category c "
                + "LEFT JOIN Product_Category pc ON pc.CategoryID = c.ID "
                + "LEFT JOIN Product p ON p.ID = pc.ProductID "
                + "AND p.Status = 'ACTIVE' WHERE c.Status = 'ACTIVE' "
                + "GROUP BY c.ID, c.Name, c.Description, c.Status ORDER BY c.ID";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {
            List<CategoryModel> categories = new ArrayList<>();
            while (resultSet.next()) {
                CategoryModel category = new CategoryModel();
                category.setId(resultSet.getInt("ID"));
                category.setName(resultSet.getString("Name"));
                category.setDescription(resultSet.getString("Description"));
                category.setActive("ACTIVE".equalsIgnoreCase(
                        resultSet.getString("Status")));
                category.setProductCount(resultSet.getInt("ProductCount"));
                categories.add(category);
            }
            return categories;
        }
    }

    public void save(ProductModel product) throws SQLException {
        if (product.getId() == 0) {
            insert(product);
        } else {
            update(product);
        }
    }

    private void insert(ProductModel product) throws SQLException {
        String sql = "INSERT INTO Product "
                + "(Name, Description, Release_Year, Rating, warranty_months, "
                + "BrandID, Status) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                try (PreparedStatement statement = connection.prepareStatement(
                        sql, Statement.RETURN_GENERATED_KEYS)) {
                    setProductParameters(statement, product);
                    statement.executeUpdate();

                    try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                        if (!generatedKeys.next()) {
                            throw new SQLException("Cannot create product ID");
                        }
                        product.setId(generatedKeys.getInt(1));
                    }
                }

                saveCategories(connection, product.getId(), product.getCategoryIds());
                for (ProductVariantModel variant : product.getVariants()) {
                    int variantId = insertVariant(connection, product.getId(), variant);
                    saveInventory(connection, variantId, 0);
                }
                connection.commit();
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    private void update(ProductModel product) throws SQLException {
        String sql = "UPDATE Product SET Name = ?, Description = ?, Release_Year = ?, "
                + "warranty_months = ?, BrandID = ?, Status = ? "
                + "WHERE ID = ?";

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setString(1, product.getName());
                    statement.setString(2, product.getDescription());
                    if (product.getReleaseYear() == null) {
                        statement.setNull(3, Types.INTEGER);
                    } else {
                        statement.setInt(3, product.getReleaseYear());
                    }
                    statement.setInt(4, product.getWarrantyMonths());
                    statement.setInt(5, product.getBrandId());
                    statement.setString(6, product.getStatus());
                    statement.setInt(7, product.getId());
                    statement.executeUpdate();
                }

                saveCategories(connection, product.getId(), product.getCategoryIds());
                List<Integer> savedVariantIds = new ArrayList<>();
                for (ProductVariantModel variant : product.getVariants()) {
                    boolean newVariantCreated = false;
                    if (variant.getId() == 0) {
                        int existingId = findVariantIdByOption(
                                connection, product.getId(), variant);
                        if (existingId == 0) {
                            variant.setId(insertVariant(
                                    connection, product.getId(), variant));
                            newVariantCreated = true;
                        } else {
                            variant.setId(existingId);
                            updateVariant(connection, product.getId(), variant);
                        }
                    } else {
                        updateVariant(connection, product.getId(), variant);
                    }
                    if (newVariantCreated) {
                        saveInventory(connection, variant.getId(), 0);
                    }
                    savedVariantIds.add(variant.getId());
                }
                deactivateMissingVariants(connection, product.getId(), savedVariantIds);
                connection.commit();
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    public void deactivate(int id) throws SQLException {
        String sql = "UPDATE Product SET Status = 'INACTIVE' WHERE ID = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.executeUpdate();
        }
    }

    public int moveProductsToBrand(int brandId, Collection<Integer> productIds)
            throws SQLException {
        if (productIds == null || productIds.isEmpty()) {
            return 0;
        }

        String sql = "UPDATE Product SET BrandID = ? "
                + "WHERE ID = ? AND BrandID <> ?";
        int movedProducts = 0;

        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            connection.setAutoCommit(false);
            try {
                for (Integer productId : new LinkedHashSet<>(productIds)) {
                    if (productId == null || productId <= 0) {
                        continue;
                    }
                    statement.setInt(1, brandId);
                    statement.setInt(2, productId);
                    statement.setInt(3, brandId);
                    statement.addBatch();
                }

                for (int result : statement.executeBatch()) {
                    if (result > 0 || result == Statement.SUCCESS_NO_INFO) {
                        movedProducts++;
                    }
                }
                connection.commit();
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
        return movedProducts;
    }

    public int countActive() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Product WHERE Status = 'ACTIVE'";
        return count(sql);
    }

    public int countActiveProducts() throws SQLException {
        return countActive();
    }

    public int countAvailableProducts() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Product p WHERE p.Status = 'ACTIVE' "
                + "AND COALESCE((SELECT SUM(i.Amount) FROM ProductVariant pv "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
                + "WHERE pv.ProductID = p.ID AND pv.Status = 'ACTIVE'), 0) > 0";
        return count(sql);
    }

    public int countOutOfStock() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Product p "
                + "WHERE COALESCE((SELECT SUM(i.Amount) FROM ProductVariant pv "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
                + "WHERE pv.ProductID = p.ID AND pv.Status = 'ACTIVE'), 0) = 0";
        return count(sql);
    }

    private int count(String sql) throws SQLException {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {
            resultSet.next();
            return resultSet.getInt(1);
        }
    }

    private void setProductParameters(PreparedStatement statement,
            ProductModel product) throws SQLException {
        statement.setString(1, product.getName());
        statement.setString(2, product.getDescription());

        if (product.getReleaseYear() == null) {
            statement.setNull(3, Types.INTEGER);
        } else {
            statement.setInt(3, product.getReleaseYear());
        }

        statement.setInt(4, product.getRating());
        statement.setInt(5, product.getWarrantyMonths());
        statement.setInt(6, product.getBrandId());
        statement.setString(7, product.getStatus());
    }

    private void appendPriceFilter(StringBuilder sql, List<Object> parameters,
            String priceRange) {
        if ("under-5m".equals(priceRange)) {
            sql.append("AND ").append(LOWEST_PRICE_SQL).append(" < ? ");
            parameters.add(5_000_000);
        } else if ("5m-10m".equals(priceRange)) {
            sql.append("AND ").append(LOWEST_PRICE_SQL).append(" >= ? ")
                    .append("AND ").append(LOWEST_PRICE_SQL).append(" < ? ");
            parameters.add(5_000_000);
            parameters.add(10_000_000);
        } else if ("10m-20m".equals(priceRange)) {
            sql.append("AND ").append(LOWEST_PRICE_SQL).append(" >= ? ")
                    .append("AND ").append(LOWEST_PRICE_SQL).append(" < ? ");
            parameters.add(10_000_000);
            parameters.add(20_000_000);
        } else if ("over-20m".equals(priceRange)) {
            sql.append("AND ").append(LOWEST_PRICE_SQL).append(" >= ? ");
            parameters.add(20_000_000);
        }
    }

    private String getOrderBy(String sort) {
        if ("price-asc".equals(sort)) {
            return "ORDER BY Selling_price ASC, p.ID DESC";
        }

        if ("price-desc".equals(sort)) {
            return "ORDER BY Selling_price DESC, p.ID DESC";
        }

        return "ORDER BY p.Created_at DESC, p.ID DESC";
    }

    private String escapeLike(String value) {
        return value.replace("\\", "\\\\")
                .replace("%", "\\%")
                .replace("_", "\\_");
    }

    private void loadVariants(Connection connection, List<ProductModel> products)
            throws SQLException {
        if (products.isEmpty()) {
            return;
        }

        Map<Integer, ProductModel> productsById = new HashMap<>();
        for (ProductModel product : products) {
            productsById.put(product.getId(), product);
        }

        String placeholders = String.join(", ",
                java.util.Collections.nCopies(products.size(), "?"));

        String sql = "SELECT pv.ID, pv.ProductID, pv.RAM_GB, pv.Storage_GB, "
                + "pv.ColorName, pv.SKU, "
                + "pv.Selling_price, pv.Latest_cost, pv.Image, pv.BackImage, "
                + "COALESCE(i.Amount, 0) AS Stock "
                + "FROM ProductVariant pv "
                + "LEFT JOIN Inventory i ON i.ProductVariantID = pv.ID "
                + "WHERE pv.Status = 'ACTIVE' "
                + "AND pv.ProductID IN (" + placeholders + ") "
                + "ORDER BY pv.ProductID, pv.Storage_GB, pv.RAM_GB, pv.ID";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < products.size(); index++) {
                statement.setInt(index + 1, products.get(index).getId());
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    ProductVariantModel variant = mapVariant(resultSet);
                    ProductModel product = productsById.get(variant.getProductId());
                    product.getVariants().add(variant);
                }
            }
        }
    }

    private void loadCategories(Connection connection, List<ProductModel> products)
            throws SQLException {
        if (products.isEmpty()) {
            return;
        }

        Map<Integer, ProductModel> productsById = new HashMap<>();
        for (ProductModel product : products) {
            productsById.put(product.getId(), product);
        }

        String placeholders = String.join(", ",
                java.util.Collections.nCopies(products.size(), "?"));
        String sql = "SELECT pc.ProductID, c.ID, c.Name, c.Description, c.Status "
                + "FROM Product_Category pc JOIN Category c ON c.ID = pc.CategoryID "
                + "WHERE c.Status = 'ACTIVE' AND pc.ProductID IN ("
                + placeholders + ") "
                + "ORDER BY pc.ProductID, c.Name";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < products.size(); index++) {
                statement.setInt(index + 1, products.get(index).getId());
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    CategoryModel category = new CategoryModel();
                    category.setId(resultSet.getInt("ID"));
                    category.setName(resultSet.getString("Name"));
                    category.setDescription(resultSet.getString("Description"));
                    category.setActive("ACTIVE".equalsIgnoreCase(
                            resultSet.getString("Status")));

                    ProductModel product = productsById.get(
                            resultSet.getInt("ProductID"));
                    if (product != null) {
                        product.getCategories().add(category);
                    }
                }
            }
        }
    }

    private void saveCategories(Connection connection, int productId,
            List<Integer> categoryIds) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE FROM Product_Category WHERE ProductID = ?")) {
            statement.setInt(1, productId);
            statement.executeUpdate();
        }

        Set<Integer> uniqueCategoryIds = new LinkedHashSet<>(categoryIds);
        String sql = "INSERT INTO Product_Category (ProductID, CategoryID) "
                + "VALUES (?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (Integer categoryId : uniqueCategoryIds) {
                statement.setInt(1, productId);
                statement.setInt(2, categoryId);
                statement.addBatch();
            }
            statement.executeBatch();
        }
    }

    private ProductVariantModel mapVariant(ResultSet resultSet)
            throws SQLException {
        ProductVariantModel variant = new ProductVariantModel();
        variant.setId(resultSet.getInt("ID"));
        variant.setProductId(resultSet.getInt("ProductID"));
        variant.setRamGb(resultSet.getInt("RAM_GB"));
        variant.setStorageGb(resultSet.getInt("Storage_GB"));
        variant.setColorName(resultSet.getString("ColorName"));
        variant.setSku(resultSet.getString("SKU"));
        variant.setSellingPrice(resultSet.getInt("Selling_price"));
        variant.setLatestCost(resultSet.getInt("Latest_cost"));
        variant.setImage(resultSet.getString("Image"));
        variant.setBackImage(resultSet.getString("BackImage"));
        variant.setStock(resultSet.getInt("Stock"));
        return variant;
    }

    private int insertVariant(Connection connection, int productId,
            ProductVariantModel variant) throws SQLException {
        String sql = "INSERT INTO ProductVariant "
                + "(ProductID, RAM_GB, Storage_GB, ColorName, SKU, "
                + "Selling_price, Latest_cost, Image, BackImage, Status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";

        try (PreparedStatement statement = connection.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, productId);
            statement.setInt(2, variant.getRamGb());
            statement.setInt(3, variant.getStorageGb());
            statement.setString(4, variant.getColorName().trim());
            statement.setString(5, "TMP-" + UUID.randomUUID());
            statement.setInt(6, variant.getSellingPrice());
            statement.setInt(7, 0);
            statement.setString(8, variant.getImage().trim());
            statement.setString(9, variant.getBackImage().trim());
            statement.executeUpdate();

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (!generatedKeys.next()) {
                    throw new SQLException("Cannot create product variant ID");
                }
                int variantId = generatedKeys.getInt(1);
                String generatedSku = "PV-" + productId + "-" + variantId;
                try (PreparedStatement skuStatement = connection.prepareStatement(
                        "UPDATE ProductVariant SET SKU = ? WHERE ID = ?")) {
                    skuStatement.setString(1, generatedSku);
                    skuStatement.setInt(2, variantId);
                    skuStatement.executeUpdate();
                }
                variant.setSku(generatedSku);
                return variantId;
            }
        }
    }

    private void updateVariant(Connection connection, int productId,
            ProductVariantModel variant) throws SQLException {
        String sql = "UPDATE ProductVariant SET RAM_GB = ?, Storage_GB = ?, "
                + "ColorName = ?, Selling_price = ?, Image = ?, BackImage = ?, "
                + "Status = 'ACTIVE' WHERE ID = ? AND ProductID = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, variant.getRamGb());
            statement.setInt(2, variant.getStorageGb());
            statement.setString(3, variant.getColorName().trim());
            statement.setInt(4, variant.getSellingPrice());
            statement.setString(5, variant.getImage().trim());
            statement.setString(6, variant.getBackImage().trim());
            statement.setInt(7, variant.getId());
            statement.setInt(8, productId);
            if (statement.executeUpdate() == 0) {
                throw new SQLException("Product variant does not exist");
            }
        }
    }

    private int findVariantIdByOption(Connection connection, int productId,
            ProductVariantModel variant) throws SQLException {
        String sql = "SELECT ID FROM ProductVariant WHERE ProductID = ? "
                + "AND RAM_GB = ? AND Storage_GB = ? AND ColorName = ? LIMIT 1";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            statement.setInt(2, variant.getRamGb());
            statement.setInt(3, variant.getStorageGb());
            statement.setString(4, variant.getColorName().trim());
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt("ID") : 0;
            }
        }
    }

    private void saveInventory(Connection connection, int variantId, int stock)
            throws SQLException {
        String sql = "INSERT INTO Inventory "
                + "(ProductVariantID, Amount, Min_amount, Max_amount, Status) "
                + "VALUES (?, ?, 0, 100, 'ACTIVE') "
                + "ON DUPLICATE KEY UPDATE Amount = VALUES(Amount), Status = 'ACTIVE'";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);
            statement.setInt(2, stock);
            statement.executeUpdate();
        }
    }

    private void deactivateMissingVariants(Connection connection, int productId,
            List<Integer> savedVariantIds) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "UPDATE ProductVariant SET Status = 'INACTIVE' WHERE ProductID = ?");
        if (!savedVariantIds.isEmpty()) {
            sql.append(" AND ID NOT IN (")
                    .append(String.join(",", java.util.Collections.nCopies(
                            savedVariantIds.size(), "?")))
                    .append(")");
        }

        try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            statement.setInt(1, productId);
            for (int index = 0; index < savedVariantIds.size(); index++) {
                statement.setInt(index + 2, savedVariantIds.get(index));
            }
            statement.executeUpdate();
        }
    }

    private ProductModel mapProduct(ResultSet resultSet) throws SQLException {
        ProductModel product = new ProductModel();
        product.setId(resultSet.getInt("ID"));
        product.setName(resultSet.getString("Name"));
        product.setDescription(resultSet.getString("Description"));

        int releaseYear = resultSet.getInt("Release_Year");
        product.setReleaseYear(resultSet.wasNull() ? null : releaseYear);

        product.setRating(resultSet.getInt("Rating"));
        product.setWarrantyMonths(resultSet.getInt("warranty_months"));
        product.setSku(resultSet.getString("SKU"));
        product.setSellingPrice(resultSet.getInt("Selling_price"));
        product.setLatestCost(resultSet.getInt("Latest_cost"));
        product.setImage(resultSet.getString("Image"));
        product.setDiscount(resultSet.getInt("Discount"));
        product.setBrandId(resultSet.getInt("BrandID"));
        product.setBrandName(resultSet.getString("BrandName"));
        product.setStatus(resultSet.getString("Status"));
        product.setStock(resultSet.getInt("Stock"));
        product.setReviewCount(resultSet.getInt("ReviewCount"));
        return product;
    }
}
