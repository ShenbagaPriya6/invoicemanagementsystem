<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.zoho.*" %>

<%



    String itemName = request.getParameter("itemName");
    String quantityStr = request.getParameter("quantity");
    int quantity = Integer.parseInt(quantityStr);
    String rateStr = request.getParameter("rate");
    double rate = Double.parseDouble(rateStr);
    if(Stock.addStock(itemName, quantity, rate)){
        response.sendRedirect("homepage.html");
    } else {
        out.println("<p>Error in updating</p>");
    }
    
%>
