<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, com.zoho.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="icon" type="image/x-icon" href="https://img.icons8.com/?size=48&id=13222&format=png">
    <title>Item Details</title>
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
    <h1>Item Details</h1>

    <form method="GET" action="getItemDetails.jsp">
        <label for="itemName">Enter Item Name:</label>
        <input type="text" id="itemName" name="itemName">
        <input type="submit" value="Search">
    </form>

    <%
        String itemName = request.getParameter("itemName");



        Stock stock = null;
        int totalQuantitySold = 0;
        double totalAmountSold = 0;

        Connection conn = null;
        PreparedStatement stmtItem = null;
        ResultSet rsItem = null;
        PreparedStatement stmtSold = null;
        ResultSet rsSold = null;

        try {
            if (itemName != null && !itemName.isEmpty()) {

                conn = DBUtil.getConnection();

                // Query to get item details from the instock table
                String itemQuery = "SELECT itemname, quantity, rate FROM instock WHERE itemname = ?";
                stmtItem = conn.prepareStatement(itemQuery);
                stmtItem.setString(1, itemName);
                rsItem = stmtItem.executeQuery();

                if (rsItem.next()) {
                    String name = rsItem.getString("itemname");
                    int quantity = rsItem.getInt("quantity");
                    double rate = rsItem.getDouble("rate");

                    stock = new Stock(name, quantity, rate);

                    // Query to get sold quantity and total amount from the bill_item table
                    String soldQuery = "SELECT SUM(quantity) AS total_quantity_sold, SUM(quantity * rate) AS total_amount_sold " +
                                       "FROM bill_item WHERE itemname = ?";
                    stmtSold = conn.prepareStatement(soldQuery);
                    stmtSold.setString(1, itemName);
                    rsSold = stmtSold.executeQuery();

                    if (rsSold.next()) {
                        totalQuantitySold = rsSold.getInt("total_quantity_sold");
                        totalAmountSold = rsSold.getDouble("total_amount_sold");
                    }
                }
    %>

    <%
        if (stock != null) {
    %>
    <h2>Item Details:</h2>
    <table>
        <tr><th>Item Name</th><td><%= stock.getItemName() %></td></tr>
        <tr><th>Quantity In Stock</th><td><%= stock.getQuantity() %></td></tr>
        <tr><th>Rate</th><td><%= stock.getRate() %></td></tr>
    </table>

    <h2>Sold Details:</h2>
    <table>
        <tr><th>Total Quantity Sold</th><td><%= totalQuantitySold %></td></tr>
        <tr><th>Total Amount Sold</th><td><%= totalAmountSold %></td></tr>
    </table>
    <%
        } else {
    %>
    <p>No item found with the name: <%= itemName %></p>
    <%
        }
    %>

    <%
            }
        } catch (Exception e) {
            out.println("<h2>Error occurred:</h2>");
            out.println("<p>" + e + "</p>");
        } finally {
            try { if (rsItem != null) rsItem.close(); } catch (SQLException e) { /* ignored */ }
            try { if (stmtItem != null) stmtItem.close(); } catch (SQLException e) { /* ignored */ }
            try { if (rsSold != null) rsSold.close(); } catch (SQLException e) { /* ignored */ }
            try { if (stmtSold != null) stmtSold.close(); } catch (SQLException e) { /* ignored */ }
            try { if (conn != null) conn.close(); } catch (SQLException e) { /* ignored */ }
        }
    %>

</div>

</body>
</html>
