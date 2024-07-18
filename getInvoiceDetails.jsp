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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.9.2/html2pdf.bundle.js"></script>
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
        .details-container {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        .details-container > div {
            flex: 1;
            min-width: 30%;
            padding: 5px;
            margin: 5px;
        }
        .invoice-title,h3 {
            font-size: 20px;
            font-weight: bold;
            color: #2b5279;
        }
        .seller-info {
            text-align: right;
        }
        .billing-info, .shipping-info, .invoice-info {
            padding: 5px;
            margin: 5px 0;
        }
        .billing-info h3, .shipping-info h3, .invoice-info h3 {
            margin-top: 0;
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
        .subtotal {
            font-weight: bold;
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
        button[type="submit"],button {
            background-color: #2b5279;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            display: block;
            margin: 0 auto;
        }
        button[type="submit"]:hover,button {
            background-color: #122d48;
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        
        <form method="get" id="invoiceForm">
            <div class="header">
                <h2>Invoice Details</h2>
            </div>
            <div class="form-group">
                <label for="invoiceId">Enter Invoice ID:</label>
                <input type="text" id="invoiceId" name="invoiceId">
            </div>
            <button type="submit">Get Details</button>
        </form>
        <div id="details" class="hidden">
            <div class="details-container">
                <div class="invoice-title">
                    INVOICE
                </div>
             
                    <% 
                        String invoiceIdParam = request.getParameter("invoiceId");
                        String itemSearchParam = request.getParameter("itemSearch");
                        if (invoiceIdParam != null && !invoiceIdParam.isEmpty()) {
                            Connection conn = null;
                            PreparedStatement stmtInvoice = null;
                            ResultSet rsInvoice = null;
                            String customerPhone = "";
                            double discount = 0;
                            String status = "";
                            String shipaddress="";
                            try {

                                conn = DBUtil.getConnection();

                                // Fetch invoice details
                                String selectInvoiceQuery = "SELECT * FROM invoice WHERE invoiceid = ?";
                                stmtInvoice = conn.prepareStatement(selectInvoiceQuery);
                                stmtInvoice.setString(1, invoiceIdParam);
                                rsInvoice = stmtInvoice.executeQuery();

                                if (rsInvoice.next()) {

                                    String invoiceId = rsInvoice.getString("invoiceid");
                                    String shop = rsInvoice.getString("shop");
                                    java.util.Date date = rsInvoice.getDate("date");
                                    customerPhone = rsInvoice.getString("phonenumber");
                                    discount = rsInvoice.getDouble("discount");
                                    status = rsInvoice.getString("statusofpayment");
                                    shipaddress=rsInvoice.getString("address");


                                    Invoice invoice = new Invoice(invoiceId, customerPhone, shop, date, discount, status,shipaddress);

                    %>
                    <div class="seller-info">
                        <p><%= shop %></p>
                    </div>
                </div>
                <div class="details-container">
                    <div class="billing-info">
                        <h3>Invoice:</h3>
                    <p><strong>Invoice ID:</strong> <%= invoice.getInvoiceId() %></p>
                    <p><strong>Date:</strong> <%= date %></p>
                    <p><strong>Status:</strong> <%= invoice.getStatus() %></p>
                    <% 
                                } 
                            } catch (ClassNotFoundException | SQLException e) {
                                out.println("<h2>Error occurred:</h2>");
                                out.println("<p>" + e.getMessage() + "</p>");
                                e.printStackTrace(); // Print stack trace to console (optional)
                            } finally {
                                if (rsInvoice != null) try { rsInvoice.close(); } catch (SQLException ignore) {}
                                if (stmtInvoice != null) try { stmtInvoice.close(); } catch (SQLException ignore) {}
                                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                            }
                    %>
                </div>
                <div class="shipping-info">
                    <h3>Ship To:</h3>
                    <p><%= shipaddress %></p>
                </div>             
            </div>
            <div class="details-container">
                <div id="customerDetails">
                    <h3>Bill To</h3>
                    <% 
                        Connection conn2 = null;
                        PreparedStatement stmtCustomer = null;
                        ResultSet rsCustomer = null;
                        try {

                            conn2 = DBUtil.getConnection();

                            // Fetch customer details
                            String selectCustomerQuery = "SELECT * FROM customer WHERE phonenumber = ?";
                            stmtCustomer = conn2.prepareStatement(selectCustomerQuery);
                            stmtCustomer.setString(1, customerPhone);
                            rsCustomer = stmtCustomer.executeQuery();

                            if (rsCustomer.next()) {
                                String customerName = rsCustomer.getString("customername");
                                String address = rsCustomer.getString("address");
                    %>
                    <p><strong>Name:</strong> <%= customerName %></p>
                    <p><strong>Phone Number:</strong> <%= customerPhone %></p>
                    <p><strong>Address:</strong> <%= address %></p>
                    <% 
                            }
                        } catch (ClassNotFoundException | SQLException e) {
                            out.println("<h2>Error occurred:</h2>");
                            out.println("<p>" + e.getMessage() + "</p>");
                            e.printStackTrace(); // Print stack trace to console (optional)
                        } finally {
                            if (rsCustomer != null) try { rsCustomer.close(); } catch (SQLException ignore) {}
                            if (stmtCustomer != null) try { stmtCustomer.close(); } catch (SQLException ignore) {}
                            if (conn2 != null) try { conn2.close(); } catch (SQLException ignore) {}
                        }
                    %>
                </div>
            </div>
            <div class="itemsSection">
                <table>
                    <tr>
                        <th>Item Name</th>
                        <th>Quantity</th>
                        <th>Rate</th>
                        <th>Price</th>
                    </tr>
                    <% 
                        Connection conn3 = null;
                        PreparedStatement stmtItems = null;
                        ResultSet rsItems = null;
                        try {

                            conn3 = DBUtil.getConnection();

                            // Fetch items related to the invoice
                            String selectItemsQuery = "SELECT * FROM bill_item WHERE invoiceid = ?";
                            if (itemSearchParam != null && !itemSearchParam.isEmpty()) {
                                selectItemsQuery += " AND itemname LIKE ?";
                            }
                            stmtItems = conn3.prepareStatement(selectItemsQuery);
                            stmtItems.setString(1, invoiceIdParam);
                            if (itemSearchParam != null && !itemSearchParam.isEmpty()) {
                                stmtItems.setString(2, "%" + itemSearchParam + "%");
                            }
                            rsItems = stmtItems.executeQuery();

                            double subtotal = 0;
                            while (rsItems.next()) {
                                String itemName = rsItems.getString("itemname");
                                int quantity = rsItems.getInt("quantity");
                                String unit = rsItems.getString("unit");
                                double rate = rsItems.getDouble("rate");
                                double price = quantity * rate;
                                subtotal += price;
                    %>
                    <tr>
                        <td><%= itemName %></td>
                        <td><%= quantity %> <%= unit %></td>
                        <td>Rs. <%= rate %></td>
                        <td>Rs. <%= price %></td>
                    </tr>
                    <% 
                            }
                    %>
                    <tr class="subtotal">
                        <td colspan="3">Subtotal:</td>
                        <td>Rs. <%= subtotal %></td>
                    </tr>
                    <tr>
                        <td colspan="3">Discount:</td>
                        <td>Rs. <%= discount %></td>
                    </tr>
                    <tr>
                        <td colspan="3">Total Amount:</td>
                        <td>Rs. <%= subtotal - subtotal*(discount/100) %></td>
                    </tr>
                </table>
                <% 
                        } catch (ClassNotFoundException | SQLException e) {
                            out.println("<h2>Error occurred:</h2>");
                            out.println("<p>" + e.getMessage() + "</p>");
                            e.printStackTrace(); // Print stack trace to console (optional)
                        } finally {
                            if (rsItems != null) try { rsItems.close(); } catch (SQLException ignore) {}
                            if (stmtItems != null) try { stmtItems.close(); } catch (SQLException ignore) {}
                            if (conn3 != null) try { conn3.close(); } catch (SQLException ignore) {}
                        }
                    } else {
                %>
                <p>No invoice found with ID: <%= invoiceIdParam %></p>
                <% 
                    } 
                %>
            </div>
        </div>
        
    </div>
    <br>
    <button onclick="generatePDF()" id="dbutton" style="display:none;">Download</button>

    <script>
        window.onload = function() {
            const invoiceForm = document.getElementById('invoiceForm');
            const details = document.getElementById('details');
            const dbutton = document.getElementById('dbutton');

            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('invoiceId') && urlParams.get('invoiceId').trim() !== '') {
                invoiceForm.style.display = 'none';
                dbutton.style.display = 'block';
                details.classList.remove('hidden');
            }
        }
        
        function generatePDF() {
            const invoice = this.document.getElementById("details");
            console.log(invoice);
            console.log(window);
            var opt = {
                margin: 1,
                filename: 'invoice.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2 },
                jsPDF: { unit: 'in', format: 'letter', orientation: 'portrait' }
            };
            html2pdf().from(invoice).set(opt).save();
        }
    </script>
</body>
</html>
