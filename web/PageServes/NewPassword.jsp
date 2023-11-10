<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page import="Webpack.hash"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Reset Password</title>
    </head>
    <body>
        <header>           
            <a href="#" class="heading">MedFinder</a>
            <nav class="navbar">
            <a href="index.html">Home</a>
            <a href="profile.html">Profile</a>
            <a href="about.html">About Us</a>
            <a href="#">Contact</a>
            </nav>
        </header>
        <div class="form-container">
            <div class="form-box" style="width: 38%;">
                <form method="POST" name="reset-password">
                    <h2 style="text-align: center;">FORGOT PASSWORD</h2>
                    <br>
                    <br>
                    <div class="input-group">
                        <label for="tpass">New Password:</label>
                        <input type="password" name="tpass" required>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="cpass">Confirm Password:</label>
                        <input type="password" name="cpass" required>
                    </div>
                    <br><br>
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" class="button-80" name="bConfirm">Reset Password</button>
                    </div> 
                    <br>
                    <div style="text-align: right; line-height: 150%;">
                    Remember your password? <a href="login.html">Log in</a><br>
                    New? <a href="register.html">Sign up</a>
                    </div>
                </form>
            </div>
        </div>
        <%!
            String email, pass, userType, table, query;
            OracleConnection oconn;
            OraclePreparedStatement ops;
            HttpSession sess, sess1;
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
            
            if(request.getParameter("bConfirm")!=null)
            {
                if(request.getParameter("tpass").equals(request.getParameter("cpass")))
                {
                    sess = request.getSession(false);
                    pass = request.getParameter("tpass");
                    //pass = hash.passwordHash(pass);
                    email = sess1.getAttribute("email").toString();
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                    if(sess!=null)
                        userType = sess.getAttribute("userType").toString();
                    if(userType.equals("CUSTOMER"))
                        table = "CUSTOMER";
                    if(userType.equals("ADMIN"))
                        table = "ADMIN";
                    if(userType.equals("PHARMACY"))
                        table = "PHARMACY";
                    query = "UPDATE "+table+" SET PASSWORD=? WHERE EMAIL=?";
                    ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                    ops.setString(1,pass);
                    ops.setString(2,email);
                    int x = ops.executeUpdate();
                    if(x>0)
                        out.println("<h3 style='color:green'>Data inserted Successfully....</h3>");
                    else
                        out.println("<h3 style='color:Red'>No Data Changes....</h3>");  
                    ops.close();
                    oconn.close();
                    sess.invalidate();
        %>
        <script>
            alert("Password reset successfully!! You can now login using the new password");
            alert("Redirecting for login ==>>");
            location.href="http://localhost:8080/MinorWebApp/StatPages/login.html";
        </script>
        <%
                }
                else
                {
        %>
        <h3 style="color: red">Password did not match, try again!</h3>
        <%
                }
            }
            else
            {
                email = request.getParameter("pemail");
                sess1 = request.getSession(true);
                sess1.setAttribute("email", email);
        %>
                <h3 style="color: green">
                Please verify your security credentials.
                </h3>
        <%                   
            }   
        %>
    </body>
</html>
