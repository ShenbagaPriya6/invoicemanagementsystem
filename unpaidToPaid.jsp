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
    <title>Unpaid to Paid</title>
    <style>
        /* Your existing styles */
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
        input[type="text"], input[type="number"] {
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
            <h2>Update Invoice Payment Status</h2>
        </div>
        <form method="post">
            <div class="form-group">
                <label for="invoiceId">Enter Invoice ID:</label>
                <input type="text" id="invoiceId" name="invoiceId" required>
            </div>
            <div class="form-group">
                <label for="customerName">Customer Name:</label>
                <input type="text" id="customerName" name="customerName" required>
            </div>
            <button type="submit" name="calculateButton">Calculate Amount</button>
        </form>
        <% 
            if (request.getParameter("calculateButton") != null) {
                String invoiceId = request.getParameter("invoiceId");
                String customerName = request.getParameter("customerName");

                Connection conn = null;
                PreparedStatement stmtFetchItems = null;
                ResultSet rsItems = null;

                try {
                    conn = DBUtil.getConnection();

                    // Fetch items related to the invoice
                    String selectItemsQuery = "SELECT * FROM bill_item WHERE invoiceid = ?";
                    stmtFetchItems = conn.prepareStatement(selectItemsQuery);
                    stmtFetchItems.setString(1, invoiceId);
                    rsItems = stmtFetchItems.executeQuery();

                    double totalAmount = 0;
                    while (rsItems.next()) {
                        int quantity = rsItems.getInt("quantity");
                        double rate = rsItems.getDouble("rate");
                        totalAmount += quantity * rate;
                    }
                    // Check if invoice is unpaid
                    String checkInvoiceStatusQuery = "SELECT statusofpayment,discount FROM invoice WHERE invoiceid = ?";
                    PreparedStatement stmtCheckStatus = conn.prepareStatement(checkInvoiceStatusQuery);
                    stmtCheckStatus.setString(1, invoiceId);
                    ResultSet rsStatus = stmtCheckStatus.executeQuery();

                    if (rsStatus.next()) {
                        String status = rsStatus.getString("statusofpayment");
                        double discount=rsStatus.getDouble("discount");
                        totalAmount=totalAmount-(totalAmount*(discount/100));
                        if (!status.equalsIgnoreCase("paid")) {
        %>
        <form method="post">
            <div class="form-group">
                <label for="amountToBePaid">Amount to be Paid:</label>
                <input type="number" id="amountToBePaid" name="amountToBePaid" value="<%= totalAmount %>" required readonly>
            </div>
            <button type="submit" name="payButton">Pay</button>
            <input type="hidden" name="invoiceId" value="<%= invoiceId %>">
            <input type="hidden" name="customerName" value="<%= customerName %>">
        </form>
        <% 
                        } else {
        %>
        <div class="form-group">
            <p>Invoice <strong><%= invoiceId %></strong> is already paid.</p>
        </div>
        <% 
                        }
                    } else {
        %>
        <div class="form-group">
            <p>Invoice <strong><%= invoiceId %></strong> not found.</p>
        </div>
        <% 
                    }

                } catch (ClassNotFoundException | SQLException e) {
                    out.println("<h2>Error occurred:</h2>");
                    out.println("<p>" + e.getMessage() + "</p>");
                    e.printStackTrace(); // Print stack trace to console (optional)
                } finally {
                    if (rsItems != null) try { rsItems.close(); } catch (SQLException ignore) {}
                    if (stmtFetchItems != null) try { stmtFetchItems.close(); } catch (SQLException ignore) {}
                    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                }
            }
            
            if (request.getParameter("payButton") != null) {
                double amountPaid = Double.parseDouble(request.getParameter("amountToBePaid"));
                String invoiceId = request.getParameter("invoiceId");
                String customerName = request.getParameter("customerName");

                Connection conn = null;
                PreparedStatement stmtUpdateInvoice = null;
                PreparedStatement stmtUpdateCustomer = null;

                try {
                    conn = DBUtil.getConnection();

                    // Update invoice status to 'paid'
                    String updateInvoiceQuery = "UPDATE invoice SET statusofpayment = 'paid' WHERE invoiceid = ?";
                    stmtUpdateInvoice = conn.prepareStatement(updateInvoiceQuery);
                    stmtUpdateInvoice.setString(1, invoiceId);
                    int rowsUpdatedInvoice = stmtUpdateInvoice.executeUpdate();

                    // Update customer's paid amount and reduce unpaid amount
                    String updateCustomerQuery = "UPDATE customer SET paid = paid + ?, unpaid = unpaid - ? WHERE customername = ?";
                    stmtUpdateCustomer = conn.prepareStatement(updateCustomerQuery);
                    stmtUpdateCustomer.setDouble(1, amountPaid);
                    stmtUpdateCustomer.setDouble(2, amountPaid);
                    stmtUpdateCustomer.setString(3, customerName);
                    int rowsUpdatedCustomer = stmtUpdateCustomer.executeUpdate();

                    // Check if both updates were successful
                    if (rowsUpdatedInvoice > 0 && rowsUpdatedCustomer > 0) {
        %>
        <div class="form-group">
            <p>Invoice <strong><%= invoiceId %></strong> updated to 'paid'. Customer <strong><%= customerName %></strong> paid <strong>Rs. <%= amountPaid %></strong>.</p>
        </div>
        <% 
                    } else {
        %>
        <div class="form-group">
            <p>Failed to update invoice status or customer paid amount. Please check input details.</p>
        </div>
        <% 
                    }
                } catch (ClassNotFoundException | SQLException e) {
                    out.println("<h2>Error occurred:</h2>");
                    out.println("<p>" + e.getMessage() + "</p>");
                    e.printStackTrace(); // Print stack trace to console (optional)
                } finally {
                    if (stmtUpdateInvoice != null) try { stmtUpdateInvoice.close(); } catch (SQLException ignore) {}
                    if (stmtUpdateCustomer != null) try { stmtUpdateCustomer.close(); } catch (SQLException ignore) {}
                    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                }
            }
        %>
    </div>
</body>
</html>
