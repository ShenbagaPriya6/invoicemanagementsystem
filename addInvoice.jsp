<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%
    // Auto-generate invoice ID and get today's date
    String invoiceId = "INV" + System.currentTimeMillis(); 
    String todayDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Invoice</title>
    <link rel="icon" type="image/x-icon" href="https://img.icons8.com/?size=48&id=13222&format=png">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f8ff;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .form-group {
            margin-bottom: 15px;
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
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table, th, td {
            border: 1px solid #ccc;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        .add-item-btn{
            background-color: #2b5279;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
            display:block;
            margin: 0 auto;
        }
         .submit-btn {
            background-color: #2b5279;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
            margin: 0 auto;
        }
        .add-item-btn:hover, .submit-btn:hover {
            background-color: #122d48;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Add Invoice</h1>
        <form action="submitInvoice.jsp" method="post">
            <div class="form-group">
                <label for="customerPhone">Customer Phone Number:</label>
                <input type="text" id="customerPhone" name="customerPhone" required>
            </div>
            <div class="form-group">
                <label for="shopName">Seller:</label>
                <input type="text" id="shopName" name="shopName" required>
            </div>
            <div class="form-group">
                <label for="shipAddress">Ship To:</label>
                <input type="text" id="shipAddress" name="shipAddress" required>
            </div>
            <div class="form-group" style="display: flex; justify-content: space-between;">
                <div style="flex: 1; margin-right: 10px;">
                    <label for="invoiceId">Invoice ID:</label>
                    <input type="text" id="invoiceId" name="invoiceId" value="<%= invoiceId %>" readonly>
                </div>
                <div style="flex: 1; margin-left: 10px;">
                    <label for="invoiceDate">Date:</label>
                    <input type="date" id="invoiceDate" name="invoiceDate" value="<%= todayDate %>" readonly>
                </div>
            </div>
            <table id="itemsTable">
                <thead>
                    <tr>
                        <th>Item Name</th>
                        <th>Quantity</th>
                        <th>Unit</th>
                        <th>Rate</th>
                        <th>Price</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><input type="text" name="itemName" required></td>
                        <td><input type="number" name="quantity" required oninput="calculatePrice(this)"></td>
                        <td><input type="text" name="unit" required></td>
                        <td><input type="number" name="rate" required oninput="calculatePrice(this)"></td>
                        <td><input type="number" name="price" readonly></td>
                    </tr>
                </tbody>
            </table>
            <button type="button" class="add-item-btn" onclick="addItem()">Add Item</button>
            <div class="form-group">
                <label for="discount">Discount:</label>
                <input type="number" id="discount" name="discount" oninput="calculateSubtotal()">
            </div>
            <div class="form-group">
                <label for="total">Sub Total:</label>
                <input type="number" id="total" name="total" readonly>
            </div>
            <div class="form-group">
                <label for="subtotal">Total:</label>
                <input type="number" id="subtotal" name="subtotal" readonly>
            </div>
            <button type="submit" class="submit-btn" name="status" value="paid">Submit as Paid</button>
            <button type="submit" class="submit-btn" name="status" value="unpaid">Submit as Unpaid</button>
        </form>
    </div>
    <script>
        function calculatePrice(element) {
            var row = element.parentElement.parentElement;
            var quantity = row.querySelector('input[name="quantity"]').value;
            var rate = row.querySelector('input[name="rate"]').value;
            var price = row.querySelector('input[name="price"]');
            price.value = quantity * rate;
            calculateSubtotal();
        }

        function addItem() {
            var table = document.getElementById('itemsTable').getElementsByTagName('tbody')[0];
            var newRow = table.insertRow();
            var cells = ['itemName', 'quantity', 'unit', 'rate', 'price'];
            cells.forEach(function(cell, index) {
                var newCell = newRow.insertCell(index);
                var input = document.createElement('input');
                input.type = index === 1 || index === 3 || index === 4 ? 'number' : 'text';
                input.name = cell;
                input.required = true;
                if (index === 1 || index === 3) {
                    input.oninput = function() { calculatePrice(input); };
                }
                if (index === 4) {
                    input.readOnly = true;
                }
                newCell.appendChild(input);
            });
        }

        function calculateSubtotal() {
            var table = document.getElementById('itemsTable').getElementsByTagName('tbody')[0];
            var rows = table.getElementsByTagName('tr');
            var total = 0;
            for (var i = 0; i < rows.length; i++) {
                var price = rows[i].querySelector('input[name="price"]').value;
                total += parseFloat(price);
            }
            var discount = document.getElementById('discount').value;
            document.getElementById('subtotal').value = total-total*(discount/100);
            document.getElementById('total').value = total;
        }
    </script>
</body>
</html>
