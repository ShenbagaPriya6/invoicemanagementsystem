package com.zoho;

import java.sql.*;

public class Stock {
    private String itemName;
    private int quantity;
    private double rate;
    public Stock(String itemName, int quantity, double rate) {
        this.itemName = itemName;
        this.quantity = quantity;
        this.rate = rate;
    }
    public String getItemName() {
        return itemName;
    }
    public void setItemName(String itemName) {
        this.itemName = itemName;
    }
    public int getQuantity() {
        return quantity;
    }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    public double getRate() {
        return rate;
    }
    public void setRate(double rate) {
        this.rate = rate;
    }

    public static boolean isItemAvailable(String itemName, int quantity) throws SQLException, ClassNotFoundException {
        String query = "SELECT quantity FROM instock WHERE itemname = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, itemName);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int availableQuantity = rs.getInt("quantity");
                return availableQuantity >= quantity;
            }
        }
        return false;
    }

    public static void updateStock(String itemName, int quantity) throws SQLException, ClassNotFoundException {
        String query = "UPDATE instock SET quantity = quantity - ? WHERE itemname = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, quantity);
            stmt.setString(2, itemName);
            stmt.executeUpdate();
        }
    }

    public static boolean addStock(String itemName, int quantity, double rate) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        PreparedStatement stmtCheckItem = null;
        PreparedStatement stmtUpdateStock = null;
        PreparedStatement stmtInsertItem = null;

        try {
            conn = DBUtil.getConnection();

            String checkItemQuery = "SELECT * FROM instock WHERE itemname = ?";
            stmtCheckItem = conn.prepareStatement(checkItemQuery);
            stmtCheckItem.setString(1, itemName);
            ResultSet rsItem = stmtCheckItem.executeQuery();

            if (rsItem.next()) {
                String query = "UPDATE instock SET quantity = quantity + ?, rate = ? WHERE itemname = ?";
                stmtUpdateStock = conn.prepareStatement(query);
                stmtUpdateStock.setInt(1, quantity);
                stmtUpdateStock.setDouble(2, rate);
                stmtUpdateStock.setString(3, itemName);
                int rowsUpdated = stmtUpdateStock.executeUpdate();
                return rowsUpdated > 0;

            } else {
                String insertItemQuery = "INSERT INTO instock (itemname, quantity, rate) VALUES (?, ?, ?)";
                stmtInsertItem = conn.prepareStatement(insertItemQuery);
                stmtInsertItem.setString(1, itemName);
                stmtInsertItem.setInt(2, quantity);
                stmtInsertItem.setDouble(3, rate);
                int rowsInserted = stmtInsertItem.executeUpdate();
                return rowsInserted > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }
}
