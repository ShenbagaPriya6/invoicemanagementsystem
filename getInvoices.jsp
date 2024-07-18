<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/x-icon" href="https://img.icons8.com/?size=48&id=13222&format=png">
    <title>Invoice Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f8ff;
            margin: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: rgb(248, 249, 250);
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin-top: 20px; /* Adjust spacing between tables */
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #dddddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Invoice Details</h2>
        </div>
        
        <!-- Paid Invoices Table -->
        <div>
            <h3>Paid Invoices</h3>
            <table>
                <tr>
                    <th>Invoice ID</th>
                    <th>Date</th>
                    <th>Customer Name</th>
                    <th>Phone Number</th>
                    <th>Address</th>
                    <th>Total Amount</th>
                </tr>
                <% 
                    Connection conn = null;
                    PreparedStatement stmtInvoicesPaid = null;
                    ResultSet rsInvoicesPaid = null;
                    
                    try {
                        String url = "jdbc:mysql://localhost:3306/invoicemanagement";
                        String username = "root";
                        String password = "SHN2606";

                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(url, username, password);

                        String selectInvoicesQueryPaid = "SELECT * FROM invoice WHERE statusofpayment=?";
                        stmtInvoicesPaid = conn.prepareStatement(selectInvoicesQueryPaid);
                        stmtInvoicesPaid.setString(1, "paid");
                        rsInvoicesPaid = stmtInvoicesPaid.executeQuery();

                        while (rsInvoicesPaid.next()) {
                            String invoiceId = rsInvoicesPaid.getString("invoiceid");
                            java.sql.Date date = rsInvoicesPaid.getDate("date");
                            String customerPhone = rsInvoicesPaid.getString("phonenumber");
                            double discount = rsInvoicesPaid.getDouble("discount");

                            String customerName = "";
                            String address = "";

                            // Retrieve customer details
                            PreparedStatement stmtCustomer = null;
                            ResultSet rsCustomer = null;
                            try {
                                String selectCustomerQuery = "SELECT * FROM customer WHERE phonenumber = ?";
                                stmtCustomer = conn.prepareStatement(selectCustomerQuery);
                                stmtCustomer.setString(1, customerPhone);
                                rsCustomer = stmtCustomer.executeQuery();
                                if (rsCustomer.next()) {
                                    customerName = rsCustomer.getString("customername");
                                    address = rsCustomer.getString("address");
                                }
                            } catch (SQLException ignore) {
                                // Handle appropriately or log
                            } finally {
                                if (rsCustomer != null) rsCustomer.close();
                                if (stmtCustomer != null) stmtCustomer.close();
                            }

                            // Calculate total amount
                            double subtotal = 0;
                            PreparedStatement stmtItems = null;
                            ResultSet rsItems = null;
                            try {
                                String selectItemsQuery = "SELECT * FROM bill_item WHERE invoiceid = ?";
                                stmtItems = conn.prepareStatement(selectItemsQuery);
                                stmtItems.setString(1, invoiceId);
                                rsItems = stmtItems.executeQuery();
                                while (rsItems.next()) {
                                    int quantity = rsItems.getInt("quantity");
                                    double rate = rsItems.getDouble("rate");
                                    double price = quantity * rate;
                                    subtotal += price;
                                }
                            } catch (SQLException ignore) {
                                // Handle appropriately or log
                            } finally {
                                if (rsItems != null) rsItems.close();
                                if (stmtItems != null) stmtItems.close();
                            }

                            double totalAmount = subtotal - subtotal*(discount/100);

                %>
                <tr>
                    <td><%= invoiceId %></td>
                    <td><%= new SimpleDateFormat("dd-MM-yyyy").format(date) %></td>
                    <td><%= customerName %></td>
                    <td><%= customerPhone %></td>
                    <td><%= address %></td>
                    <td>Rs. <%= totalAmount %></td>
                </tr>
                <% 
                        } // end while rsInvoicesPaid.next()

                    } catch (ClassNotFoundException | SQLException e) {
                        out.println("<tr><td colspan='6'>Error occurred: " + e.getMessage() + "</td></tr>");
                        e.printStackTrace();
                    } finally {
                        // Close all resources
                        try {
                            if (rsInvoicesPaid != null) rsInvoicesPaid.close();
                            if (stmtInvoicesPaid != null) stmtInvoicesPaid.close();
                            if (conn != null) conn.close();
                        } catch (SQLException ignore) {
                            // Handle appropriately or log
                        }
                    }
                %>
            </table>
        </div>
        <div>
            <h3>Unpaid Invoices</h3>
            <table>
                <tr>
                    <th>Invoice ID</th>
                    <th>Date</th>
                    <th>Customer Name</th>
                    <th>Phone Number</th>
                    <th>Address</th>
                    <th>Total Amount</th>
                </tr>
                <% 
                    Connection connUnpaid = null;
                    PreparedStatement stmtInvoicesUnpaid = null;
                    ResultSet rsInvoicesUnpaid = null;
                    
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        connUnpaid = DriverManager.getConnection("jdbc:mysql://localhost:3306/invoicemanagement","root", "SHN2606");

                        String selectInvoicesQueryUnpaid = "SELECT * FROM invoice WHERE statusofpayment=?";
                        stmtInvoicesUnpaid = connUnpaid.prepareStatement(selectInvoicesQueryUnpaid);
                        stmtInvoicesUnpaid.setString(1, "unpaid");
                        rsInvoicesUnpaid = stmtInvoicesUnpaid.executeQuery();

                        while (rsInvoicesUnpaid.next()) {
                            String invoiceId = rsInvoicesUnpaid.getString("invoiceid");
                            java.sql.Date date = rsInvoicesUnpaid.getDate("date");
                            String customerPhone = rsInvoicesUnpaid.getString("phonenumber");
                            double discount = rsInvoicesUnpaid.getDouble("discount");

                            String customerName = "";
                            String address = "";

                            // Retrieve customer details
                            PreparedStatement stmtCustomer = null;
                            ResultSet rsCustomer = null;
                            try {
                                String selectCustomerQuery = "SELECT * FROM customer WHERE phonenumber = ?";
                                stmtCustomer = connUnpaid.prepareStatement(selectCustomerQuery);
                                stmtCustomer.setString(1, customerPhone);
                                rsCustomer = stmtCustomer.executeQuery();
                                if (rsCustomer.next()) {
                                    customerName = rsCustomer.getString("customername");
                                    address = rsCustomer.getString("address");
                                }
                            } catch (SQLException ignore) {
                                // Handle appropriately or log
                            } finally {
                                if (rsCustomer != null) rsCustomer.close();
                                if (stmtCustomer != null) stmtCustomer.close();
                            }

                            // Calculate total amount
                            double subtotal = 0;
                            PreparedStatement stmtItems = null;
                            ResultSet rsItems = null;
                            try {
                                String selectItemsQuery = "SELECT * FROM bill_item WHERE invoiceid = ?";
                                stmtItems = connUnpaid.prepareStatement(selectItemsQuery);
                                stmtItems.setString(1, invoiceId);
                                rsItems = stmtItems.executeQuery();
                                while (rsItems.next()) {
                                    int quantity = rsItems.getInt("quantity");
                                    double rate = rsItems.getDouble("rate");
                                    double price = quantity * rate;
                                    subtotal += price;
                                }
                            } catch (SQLException ignore) {
                                // Handle appropriately or log
                            } finally {
                                if (rsItems != null) rsItems.close();
                                if (stmtItems != null) stmtItems.close();
                            }

                            double totalAmount = subtotal- subtotal*( discount/100);

                %>
                <tr>
                    <td><%= invoiceId %></td>
                    <td><%= new SimpleDateFormat("dd-MM-yyyy").format(date) %></td>
                    <td><%= customerName %></td>
                    <td><%= customerPhone %></td>
                    <td><%= address %></td>
                    <td>Rs. <%= totalAmount %></td>
                </tr>
                <% 
                        } // end while rsInvoicesUnpaid.next()

                    } catch (ClassNotFoundException | SQLException e) {
                        out.println("<tr><td colspan='6'>Error occurred: " + e.getMessage() + "</td></tr>");
                        e.printStackTrace();
                    } finally {
                        // Close all resources
                        try {
                            if (rsInvoicesUnpaid != null) rsInvoicesUnpaid.close();
                            if (stmtInvoicesUnpaid != null) stmtInvoicesUnpaid.close();
                            if (connUnpaid != null) connUnpaid.close();
                        } catch (SQLException ignore) {
                            // Handle appropriately or log
                        }
                    }
                %>
            </table>
        </div>
        
    </div>
</body>
</html>
