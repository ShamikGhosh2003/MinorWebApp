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
    <link rel="icon" href="../media/favion.ico" type="image/x-icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer</title>
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
        String ident;
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
        <img src="../media/logo.png" class="logo">
        <span class="heading">MedFinder</span>
        <nav class="navbar">
        <a href="http://localhost:8080/MinorWebApp/StatPages/admin-database.html">Home</a>
        <a href="http://localhost:8080/MinorWebApp/StatPages/about.html">About Us</a>
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
                <h2>Customer Table</h2>
                <br>
                <div id="error-alert"></div>
                <div id="success-alert"></div>
                <%
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                    query = "SELECT CID, EMAIL, FNAME || ' ' || LNAME AS CUSTOMER_NAME, GENDER, AGE, ADDRESS, PHONE, PINCODE, SQUES, SANS, CITY FROM CUSTOMER ORDER BY CID ASC";
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
                        <th>ACTIONS</th>            
                    </thead>
                    <tbody>
                        <%  
                            while(ors.next()==true)
                            {
                        %>
                        <tr>
                            <%
                                ident="CUSTOMER";
                                for(int i=1; i<=orsm.getColumnCount(); i++)
                                {
                            %>
                                    <td><%=ors.getString(i)%></td>
                            <% 
                                    if(orsm.getColumnName(i).equals("CID"))
                                        ident+=","+ors.getString(i);
                                }
                            %>
                            <td>
                                <div class="actions-button-container">
                                    <form method="POST" action="http://localhost:8080/MinorWebApp/PageServes/ModifyCustomer.jsp">
                                        <!--<h3><%=ident%></h3>-->
                                        <button type="submit" name="Modify" value="<%=ident%>" class="button-46">MODIFY</button>
                                    </form>
                                    <form method="POST" action="http://localhost:8080/MinorWebApp/DeleteAll">
                                        <button type="submit" name="Delete" value="<%=ident%>" class="button-45">DELETE</button>
                                    </form>
                                </div>
                            </td>
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
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");

            if (response === "edit-success") {
                showSuccess("Customer edited successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response === "edit-fail") {
                showError("Failed to update customer.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response === "delete-success") {
                showSuccess("Customer deleted successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
        </script>
    </main>
<footer>
    <a href="https://www.facebook.com" target="_blank"><img src="../media/facebook-icon.png" class="social-icon" alt="Facebook"></a>
    <a href="https://www.twitter.com" target="_blank"><img src="../media/twitter-icon.ico" class="social-icon" alt="Twitter"></a>
    <a href="https://www.pintrest.com" target="_blank"><img src="../media/pinterest-icon.png" class="social-icon" alt="Pintrest"></a>
</footer>
</body>
</html>