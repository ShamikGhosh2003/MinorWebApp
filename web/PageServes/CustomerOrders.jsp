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
        String email,cid;
        int rtotal, total=0;
    %>
    <%
        try {
            InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
            props.load(input);
            oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
                + props.getProperty("port") + ":" + props.getProperty("SID");
            oconnUsername = props.getProperty("username");
            oconnPassword = props.getProperty("password");
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
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
            <h2>ORDERS</h2>
            <%
                query = "SELECT O.OID,P.PNAME, P.ADDRESS, M.MNAME, O.QTY, O.ITEM_PRICE, O.TOTAL FROM ORDERS O, PHARMACY P, CUSTOMER C, MEDICINE M WHERE O.CID=C.CID AND O.MID=M.MID AND O.PID=P.PID AND C.CID = ? AND O.STATUS = 'ORDERED' ORDER BY OID ASC";
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ops.setString(1, cid);
                ors = (OracleResultSet) ops.executeQuery();
                orsm = (OracleResultSetMetaData) ors.getMetaData();  
            %>
            <table>
                <thead>
                    <%
                        for(int i=1; i<=orsm.getColumnCount(); i++) 
                        {
                    %>
                        <th><%=orsm.getColumnName(i)%></th>
                    <%
                        }
                    %>
                </thead>
                <tbody>
                    <%  
                        while(ors.next())
                        { 
                    %>
                    <tr>
                        <%
                            int count = 0;
                            for(int i=1; i<=orsm.getColumnCount(); i++) 
                            {
                        %>
                                <td><%=ors.getString(i)%></td>
                        <%                                  
                            }
                        %>
                    </tr>  
                    <% 
                        }
                    %>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>
