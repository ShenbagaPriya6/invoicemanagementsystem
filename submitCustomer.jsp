<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.zoho.*" %>
<%

    String customerPhone = request.getParameter("customerPhone");
    String customerName = request.getParameter("customerName");
    String address = request.getParameter("address");

    Connection conn = null;
    PreparedStatement stmtInsertCustomer = null;

    try {
      
        conn = DBUtil.getConnection();

        String insertCustomerQuery = "INSERT INTO customer (phonenumber, customername, address, paid, unpaid) VALUES (?, ?, ?, 0, 0)";
        stmtInsertCustomer = conn.prepareStatement(insertCustomerQuery);
        stmtInsertCustomer.setString(1, customerPhone);
        stmtInsertCustomer.setString(2, customerName);
        stmtInsertCustomer.setString(3, address);
        stmtInsertCustomer.executeUpdate();

        response.sendRedirect("homepage.html");

    } catch (SQLIntegrityConstraintViolationException e) {
        // Integrity constraint violation (duplicate phone number or name)
        out.println("<h2>Error occurred:</h2>");
        out.println("<p>A customer with the same phone number or name already exists.</p>");
        out.println("<p><a href='addCustomer.jsp'>Go back to Add Customer page</a></p>");
    } catch (Exception e) {
        // Other exceptions
        out.println("<h2>Error occurred:</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
    } finally {
        // Close all resources
        try {
            if (stmtInsertCustomer != null) stmtInsertCustomer.close();
            if (conn != null) conn.close();
        } catch (SQLException ignore) {
            // Handle appropriately or log
        }
    }
%>
