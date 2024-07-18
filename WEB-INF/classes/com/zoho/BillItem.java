package com.zoho;
import java.sql.*;

public class BillItem {
    private String invoiceId;
    private String itemName;
    private int quantity;
    private String unit;
    private double rate;


    public String getInvoiceId() { return invoiceId; }
    public void setInvoiceId(String invoiceId) { this.invoiceId = invoiceId; }
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public double getRate() { return rate; }
    public void setRate(double rate) { this.rate = rate; }

    public void save() throws SQLException, ClassNotFoundException {
        String query = "INSERT INTO bill_item (invoiceid, itemname, quantity, unit, rate) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, this.invoiceId);
            stmt.setString(2, this.itemName);
            stmt.setInt(3, this.quantity);
            stmt.setString(4, this.unit);
            stmt.setDouble(5, this.rate);
            stmt.executeUpdate();
        }
    }
}
