<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.zoho.Stock"%>
<%@ page import="com.zoho.Customer"%>
<%@ page import="com.zoho.Invoice"%>
<%@ page import="com.zoho.BillItem"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<%
    String customerPhone = request.getParameter("customerPhone");
    String shopName = request.getParameter("shopName");
    String invoiceId = request.getParameter("invoiceId");
    String invoiceDate = request.getParameter("invoiceDate");
    String discountStr = request.getParameter("discount");
    double discount = Double.parseDouble(discountStr);
    String status = request.getParameter("status");
    String shipaddress=request.getParameter("shipAddress");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    Date date = dateFormat.parse(invoiceDate);


    String[] itemNames = request.getParameterValues("itemName");
    String[] quantities = request.getParameterValues("quantity");
    String[] units = request.getParameterValues("unit");
    String[] rates = request.getParameterValues("rate");

    try {
        Customer customer = Customer.getCustomerByPhoneNumber(customerPhone);

        if (customer == null) {
            out.println("<h2>Error:</h2>");
            out.println("<p>No customer found with the phone number: " + customerPhone + "</p>");
        } else {
            Invoice invoice = new Invoice(invoiceId, customerPhone, shopName, date, discount, status,shipaddress);
            invoice.save();

            double totalAmount = 0;

            for (int i = 0; i < itemNames.length; i++) {
                String itemName = itemNames[i];
                int quantity = Integer.parseInt(quantities[i]);

                if (Stock.isItemAvailable(itemName, quantity)) {
                    BillItem billItem = new BillItem();
                    billItem.setInvoiceId(invoiceId);
                    billItem.setItemName(itemName);
                    billItem.setQuantity(quantity);
                    billItem.setUnit(units[i]);
                    billItem.setRate(Double.parseDouble(rates[i]));
                    billItem.save(); 

                    double price = quantity * Double.parseDouble(rates[i]);
                    totalAmount += price;

                    // Update stock for the item
                    Stock.updateStock(itemName, quantity); // Ensure this matches the method signature in Stock class
                } else {
                    out.println("<h2>Error:</h2>");
                    out.println("<p>Item not available in stock: " + itemName + "</p>");
                }
            }

            double discountedAmount = totalAmount - (totalAmount * (discount / 100));
            customer.updatePayment(discountedAmount, "paid".equals(status));

            response.sendRedirect("homepage.html");
        }

    } catch (Exception e) {
        out.println("<h2>Error occurred:</h2>");
        out.println("<p>" + e + "</p>");
    }
%>
