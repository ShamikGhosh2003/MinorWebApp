<%-- TODO Fix this shit wtf happened here, --%>
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
    <title>Medicine Search JSP</title>
    <link rel="stylesheet" href="../stylesheet/main-style.css">
    <style>
        search-container {
            max-width: 600px;
            margin: auto;
            padding: 20px;
            box-shadow: 0 2px 4px 0 rgba(0, 0, 0, 0.06);
            background-color: #fff;
        }
        .search-container h2 {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .search-container select {
            width: 100%;
            height: 40px;
            padding: 5px 10px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .search-container input[type="submit"] {
            width: 100%;
            height: 40px;
            background-color: #20ab4a;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-container input[type="submit"]:hover {
            background-color: #1a753b;
        }
    </style>
    <%! 
        OracleConnection oconn;
        OraclePreparedStatement ops;
        OracleResultSet ors; //Store the data in the webpage from oracle
        OracleResultSetMetaData orsm;
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
            <a href="http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp">Home</a>
            <a href="http://localhost:8080/MinorWebApp/StatPages/about.html">About Us</a>
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
            <div class="search-container">
                <h2>Search Medicine</h2>
                <br>
                <div id="error-alert"></div>
                <div id="success-alert"></div>
                <br>
                <form action="SearchMedicineResult.jsp" method="post">
                    <select name="medicineName">
                    <%
                        DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                        oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                        query = "SELECT MNAME FROM MEDICINE ORDER BY MNAME ASC";
                        ops = (OraclePreparedStatement) oconn.prepareCall(query);
                        ors = (OracleResultSet) ops.executeQuery();
                        while(ors.next()==true)
                        {
                    %>
                    <option value="<%=ors.getString(1)%>"><%=ors.getString(1)%></option>
                    <% 
                        }
                    %>
                    </select>
                    <select id="city" name="city" required>
                        <option value="" selected disabled hidden>Select a City</option>
                        <option value="KOLKATA">Kolkata</option>
                        <option value="HOWRAH">Howrah</option>
                        <option value="BURDWAN">Burdwan</option>
                        <option value="DURGAPUR">Durgapur</option>
                    </select>
                    <br>
                    <input type="submit" value="Search">
                    <br><br>
                    <button type="button"><a href="http://localhost:8080/MinorWebApp/PageServes/FeedBack.jsp">Feedback Form</a></button>
                    <br>
                    <button type="button"><a href="http://localhost:8080/MinorWebApp/PageServes/changePassword.jsp">Change Password</a></button>
                    <br>
                    <button type="button"><a href="http://localhost:8080/MinorWebApp/PageServes/PaymentPortal.jsp">Payment Portal</a></button>
                    <br>
                    <button type="button"><a href="http://localhost:8080/MinorWebApp/PageServes/CustomerCart.jsp">Cart</a></button>
                    <br>
                    <button type="button"><a href="http://localhost:8080/MinorWebApp/PageServes/CustomerOrders.jsp">Orders</a></button>
                    <br><br>
                </form>
            </div>
        </main>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            let params = (new URL(document.location)).searchParams;
            let response = params.get("response");

            if (response == "feedback-success") {
                showSuccess("Feedback recieved successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "order-placed") {
                showSuccess("Order placed successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "added-cart") {
                showSuccess("Added to cart successfully.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "failed-cart") {
                showError("Failed to add to cart.<br>Please try again later.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
            if (response == "order-too-high") {
                showError("Not enough items in stock.<br>Please try again.");
                params.delete('response');
                window.history.replaceState({}, document.title, url.toString());
            }
        </script>
    </body>
</html>
