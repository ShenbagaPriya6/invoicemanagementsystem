
<%@ page import="java.sql.*"%>
<%
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/sampletry","root","SHN2606");
            CallableStatement stmt=conn.prepareCall("{?=call sumofage()}");
            stmt.registerOutParameter(1,Types.INTEGER);
            stmt.execute();
            out.println(stmt.getInt(1));

        }
        catch(Exception e){
            out.println(e);
        }

%>
