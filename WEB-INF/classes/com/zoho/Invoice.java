package com.zoho;

import java.sql.*;
import java.util.*;

public class Invoice {
    private String invoiceId;
    private String customerPhone;
    private String shopName;
    private java.util.Date invoiceDate; 
    private double discount;
    private String status;
    private double totalAmount; // Add this field
    private String shipAddress;

    public Invoice(String invoiceId, String customerPhone, String shopName, java.util.Date invoiceDate, double discount, String status,String shipadd) {
        this.invoiceId = invoiceId;
        this.customerPhone = customerPhone;
        this.shopName = shopName;
        this.invoiceDate = invoiceDate;
        this.discount = discount;
        this.status = status;
        this.shipAddress=shipadd;
    }

    public String getInvoiceId() { return invoiceId; }
    public void setInvoiceId(String invoiceId) { this.invoiceId = invoiceId; }
    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }
    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }
    public java.util.Date getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(java.util.Date invoiceDate) { this.invoiceDate = invoiceDate; }
    public double getDiscount() { return discount; }
    public void setDiscount(double discount) { this.discount = discount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public String getShipAddress() { return shipAddress; }
    public void setShipAddress(String shipAddress) { this.shipAddress = shipAddress; }


    public void save() throws SQLException, ClassNotFoundException {
        String query = "INSERT INTO invoice (invoiceid, phonenumber, statusofpayment, date, discount, shop,address) VALUES (?, ?, ?, ?, ?, ?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, this.invoiceId);
            stmt.setString(2, this.customerPhone);
            stmt.setString(3, this.status);
            stmt.setDate(4, new java.sql.Date(this.invoiceDate.getTime())); 
            stmt.setDouble(5, this.discount);
            stmt.setString(6, this.shopName);
            stmt.setString(7,this.shipAddress);
            stmt.executeUpdate();
        }
    }
}
