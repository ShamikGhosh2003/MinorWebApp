<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="javax.mail.MessagingException"%>
<%@page import="javax.mail.Transport"%>
<%@page import="java.util.Random"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.PasswordAuthentication"%>
<%@page import="javax.mail.Session"%>
<%@page import="java.util.Properties"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Feedback</title>
    </head>
    <body>
        <header>
            <a href="#"><img src="../media/logo.png" class="logo"></a>
            <a href="#" class="heading">MedFinder</a>
            <nav class="navbar">
            <a href="index.html">Home</a>
            <a href="profile.html">Profile</a>
            <a href="about.html">About Us</a>
            <a href="#">Contact</a>
            <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
            </nav>
        </header>
        <%!
            String to1, to2, from1, from2, subject1, subject2, body1, body2, link;
            String email, userType;
            String mailUsername, mailPassword;
            HttpSession sess; 
        %>
        <%
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
                sess = request.getSession(false);
                if(sess!=null){
                    email = sess.getAttribute("email").toString();
                    userType = sess.getAttribute("userType").toString();                    
                }
                to1 = mailUsername;
                subject1 = "FEEDBACK from a "+userType;
                body1 = request.getParameter("feedback") + "\nFeedback given by: \nemail: "+email;
                to2 = email;
                subject2 = "FEEDBACK";
                body2 = "Thank You for your valuable feedback! This will help us improve!! \n\nYour feedback was: " + request.getParameter("feedback");
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
                Session session2 = Session.getInstance(props, new javax.mail.Authenticator() {
                        protected PasswordAuthentication getPasswordAuthentication(){
                            return new PasswordAuthentication(username,password);
                        }});

                try {
                    Message message1 = new MimeMessage(session1);
                    message1.setFrom(new InternetAddress(username));
                    message1.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to1));
                    message1.setSubject(subject1);
                    message1.setText(body1);
                    Transport.send(message1);
                    Message message2 = new MimeMessage(session2);
                    message2.setFrom(new InternetAddress(username));
                    message2.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to2));
                    message2.setSubject(subject2);
                    message2.setText(body2);
                    Transport.send(message2);
                    if(userType.equals("CUSTOMER"))
                        link = "http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp";
                    else if(userType.equals("PHARMACY"))
                        link = "http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html";
        %>
                        <script>
                            alert("Your feedback has been recorded! You are being forwarded to home page!");
                            location.href="<%=link%>";
                        </script>
        <% 
                    
                } catch (MessagingException ex) {
                    out.println("<h2 style='color: red'>"+ex.getMessage()+"</h2>");
                }   
            }
        %>
        <div class="form-container">
            <div class="form-box" style="width: 45%;">
                <form method="POST"> <!-- method="POST" action="http://localhost:8080/MinorWebApp/Feedback"-->
                    <h2 style="text-align: center;">FEEDBACK</h2>
                    <br>
                    <p>Please let us know how we can do better.</p>
                    <br>
                    <textarea id="feedback" style="width: 100%; height: 100px;" name="feedback" placeholder="Feedback..." required></textarea>
                    <br>
                    <br>
                    <!--<div class="input-group">
                        <label for="email">Please enter your email address:</label><br>
                        <input type="email" id="email" name="email" placeholder="example@domain.com" required>
                    </div>-->
                    <br>
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" name="submit" class="button-80">Submit Feedback</button>
                    </div>                   
                    <br>
                </form>
            </div>
        </div>
    </body>
</html>

