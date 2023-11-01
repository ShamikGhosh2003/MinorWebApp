<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="main-style.css">
        <title>Change Password</title>
        <script>
            function validateForm() {
               var currentPassword = document.forms['change-password']['current-password'].value;
               var newPassword = document.forms['change-password']['new-password'].value;
               var confirmPassword = document.forms['change-password']['confirm-password'].value;

               if(currentPassword == "" || newPassword == "" || confirmPassword == "") {
                    document.getElementById('error-alert').innerHTML = "All fields are required.";
                    event.preventDefault();
               }
               if(newPassword.length < 8) {
                    document.getElementById('error-alert').innerHTML = "Password must be at least 8 characters.";
                    event.preventDefault();
               }
               if(newPassword != confirmPassword) {
                    document.getElementById('error-alert').innerHTML = "Passwords do not match.";
                    event.preventDefault();
               }
           }
       </script>
    </head>
    <body>
        <%!
            String vemail, vpass;
            OracleConnection oconn;
            OraclePreparedStatement ops;
            HttpSession sess;
        %>
        <%
            if(request.getParameter("submit")!=null)
            {
                if(request.getParameter("new-password").equals(request.getParameter("confirm-password")))
                {
                    sess = request.getSession(false);
                    vpass = request.getParameter("new-password");
                    vemail = sess.getAttribute("sessemail").toString();
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection("jdbc:oracle:thin:@DESKTOP-CPL2IQA:1521:orcl","SHAMIK","DATABASE");
                    ops = (OraclePreparedStatement) oconn.prepareStatement("UPDATE CUSTOMER SET PASSWORD=? WHERE EMAIL=?");
                    ops.setString(1,vpass);
                    ops.setString(2,vemail);
                    int x = ops.executeUpdate();
                    ops.close();
                    oconn.close();
                    sess.invalidate();
        %>
        <script>
            alert("Password reset successfully!! You can now login using the new password");
            alert("Redirecting for login ==>>");
            location.href="http://localhost:8080/MinorWebApp/forgotLogin.html";
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
                vemail = request.getParameter("pemail");
                sess = request.getSession(true);
                sess.setAttribute("sessemail", vemail);
        %>
                <!--<h3 style="color: green">
                Please verify your security credentials.
                </h3>-->
        <%                   
            }   
        %>
        <header class="header">           
            <a href="#" class="logo">MedFinder</a>
            <nav class="navbar">
            <a href="index.html">Home</a>
            <a href="profile.html">Profile</a>
            <a href="about.html">About Us</a>
            <a href="#">Contact</a>
            </nav>
        </header>
        <div class="form-container">
            <div class="form-box" style="width: 45%;">
                <form onsubmit="validateForm()"><!--method="POST" name="change-password" action="http://localhost:8080/MinorWebApp/ChangePassword"--> 
                    <h2 style="text-align: center;">CHANGE PASSWORD</h2>
                    <br>
                    <div id="error-alert" style="color: red; text-align: center; font-weight: bold;"></div>
                    <div class="input-group">
                        <label for="current-password">Current Password:</label>
                        <input type="password" name="current-password" placeholder="********" required>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="new-password">New Password:</label>
                        <input type="password" name="new-password" placeholder="********" required>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="confirm-password">Confirm New Password:</label>
                        <input type="password" name="confirm-password" placeholder="********" required>
                    </div>                         
                    <br>    
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" class="button-80" name="submit">Submit</button>
                        <button type="reset" class="button-80" name="clear">Clear</button>
                   </div>                   
                    <br>
                    <div style="text-align: right; line-height: 150%;">
                    Forgot password? <a href="forgot-password.html">Reset password</a><br>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>
