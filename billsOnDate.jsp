<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.zoho.*" %>

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
        }
        .header{
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
        .form-group {
            margin-bottom: 15px;
            background-color: #ffffff; 
            padding: 10px;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);
        }
        label {
            display: block;
            margin-bottom: 5px;
        }
        input[type="text"], input[type="number"], input[type="date"] {
            width: calc(100% - 22px);
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button[type="submit"] {
            background-color: #2b5279;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            display: block;
            margin: 0 auto;
        }
        button[type="submit"]:hover {
            background-color: #122d48;
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Invoice Details</h2>
        </div>
        <form method="get" id="dateRangeForm">
            <div class="form-group">
                <label for="startDate">Start Date:</label>
                <input type="date" id="startDate" name="startDate" required>
            </div>
            <div class="form-group">
                <label for="endDate">End Date:</label>
                <input type="date" id="endDate" name="endDate" required>
            </div>
            <button type="submit">Get Invoices</button>
        </form>
        <div id="dateRangeDetails" class="hidden">
            <% 
                String startDateParam = request.getParameter("startDate");
                String endDateParam = request.getParameter("endDate");
                if (startDateParam != null && endDateParam != null) {
                    Connection conn = null;
                    PreparedStatement stmtInvoices = null;
                    ResultSet rsInvoices = null;
                    try {
                        conn = DBUtil.getConnection();
                        String selectInvoicesQuery = "SELECT * FROM invoice WHERE date BETWEEN ? AND ?";
                        stmtInvoices = conn.prepareStatement(selectInvoicesQuery);
                        stmtInvoices.setString(1, startDateParam);
                        stmtInvoices.setString(2, endDateParam);
                        rsInvoices = stmtInvoices.executeQuery();
            %>
            <table>
                <tr>
                    <th>Invoice ID</th>
                    <th>Date</th>
                    <th>Customer Name</th>
                    <th>Phone Number</th>
                    <th>Address</th>
                    <th>Status</th>
                    <th>Total Amount</th>
                </tr>
                <% 
                    while (rsInvoices.next()) {
                        String invoiceId = rsInvoices.getString("invoiceid");
                        java.util.Date date = rsInvoices.getDate("date");
                        String customerPhone = rsInvoices.getString("phonenumber");
                        double discount = rsInvoices.getDouble("discount");
                        String status = rsInvoices.getString("statusofpayment");


                        String customerName = "";
                        String address = "";
                        Connection conn2 = null;
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
                        } 

                        // Calculate total amount
                        double subtotal = 0;
                        Connection conn3 = null;
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
                        } 
                        double totalAmount = subtotal - (subtotal * (discount / 100));
                %>
                <tr>
                    <td><%= invoiceId %></td>
                    <td><%= date %></td>
                    <td><%= customerName %></td>
                    <td><%= customerPhone %></td>
                    <td><%= address %></td>
                    <td><%= status %></td>
                    <td>Rs. <%= totalAmount %></td>
                </tr>
                <% 
                    } 
                %>
            </table>
            <% 
                    } catch (ClassNotFoundException | SQLException e) {
                        out.println("<h2>Error occurred:</h2>");
                        out.println("<p>" + e.getMessage() + "</p>");
                        e.printStackTrace();
                    } 
                } 
            %>
        </div>
    </div>
    <script>
        window.onload = function() {
            const dateRangeForm = document.getElementById('dateRangeForm');
            const dateRangeDetails = document.getElementById('dateRangeDetails');

            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('startDate') && urlParams.has('endDate')) {
                dateRangeForm.style.display = 'none';
                dateRangeDetails.classList.remove('hidden');
            }
        }
    </script>
</body>
</html>
