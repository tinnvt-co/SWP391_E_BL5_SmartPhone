package DAO;

import config.DBContext;
import model.BrandProfitModel;
import model.ChannelSlice;
import model.SalesStatsModel;
import model.TopBrandModel;
import model.TopProductModel;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SalesStatsDAO {

    public List<BrandProfitModel> getBrandProfitByMonth(java.sql.Timestamp from, java.sql.Timestamp to) throws SQLException {
        // Query: profit by brand by month
        // Revenue: from COMPLETED orders (Type = 'ORDER')
        // Capital: from COMPLETED import transactions (Type = 'IMPORT')
        // Refund: from APPROVED return requests (full refund amount from items)
        String sql = """
            SELECT 
                MonthKey AS Month,
                BrandID,
                BrandName,
                SUM(SoldQty) AS SoldQuantity,
                SUM(Revenue) AS Revenue,
                SUM(Capital) AS Capital,
                SUM(Refund) AS Refund,
                SUM(Revenue) - SUM(Capital) - SUM(Refund) AS Profit
            FROM (
                -- Sales (ORDER transactions)
                SELECT 
                    DATE_FORMAT(t.Created_at, '%Y-%m') AS MonthKey,
                    b.ID AS BrandID,
                    b.Name AS BrandName,
                    COALESCE(SUM(tp.Amount), 0) AS SoldQty,
                    COALESCE(SUM(tp.Total), 0) AS Revenue,
                    0 AS Capital,
                    0 AS Refund
                FROM `Transaction` t
                JOIN Transaction_ProductVariant tp ON tp.TransactionID = t.ID
                JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID
                JOIN Product p ON p.ID = pv.ProductID
                JOIN Brand b ON b.ID = p.BrandID
                WHERE t.Type = 'ORDER' 
                AND t.Status = 'COMPLETED'
                AND t.Created_at BETWEEN ? AND ?
                GROUP BY DATE_FORMAT(t.Created_at, '%Y-%m'), b.ID, b.Name
                
                UNION ALL
                
                -- Capital (IMPORT transactions)
                SELECT 
                    DATE_FORMAT(t.Created_at, '%Y-%m') AS MonthKey,
                    b.ID AS BrandID,
                    b.Name AS BrandName,
                    0 AS SoldQty,
                    0 AS Revenue,
                    COALESCE(SUM(tp.UnitPrice * tp.Amount), 0) AS Capital,
                    0 AS Refund
                FROM `Transaction` t
                JOIN Transaction_ProductVariant tp ON tp.TransactionID = t.ID
                JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID
                JOIN Product p ON p.ID = pv.ProductID
                JOIN Brand b ON b.ID = p.BrandID
                WHERE t.Type = 'IMPORT' AND t.Status = 'COMPLETED'
                AND t.Created_at BETWEEN ? AND ?
                GROUP BY DATE_FORMAT(t.Created_at, '%Y-%m'), b.ID, b.Name
                
                UNION ALL
                
                -- Refund (APPROVED return requests - full refund amount from Transaction_ProductVariant)
                SELECT 
                    DATE_FORMAT(t.Created_at, '%Y-%m') AS MonthKey,
                    b.ID AS BrandID,
                    b.Name AS BrandName,
                    0 AS SoldQty,
                    0 AS Revenue,
                    0 AS Capital,
                    COALESCE(SUM(tp.Total), 0) AS Refund
                FROM `ReturnRequest` r
                JOIN `Transaction` t ON t.ID = r.TransactionID
                JOIN Transaction_ProductVariant tp ON tp.TransactionID = r.TransactionID 
                    AND tp.ProductVariantID IN (SELECT ProductVariantID FROM ReturnRequest_ProductVariant WHERE ReturnRequestID = r.ID)
                JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID
                JOIN Product p ON p.ID = pv.ProductID
                JOIN Brand b ON b.ID = p.BrandID
                WHERE r.Status = 'APPROVED'
                AND t.Created_at BETWEEN ? AND ?
                GROUP BY DATE_FORMAT(t.Created_at, '%Y-%m'), b.ID, b.Name
            ) AS combined
            GROUP BY MonthKey, BrandID, BrandName
            ORDER BY MonthKey DESC, Profit DESC
            """;

        List<BrandProfitModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); 
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            statement.setTimestamp(3, from);
            statement.setTimestamp(4, to);
            statement.setTimestamp(5, from);
            statement.setTimestamp(6, to);
            
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    BrandProfitModel m = new BrandProfitModel();
                    m.setMonth(rs.getString("Month"));
                    m.setBrandId(rs.getInt("BrandID"));
                    m.setBrandName(rs.getString("BrandName"));
                    m.setSoldQuantity(rs.getInt("SoldQuantity"));
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    m.setCapital(rs.getBigDecimal("Capital"));
                    m.setRefund(rs.getBigDecimal("Refund"));
                    m.setProfit(rs.getBigDecimal("Profit"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    public List<BrandProfitModel> getBrandProfitSummary(java.sql.Timestamp from, java.sql.Timestamp to) throws SQLException {
        String sql = """
            SELECT 
                BrandID,
                BrandName,
                SUM(SoldQty) AS SoldQuantity,
                SUM(Revenue) AS Revenue,
                SUM(Capital) AS Capital,
                SUM(Refund) AS Refund,
                SUM(Revenue) - SUM(Capital) - SUM(Refund) AS Profit
            FROM (
                -- Sales (ORDER transactions)
                SELECT 
                    b.ID AS BrandID,
                    b.Name AS BrandName,
                    COALESCE(SUM(tp.Amount), 0) AS SoldQty,
                    COALESCE(SUM(tp.Total), 0) AS Revenue,
                    0 AS Capital,
                    0 AS Refund
                FROM `Transaction` t
                JOIN Transaction_ProductVariant tp ON tp.TransactionID = t.ID
                JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID
                JOIN Product p ON p.ID = pv.ProductID
                JOIN Brand b ON b.ID = p.BrandID
                WHERE t.Type = 'ORDER' 
                AND t.Status = 'COMPLETED'
                AND t.Created_at BETWEEN ? AND ?
                GROUP BY b.ID, b.Name
                
                UNION ALL
                
                -- Capital (IMPORT transactions)
                SELECT 
                    b.ID AS BrandID,
                    b.Name AS BrandName,
                    0 AS SoldQty,
                    0 AS Revenue,
                    COALESCE(SUM(tp.UnitPrice * tp.Amount), 0) AS Capital,
                    0 AS Refund
                FROM `Transaction` t
                JOIN Transaction_ProductVariant tp ON tp.TransactionID = t.ID
                JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID
                JOIN Product p ON p.ID = pv.ProductID
                JOIN Brand b ON b.ID = p.BrandID
                WHERE t.Type = 'IMPORT' 
                AND t.Status = 'COMPLETED'
                AND t.Created_at BETWEEN ? AND ?
                GROUP BY b.ID, b.Name
                
                UNION ALL
                
                -- Refund (APPROVED return requests - full refund amount)
                SELECT 
                    b.ID AS BrandID,
                    b.Name AS BrandName,
                    0 AS SoldQty,
                    0 AS Revenue,
                    0 AS Capital,
                    COALESCE(SUM(tp.Total), 0) AS Refund
                FROM `ReturnRequest` r
                JOIN `Transaction` t ON t.ID = r.TransactionID
                JOIN Transaction_ProductVariant tp ON tp.TransactionID = r.TransactionID 
                    AND tp.ProductVariantID IN (SELECT ProductVariantID FROM ReturnRequest_ProductVariant WHERE ReturnRequestID = r.ID)
                JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID
                JOIN Product p ON p.ID = pv.ProductID
                JOIN Brand b ON b.ID = p.BrandID
                WHERE r.Status = 'APPROVED'
                AND t.Created_at BETWEEN ? AND ?
                GROUP BY b.ID, b.Name
            ) AS combined
            GROUP BY BrandID, BrandName
            ORDER BY Revenue DESC
            """;

        List<BrandProfitModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); 
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            statement.setTimestamp(3, from);
            statement.setTimestamp(4, to);
            statement.setTimestamp(5, from);
            statement.setTimestamp(6, to);
            
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    BrandProfitModel m = new BrandProfitModel();
                    m.setBrandId(rs.getInt("BrandID"));
                    m.setBrandName(rs.getString("BrandName"));
                    m.setSoldQuantity(rs.getInt("SoldQuantity"));
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    m.setCapital(rs.getBigDecimal("Capital"));
                    m.setRefund(rs.getBigDecimal("Refund"));
                    m.setProfit(rs.getBigDecimal("Profit"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    public SalesStatsModel getOverview(java.sql.Timestamp from, java.sql.Timestamp to) throws SQLException {
        String sql = "SELECT "
                + "  COALESCE(SUM(t.Total_price), 0) AS Revenue, "
                + "  COUNT(t.ID) AS OrderCount, "
                + "  COALESCE(SUM(tp.SoldQty), 0) AS ProductSold "
                + "FROM `Transaction` t "
                + "LEFT JOIN (SELECT TransactionID, SUM(Amount) AS SoldQty FROM Transaction_ProductVariant GROUP BY TransactionID) tp "
                + "  ON tp.TransactionID = t.ID "
                + "WHERE t.Type = 'ORDER' "
                + "  AND t.Status = 'COMPLETED' "
                + "  AND t.Created_at BETWEEN ? AND ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    SalesStatsModel m = new SalesStatsModel();
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    m.setOrderCount(rs.getInt("OrderCount"));
                    m.setProductSold(rs.getInt("ProductSold"));
                    return m;
                }
            }
        }
        return new SalesStatsModel();
    }

    public List<SalesStatsModel> getRevenueByDay(java.sql.Timestamp from, java.sql.Timestamp to) throws SQLException {
        String sql = "SELECT DATE(t.Created_at) AS Day, "
                + "  COALESCE(SUM(t.Total_price), 0) AS Revenue, "
                + "  COUNT(t.ID) AS OrderCount, "
                + "  COALESCE(SUM(tp.SoldQty), 0) AS ProductSold "
                + "FROM `Transaction` t "
                + "LEFT JOIN (SELECT TransactionID, SUM(Amount) AS SoldQty FROM Transaction_ProductVariant GROUP BY TransactionID) tp "
                + "  ON tp.TransactionID = t.ID "
                + "WHERE t.Type = 'ORDER' "
                + "  AND t.Status = 'COMPLETED' "
                + "  AND t.Created_at BETWEEN ? AND ? "
                + "GROUP BY DATE(t.Created_at) ORDER BY Day ASC";

        List<SalesStatsModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    java.sql.Date day = rs.getDate("Day");
                    SalesStatsModel m = new SalesStatsModel();
                    m.setPeriod(day != null ? day.toString() : "");
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    m.setOrderCount(rs.getInt("OrderCount"));
                    m.setProductSold(rs.getInt("ProductSold"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    public List<SalesStatsModel> getRevenueByMonth(java.sql.Timestamp from, java.sql.Timestamp to) throws SQLException {
        String sql = "SELECT DATE_FORMAT(t.Created_at, '%Y-%m') AS Month, "
                + "  COALESCE(SUM(t.Total_price), 0) AS Revenue, "
                + "  COUNT(t.ID) AS OrderCount, "
                + "  COALESCE(SUM(tp.SoldQty), 0) AS ProductSold "
                + "FROM `Transaction` t "
                + "LEFT JOIN (SELECT TransactionID, SUM(Amount) AS SoldQty FROM Transaction_ProductVariant GROUP BY TransactionID) tp "
                + "  ON tp.TransactionID = t.ID "
                + "WHERE t.Type = 'ORDER' "
                + "  AND t.Status = 'COMPLETED' "
                + "  AND t.Created_at BETWEEN ? AND ? "
                + "GROUP BY DATE_FORMAT(t.Created_at, '%Y-%m') ORDER BY Month ASC";

        List<SalesStatsModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    SalesStatsModel m = new SalesStatsModel();
                    m.setPeriod(rs.getString("Month"));
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    m.setOrderCount(rs.getInt("OrderCount"));
                    m.setProductSold(rs.getInt("ProductSold"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    public List<TopProductModel> getTopProducts(java.sql.Timestamp from, java.sql.Timestamp to, int limit) throws SQLException {
        String sql = "SELECT p.ID AS ProductID, pv.ID AS VariantID, p.Name AS ProductName, "
                + "  CONCAT_WS(' / ', CONCAT(pv.RAM_GB,'GB RAM'), CONCAT(pv.Storage_GB,'GB'), pv.ColorName) AS VariantLabel, "
                + "  b.Name AS BrandName, "
                + "  SUM(tp.Amount) AS SoldQty, "
                + "  SUM(tp.Total) AS Revenue "
                + "FROM Transaction_ProductVariant tp "
                + "JOIN `Transaction` t ON t.ID = tp.TransactionID "
                + "JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID "
                + "LEFT JOIN Brand b ON b.ID = p.BrandID "
                + "WHERE t.Type = 'ORDER' "
                + "  AND t.Status = 'COMPLETED' "
                + "  AND t.Created_at BETWEEN ? AND ? "
                + "GROUP BY p.ID, pv.ID, p.Name, pv.RAM_GB, pv.Storage_GB, pv.ColorName, b.Name "
                + "ORDER BY SoldQty DESC, Revenue DESC "
                + "LIMIT ?";

        List<TopProductModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            statement.setInt(3, limit);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    TopProductModel m = new TopProductModel();
                    m.setProductId(rs.getInt("ProductID"));
                    m.setVariantId(rs.getInt("VariantID"));
                    m.setProductName(rs.getString("ProductName"));
                    m.setVariantLabel(rs.getString("VariantLabel"));
                    m.setBrandName(rs.getString("BrandName"));
                    m.setSoldQuantity(rs.getInt("SoldQty"));
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    public List<SalesStatsModel> getRevenueByHour(java.sql.Timestamp from, java.sql.Timestamp to) throws SQLException {
        String sql = "SELECT HOUR(t.Created_at) AS Hour, "
                + "  COALESCE(SUM(t.Total_price), 0) AS Revenue, "
                + "  COUNT(t.ID) AS OrderCount, "
                + "  COALESCE(SUM(tp.SoldQty), 0) AS ProductSold "
                + "FROM `Transaction` t "
                + "LEFT JOIN (SELECT TransactionID, SUM(Amount) AS SoldQty FROM Transaction_ProductVariant GROUP BY TransactionID) tp "
                + "  ON tp.TransactionID = t.ID "
                + "WHERE t.Type = 'ORDER' "
                + "  AND t.Status = 'COMPLETED' "
                + "  AND t.Created_at BETWEEN ? AND ? "
                + "GROUP BY HOUR(t.Created_at) ORDER BY Hour ASC";

        List<SalesStatsModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    SalesStatsModel m = new SalesStatsModel();
                    m.setPeriod(String.format("%02d", rs.getInt("Hour")));
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    m.setOrderCount(rs.getInt("OrderCount"));
                    m.setProductSold(rs.getInt("ProductSold"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    public List<ChannelSlice> getRevenueByChannel(java.sql.Timestamp from, java.sql.Timestamp to) throws SQLException {
        String sql = "SELECT t.Type AS Channel, "
                + "  COALESCE(SUM(t.Total_price), 0) AS Revenue, "
                + "  COUNT(t.ID) AS OrderCount "
                + "FROM `Transaction` t "
                + "WHERE t.Type = 'ORDER' "
                + "  AND t.Status = 'COMPLETED' "
                + "  AND t.Created_at BETWEEN ? AND ? "
                + "GROUP BY t.Type "
                + "ORDER BY Revenue DESC";

        List<ChannelSlice> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            try (ResultSet rs = statement.executeQuery()) {
                BigDecimal total = BigDecimal.ZERO;
                List<ChannelSlice> tmp = new ArrayList<>();
                while (rs.next()) {
                    BigDecimal rev = rs.getBigDecimal("Revenue");
                    String ch = rs.getString("Channel");
                    ChannelSlice s = new ChannelSlice(ch != null ? ch : "Unknown", rev != null ? rev : BigDecimal.ZERO, rs.getInt("OrderCount"));
                    tmp.add(s);
                    total = total.add(s.getRevenue());
                }
                for (ChannelSlice s : tmp) {
                    double pct = total.doubleValue() > 0 ? s.getRevenue().doubleValue() * 100.0 / total.doubleValue() : 0;
                    s.setPercentage(Math.round(pct * 10.0) / 10.0);
                    list.add(s);
                }
            }
        }
        return list;
    }

    public List<TopBrandModel> getTopBrands(java.sql.Timestamp from, java.sql.Timestamp to, int limit) throws SQLException {
        String sql = "SELECT b.ID AS BrandID, b.Name AS BrandName, "
                + "  COALESCE(SUM(tp.Amount), 0) AS SoldQty, "
                + "  COALESCE(SUM(tp.Total), 0) AS Revenue, "
                + "  COUNT(DISTINCT t.ID) AS OrderCount "
                + "FROM `Transaction` t "
                + "JOIN Transaction_ProductVariant tp ON tp.TransactionID = t.ID "
                + "JOIN ProductVariant pv ON pv.ID = tp.ProductVariantID "
                + "JOIN Product p ON p.ID = pv.ProductID "
                + "JOIN Brand b ON b.ID = p.BrandID "
                + "WHERE t.Type = 'ORDER' "
                + "  AND t.Status = 'COMPLETED' "
                + "  AND t.Created_at BETWEEN ? AND ? "
                + "GROUP BY b.ID, b.Name "
                + "ORDER BY Revenue DESC, SoldQty DESC "
                + "LIMIT ?";

        List<TopBrandModel> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setTimestamp(1, from);
            statement.setTimestamp(2, to);
            statement.setInt(3, limit);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    TopBrandModel m = new TopBrandModel();
                    m.setBrandId(rs.getInt("BrandID"));
                    m.setBrandName(rs.getString("BrandName"));
                    m.setSoldQuantity(rs.getInt("SoldQty"));
                    m.setRevenue(rs.getBigDecimal("Revenue"));
                    m.setOrderCount(rs.getInt("OrderCount"));
                    list.add(m);
                }
            }
        }
        return list;
    }
}
