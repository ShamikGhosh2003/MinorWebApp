<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Result</title>
    <link rel="stylesheet" href="../stylesheet/main-style.css">
    <style>
        .result-container {
            max-width: 800px;
            margin: auto;
            padding: 20px;
            box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.06);
            background-color: #fff;
        }
        .result-container h2 {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .result-container table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .result-container th, .result-container td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .result-container th {
            background-color: #f8f9fa;
            color: #333;
        }
        .result-container label {
            margin-right: 10px;
        }
        .result-container input[type="number"] {
            width: 50px;
            height: 30px;
            margin-right: 10px;
        }
        .result-container input[type="submit"] {
            background-color: #007bff;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 5px 10px;
            cursor: pointer;
        }
        .result-container input[type="submit"]:hover {
            background-color: #0056b3;
        }
    </style>
    <%! 
        OracleConnection oconn;
        OraclePreparedStatement ops, ops1;
        OracleResultSet ors, ors1; //Store the data in the webpage from oracle
        OracleResultSetMetaData orsm;
        String query, query2;
        java.util.Properties props = new java.util.Properties();
        String oconnUrl, oconnUsername, oconnPassword;
        String ident,email,cid;
    %>
    <%
        boolean hasResult = false;
        try {
            InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
            props.load(input);
            oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
                + props.getProperty("port") + ":" + props.getProperty("SID");
            oconnUsername = props.getProperty("username");
            oconnPassword = props.getProperty("password");
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
            query = "SELECT P.PNAME, M.MNAME, P.ADDRESS, PMS.MQTY, PMS.PRICE, P.PID, M.MID FROM PHARMACY P,MEDICINE M, PHARM_MED_STOCK PMS WHERE M.MID = (SELECT MID FROM MEDICINE WHERE MNAME = ?) AND P.PID=PMS.PID AND M.MID=PMS.MID";
            ops = (OraclePreparedStatement) oconn.prepareCall(query);
            ops.setString(1, request.getParameter("medicineName"));
            //ops.setString(2, request.getParameter("city"));
            ors = (OracleResultSet) ops.executeQuery();
            orsm = (OracleResultSetMetaData) ors.getMetaData();
            HttpSession sess = request.getSession(false);
            if(session!=null)
                email = sess.getAttribute("email").toString();
            ops1 = (OraclePreparedStatement) oconn.prepareStatement("SELECT CID FROM CUSTOMER WHERE EMAIL = ?");
            ops1.setString(1,email);
            ors1 = (OracleResultSet) ops1.executeQuery();
            ors1.next();
            cid = ors1.getString("CID");
        } catch (Exception ex) {
            out.println("Error: " + ex.getMessage());
        }
    %>
</head>
<body>
    <header>           
        <span class="heading">MedFinder</span>
        <nav class="navbar">
        <a href="index.html">Home</a>
        <a href="registerUser.html">Register</a>
        <a href="about.html">About Us</a>
        <a href="#">Contact</a>
        <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
        </nav>
    </header>
    <main>
        <div class="result-container">
            <h2>Search Result</h2>
            <table>
                <thead>
                    <%
                        for(int i=1; i<=orsm.getColumnCount()-2; i++) //-2 given to exclude PID, MID from printing
                        {
                    %>
                    <th><%=orsm.getColumnName(i)%></th>
                    <%
                        }
                    %>
                    <th>QUANTITY</th>
                </thead>
                <tbody>
                    <%  
                        while(ors.next())
                        {
                            hasResult=true; 
                    %>
                    <tr>
                        <%
                            ident = "ORDERS,"+cid;
                            int count = 0;
                            for(int i=1; i<=orsm.getColumnCount(); i++) 
                            {   
                                if(orsm.getColumnName(i).equals("PID")){
                                    ident+=","+ors.getString(i);++count;}
                                if(orsm.getColumnName(i).equals("MID")){
                                    ident+=","+ors.getString(i);++count;}
                                if(orsm.getColumnName(i).equals("MQTY"))
                                    ident+=","+ors.getString(i);
                                if(orsm.getColumnName(i).equals("PRICE"))
                                    ident+=","+ors.getString(i);
                                if(count!=0)
                                    continue;
                        %>
                                <td><%=ors.getString(i)%></td>
                        <%                             
                            }
                        %>
                        <td>                            
                            <form method="POST" action="http://localhost:8080/MinorWebApp/AddToCart">
                                <!--<h3><%=ident%></h3>-->
                                <input type="number" id="quantity" name="<%=ident%>" min="1" max="100">
                                <button type="submit" name="cart" value="<%=ident%>" class="button-80">Add to cart</button>
                            </form>
                        </td>
                    </tr>  
                    <% 
                        }
                    %>
                </tbody>
            </table> 
            <!--
            TODO:
            Change this submit quantity form to showing which pharmacy has said medicine instead through SQL queries.
            -->
            <form method="POST" action="http://localhost:8080/MinorWebApp/PageServes/CustomerCart.jsp">
                <input type="submit" value="Go to cart" name="go-to-cart">
            </form>
            <%
                if(!hasResult) {
            %>
            <p>No results found for <%=request.getParameter("medicineName")%></p>
            <%
                }
            %>
        </div>
    </main>
</body>
</html>
