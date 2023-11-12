<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Check Orders</title>
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <%! 
            //DECLARATION
            OracleConnection oconn;
            OraclePreparedStatement ops;
            OracleResultSet ors; //Store the data in the webpage from oracle
            OracleResultSetMetaData orsm;
            int reccounter=0; //record counter
            String query;
            java.util.Properties props = new java.util.Properties();
            String oconnUrl, oconnUsername, oconnPassword;
        %>
        <%
            try {
                InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
                props.load(input);
                oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
                    + props.getProperty("port") + ":" + props.getProperty("SID");
                oconnUsername = props.getProperty("username");
                oconnPassword = props.getProperty("password");
            } catch (IOException ex) {
                out.println("Error: " + ex.getMessage());
            }
        %>
    </head>
    <body>
        <header>
            <img src="http://localhost:8080/MinorWebApp/media/logo.png" class="logo">
            <span class="heading">MedFinder</span>
            <nav class="navbar">
            <a href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html">Home</a>
            <a href="http://localhost:8080/MinorWebApp/about.html">About Us</a>
            <a href="http://localhost:8080/MinorWebApp/PageServes/FeedBack.jsp">Feedback</a>
            <div class="navbar-dropdown">
                <a class="navbar-dropdown-button">Settings</a>
                <div class="navbar-dropdown-content">
                    <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
                    <a href="http://localhost:8080/MinorWebApp/PageServes/changePassword.jsp">Change Password</a>
                </div>
            </div>
            </nav>
        </header>
        <main>
            <div class="table-box-container">
                <div class="table-box">
                    <h2>Pharmacy Orders</h2>
                    <%
                        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                        query = "SELECT O.OID, O.CID, C.FNAME || ' ' || C.LNAME AS CUSTOMER_NAME, O.PID, P.PNAME, O.MID, M.MNAME, O.ODATE, O.QTY, O.STATUS FROM ORDERS O, PHARMACY P, CUSTOMER C, MEDICINE M WHERE O.CID=C.CID AND O.PID=P.PID AND O.MID = M.MID ORDER BY OID ASC";
                        ops = (OraclePreparedStatement) oconn.prepareCall(query);                    
                        ors = (OracleResultSet) ops.executeQuery();
                        orsm = (OracleResultSetMetaData) ors.getMetaData();
                    %>
                    <table>
                        <thead>
                            <%
                                for(int i=1; i<=orsm.getColumnCount(); i++)
                                {
                                    reccounter++;
                            %>
                                    <th><%=orsm.getColumnName(i)%></th>
                            <%
                                }
                            %>          
                        </thead>
                        <tbody>
                            <%  
                                while(ors.next()==true)
                                {
                            %>
                            <tr>
                                <%
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
                        <tfoot>
                            <tr>
                                <th colspan="<%=reccounter+1%>" style="text-align: center;">MedFinder</th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </main>
    </body>
</html>
