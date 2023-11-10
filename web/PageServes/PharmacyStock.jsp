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
    <title>Pharmacy Medicine Stock</title>
    <link rel="stylesheet" href="../StatPages/main-style.css">
    <%! 
        //DECLARATION
        OracleConnection oconn;
        OraclePreparedStatement ops;
        OracleResultSet ors; //Store the data in the webpage from oracle
        OracleResultSetMetaData orsm;
        int reccounter=0; //record counter
        String query, email;        
        java.util.Properties props = new java.util.Properties();
        HttpSession sess;
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
        sess = request.getSession(false);
        if(sess!=null)
            email = sess.getAttribute("email").toString();
    %>
</head>
<body>
    <header class="header">           
        <a href="#" class="heading">MedFinder</a>
        <nav class="navbar">
        <a href="../StatPages/PharmacyHome.html">Home</a>
        <a href="registerUser.html">Register</a>
        <a href="about.html">About Us</a>
        <a href="#">Contact</a>
        <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
        </nav>
    </header>
    <main class="admin-panel">
        <div class="table-container">
            <h2>Pharmacy Medicine Stock Table</h2>
            <%
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                query = "SELECT PMS.PID, P.PNAME, PMS.MID, M.MNAME, PMS.MQTY, PMS.PRICE, PMS.MAV FROM PHARM_MED_STOCK PMS, PHARMACY P, MEDICINE M WHERE PMS.PID=P.PID AND PMS.MID=M.MID AND P.EMAIL = ? ORDER BY PID ASC, MID ASC";
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ops.setString(1, email);
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
                    <th>ACTIONS</th>            
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
                        <td>
                            <form>
                                <button type="submit" name="Delete">DELETE</button>
                            </form>
                        </td>
                    </tr>    
                    <% 
                        }
                    %>
                </tbody>
                <tfoot>
                    <tr>
                        <th colspan="<%=reccounter+1%>" style="text-align: center">MedFinder</th>
                    </tr>
                </tfoot>
            </table>
        </div>
    </main>
</body>
</html>
