<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, com.zoho.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="icon" type="image/x-icon" href="https://img.icons8.com/?size=48&id=13222&format=png">
    <title>Customer Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f8ff;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 80%;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin-top: 40px;
        }
        h1 {
            color: #333333;
        }
        form {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555555;
        }
        input[type="text"], input[type="submit"] {
            padding: 10px;
            width: 100%;
            box-sizing: border-box;
            margin-bottom: 10px;
        }
        input[type="submit"] {
            background-color: #2b5279;
            color: #ffffff;
            border: none;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #063a6e;
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
            color: #333333;
        }
        td {
            background-color: #ffffff;
            color: #555555;
        }

    </style>
</head>
<body>

<div class="container">
    <h2>Customer Details</h2>

    <form method="GET" action="getCustomerBalance.jsp">
        <label for="identifier">Enter Customer Phone Number or Name:</label>
        <input type="text" id="identifier" name="identifier">
        <input type="submit" value="Search">
    </form>

    <%
        String identifier = request.getParameter("identifier");

        Customer customer = null;
        List<Invoice> unpaidInvoices = new ArrayList<>();
        List<Invoice> paidInvoices = new ArrayList<>();

        Connection conn = null;
        PreparedStatement stmtCustomer = null;
        ResultSet rsCustomer = null;
        PreparedStatement stmtUnpaidInvoices = null;
        ResultSet rsUnpaidInvoices = null;
        PreparedStatement stmtPaidInvoices = null;
        ResultSet rsPaidInvoices = null;

        try {
            if (identifier != null && !identifier.isEmpty()) {

                conn =DBUtil.getConnection();

                // Query to retrieve customer details
                String customerQuery = "SELECT phonenumber, customername, address, paid, unpaid FROM customer WHERE phonenumber = ? OR customername = ?";
                stmtCustomer = conn.prepareStatement(customerQuery);
                stmtCustomer.setString(1, identifier);
                stmtCustomer.setString(2, identifier);
                rsCustomer = stmtCustomer.executeQuery();

                if (rsCustomer.next()) {
                    String phoneNumber = rsCustomer.getString("phonenumber");
                    String customerName = rsCustomer.getString("customername");
                    String address = rsCustomer.getString("address");
                    int totalAmountPaid = rsCustomer.getInt("paid");
                    int totalAmountUnpaid = rsCustomer.getInt("unpaid");

                    customer = new Customer(phoneNumber, customerName, address);
                    customer.setTotalAmountPaid(totalAmountPaid);
                    customer.setTotalAmountUnpaid(totalAmountUnpaid);

                    // Query to retrieve unpaid invoices
                    String unpaidInvoicesQuery = "SELECT invoiceid, date, shop, discount, statusofpayment,address FROM invoice WHERE phonenumber = ? AND statusofpayment = 'unpaid'";
                    stmtUnpaidInvoices = conn.prepareStatement(unpaidInvoicesQuery);
                    stmtUnpaidInvoices.setString(1, customer.getPhoneNumber());
                    rsUnpaidInvoices = stmtUnpaidInvoices.executeQuery();

                    while (rsUnpaidInvoices.next()) {
                        String invoiceId = rsUnpaidInvoices.getString("invoiceid");
                        java.sql.Date date = rsUnpaidInvoices.getDate("date");
                        String shop = rsUnpaidInvoices.getString("shop");
                        double disamount=rsUnpaidInvoices.getDouble("discount");
                        String status = rsUnpaidInvoices.getString("statusofpayment");
                        String ship=rsUnpaidInvoices.getString("address");

                        Invoice invoice = new Invoice(invoiceId, phoneNumber, shop, date, disamount , status,ship);

                        String itemsQuery = "SELECT quantity, rate FROM bill_item WHERE invoiceid = ?";
                        PreparedStatement stmtItems = conn.prepareStatement(itemsQuery);
                        stmtItems.setString(1, invoiceId);
                        ResultSet rsItems = stmtItems.executeQuery();

                        double totalAmount = 0;
                        while (rsItems.next()) {
                            int quantity = rsItems.getInt("quantity");
                            double rate = rsItems.getDouble("rate");
                            totalAmount += quantity * rate;
                        }
                        rsItems.close();
                        stmtItems.close();

                        invoice.setTotalAmount(totalAmount - totalAmount * (disamount / 100));
                        unpaidInvoices.add(invoice);
                    }

                    // Query to retrieve paid invoices
                    String paidInvoicesQuery = "SELECT invoiceid, date, shop, discount, statusofpayment,address FROM invoice WHERE phonenumber = ? AND statusofpayment = 'paid'";
                    stmtPaidInvoices = conn.prepareStatement(paidInvoicesQuery);
                    stmtPaidInvoices.setString(1, customer.getPhoneNumber());
                    rsPaidInvoices = stmtPaidInvoices.executeQuery();

                    while (rsPaidInvoices.next()) {
                        String invoiceId = rsPaidInvoices.getString("invoiceid");
                        java.sql.Date date = rsPaidInvoices.getDate("date");
                        String shop = rsPaidInvoices.getString("shop");
                        double disamount=rsPaidInvoices.getDouble("discount");
                        String status = rsPaidInvoices.getString("statusofpayment");
                        String ship=rsPaidInvoices.getString("address");

                        Invoice invoice = new Invoice(invoiceId, phoneNumber, shop, date, disamount, status,ship);

                        String itemsQuery = "SELECT quantity, rate FROM bill_item WHERE invoiceid = ?";
                        PreparedStatement stmtItems = conn.prepareStatement(itemsQuery);
                        stmtItems.setString(1, invoiceId);
                        ResultSet rsItems = stmtItems.executeQuery();

                        double totalAmount = 0;
                        while (rsItems.next()) {
                            int quantity = rsItems.getInt("quantity");
                            double rate = rsItems.getDouble("rate");
                            totalAmount += quantity * rate;
                        }
                        rsItems.close();
                        stmtItems.close();

                        invoice.setTotalAmount(totalAmount - totalAmount * (disamount / 100));
                        paidInvoices.add(invoice);
                    }
    %>
                    <h3>Customer Details:</h3>
                    <table>
                        <tr><th>Phone Number</th><td><%= customer.getPhoneNumber() %></td></tr>
                        <tr><th>Customer Name</th><td><%= customer.getCustomerName() %></td></tr>
                        <tr><th>Address</th><td><%= customer.getAddress() %></td></tr>
                        <tr><th>Total Amount Paid</th><td><%= customer.getTotalAmountPaid() %></td></tr>
                        <tr><th>Total Amount Unpaid</th><td><%= customer.getTotalAmountUnpaid() %></td></tr>
                    </table>

                    <h3>Unpaid Invoices:</h3>
                    <table>
                        <tr>
                            <th>Invoice ID</th>
                            <th>Date</th>
                            <th>Shop</th>
                            <th>Total Amount</th>
                        </tr>
    <%
                        for (Invoice invoice : unpaidInvoices) {
    %>
                            <tr>
                                <td><%= invoice.getInvoiceId() %></td>
                                <td><%= invoice.getInvoiceDate() %></td>
                                <td><%= invoice.getShopName() %></td>
                                <td><%= invoice.getTotalAmount() %></td>
                            </tr>
    <%
                        }
    %>
                    </table>

                    <h3>Paid Invoices:</h3>
                    <table>
                        <tr>
                            <th>Invoice ID</th>
                            <th>Date</th>
                            <th>Shop</th>
                            <th>Total Amount</th>
                        </tr>
    <%
                        for (Invoice invoice : paidInvoices) {
    %>
                            <tr>
                                <td><%= invoice.getInvoiceId() %></td>
                                <td><%= invoice.getInvoiceDate() %></td>
                                <td><%= invoice.getShopName() %></td>
                                <td><%= invoice.getTotalAmount() %></td>
                            </tr>
    <%
                        }
    %>
                    </table>
    <%
                } else {
    %>
                    <p class="no-data">No customer found with the identifier: <%= identifier %></p>
    <%
                }
            } 
    %>
                
    <%
            
        } catch (Exception e) {
            out.println("<h2>Error occurred:</h2>");
            out.println("<p>" + e + "</p>");
        } finally {
            if (rsCustomer != null) try { rsCustomer.close(); } catch (SQLException ignore) {}
            if (stmtCustomer != null) try { stmtCustomer.close(); } catch (SQLException ignore) {}
            if (rsUnpaidInvoices != null) try { rsUnpaidInvoices.close(); } catch (SQLException ignore) {}
            if (stmtUnpaidInvoices != null) try { stmtUnpaidInvoices.close(); } catch (SQLException ignore) {}
            if (rsPaidInvoices != null) try { rsPaidInvoices.close(); } catch (SQLException ignore) {}
            if (stmtPaidInvoices != null) try { stmtPaidInvoices.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    %>

</div>

</body>
</html>
