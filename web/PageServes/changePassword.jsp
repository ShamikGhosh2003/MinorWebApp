<%@page import="java.util.logging.Logger"%>
<%@page import="java.util.logging.Level"%>
<%@page import="javax.mail.MessagingException"%>
<%@page import="javax.mail.Transport"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.PasswordAuthentication"%>
<%@page import="javax.mail.Session"%>
<%@page import="java.util.Properties"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
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
            String email, oldpass, newpass, userType, table, query, databasePass;
            String vto, vsubject, vbody;
            OracleConnection oconn;
            OraclePreparedStatement ops;
            OracleResultSet ors = null;
            HttpSession sess;            
            String oconnUrl, oconnUsername, oconnPassword;
            String mailUsername, mailPassword;
        %>
        <%
            try {
                InputStream input = application.getResourceAsStream("/WEB-INF/db.properties");
                Properties props = new Properties();
                props.load(input);
                oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
                    + props.getProperty("port") + ":" + props.getProperty("SID");
                oconnUsername = props.getProperty("username");
                oconnPassword = props.getProperty("password");
            } catch (IOException ex) {
                out.println("Error: " + ex.getMessage());
            }
            try (InputStream mailInput = application.getResourceAsStream("/WEB-INF/mail.properties")) {
                Properties mailProps = new Properties();
                mailProps.load(mailInput);
                mailUsername = mailProps.getProperty("username");
                mailPassword = mailProps.getProperty("password");
                } catch (IOException ex) {
                    throw new ServletException(ex);
            }
            
            if(request.getParameter("submit")!=null)
            {
                if(request.getParameter("new-password").equals(request.getParameter("confirm-password")))
                {
                    sess = request.getSession(false);
                    if(sess!=null){
                        email = sess.getAttribute("email").toString();
                        userType = sess.getAttribute("userType").toString();                    
                    }
                    if(userType.equals("CUSTOMER"))
                        table = "CUSTOMER";
                    if(userType.equals("PHARMACY"))
                        table = "PHARMACY";
                    oldpass = request.getParameter("current-password");
                    newpass = request.getParameter("new-password");
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                    query = "SELECT * FROM "+table+" WHERE EMAIL=?";
                    ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                    ops.setString(1,email);
                    ors = (OracleResultSet)ops.executeQuery();
                    ors.next();
                    databasePass = ors.getString("PASSWORD");
                    if(oldpass.equals(databasePass)){
                        query = "UPDATE "+table+" SET PASSWORD=? WHERE EMAIL=?";
                        ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                        ops.setString(1,newpass);
                        ops.setString(2,email);
                        int x = ops.executeUpdate();
                        if(x>0){
                            out.println("<h3 style='color:green'>Data inserted Successfully....</h3>");
        %>
                        <script>
                            alert("Password Changed Successfully, try Loggin-in again!");
                            location.href="http://localhost:8080/MinorWebApp/StatPages/login.html";
                        </script>
        <%
                            vto = email;
                            vsubject = "Password Changed Successfully";
                            vbody = "Your recent password Change was successful! You can now login using the new password. \nLogin link: http://localhost:8080/MinorWebApp/StatPages/login.html";
                            final String username = mailUsername;
                            final String password = mailPassword;

                            Properties props = new Properties();
                            props.put("mail.smtp.auth","true");
                            props.put("mail.smtp.starttls.enable","true");
                            props.put("mail.smtp.host","smtp.gmail.com");
                            props.put("mail.smtp.port","587");

                            Session session1 = Session.getInstance(props, new javax.mail.Authenticator() {
                            protected PasswordAuthentication getPasswordAuthentication(){
                                return new PasswordAuthentication(username,password);
                            }});
                            try {
                                Message message = new MimeMessage(session1);
                                message.setFrom(new InternetAddress(username));
                                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(vto));
                                message.setSubject(vsubject);                       
                                message.setText(vbody);
                                Transport.send(message);
                                //response.sendRedirect("http://localhost:8080/WebApp1/PageServes/VerifyOTP.jsp");
                            } catch (MessagingException ex) {
                                out.println("<h2 style='color: red'>"+ex.getMessage()+"</h2>");
                            }                   
                        }
                        else
                            out.println("<h3 style='color:Red'>No Data Changes....</h3>");  
                    }else{
        %>
                    <script>
                        alert("OldPassword is Wrong, try again!!");
                        location.href="http://localhost:8080/MinorWebApp/PageServes/changePassword.jsp";
                    </script>
        <%
                    }
                    ops.close();
                    oconn.close();
                    sess.invalidate();

                }
                else
                {
        %>
        <h3 style="color: red">Password did not match, try again!</h3>
        <%
                }
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
