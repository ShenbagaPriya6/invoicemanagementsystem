package com.zoho;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Customer {
    private String phoneNumber;
    private String name;
    private String address;
    private double paid;
    private double unpaid;


    public Customer() {
    }


    public Customer(String phoneNumber, String name, String address) {
        this.phoneNumber = phoneNumber;
        this.name = name;
        this.address = address;
    }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public double getPaid() { return paid; }
    public void setPaid(double paid) { this.paid = paid; }
    public double getUnpaid() { return unpaid; }
    public void setUnpaid(double unpaid) { this.unpaid = unpaid; }

    public void setTotalAmountPaid(double paid) { this.paid = paid; }
    public void setTotalAmountUnpaid(double unpaid) { this.unpaid = unpaid; }
    public String getCustomerName() { return name; }
    public double getTotalAmountPaid() { return paid; }
    public double getTotalAmountUnpaid() { return unpaid; }

    public static Customer getCustomerByPhoneNumber(String phoneNumber) throws SQLException, ClassNotFoundException {
        String query = "SELECT * FROM customer WHERE phonenumber = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, phoneNumber);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Customer customer = new Customer();
                customer.setPhoneNumber(rs.getString("phonenumber"));
                customer.setName(rs.getString("customername"));
                customer.setAddress(rs.getString("address"));
                customer.setPaid(rs.getDouble("paid"));
                customer.setUnpaid(rs.getDouble("unpaid"));
                return customer;
            }
        }
        return null;
    }

    public void updatePayment(double amount, boolean isPaid) throws SQLException, ClassNotFoundException {
        String query = isPaid ? "UPDATE customer SET paid = paid + ? WHERE phonenumber = ?" :
                                "UPDATE customer SET unpaid = unpaid + ? WHERE phonenumber = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setDouble(1, amount);
            stmt.setString(2, this.phoneNumber);
            stmt.executeUpdate();
        }
    }
    
}
