<%@page import="javax.mail.MessagingException"%>
<%@page import="javax.mail.Transport"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.PasswordAuthentication"%>
<%@page import="javax.mail.Session"%>
<%@page import="java.util.Random"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="main-style.css">
        <title>Payment Portal</title>
        <script>
            function validateForm() {
               var nameOnCard = document.forms['payment-portal']['nameOnCard'].value;
               var cardNumber = document.forms['payment-portal']['cardNumber'].value;
               var expiry = document.forms['payment-portal']['expiry'].value;
               var cvv = document.forms['payment-portal']['cvv'].value;
               var billingAddress = document.forms['payment-portal']['billingAddress'].value;

               if(nameOnCard === "" || cardNumber === "" || expiry === "" || cvv === "" || billingAddress === "") {
                    document.getElementById('error-alert').innerHTML = "All fields are required.";
                    event.preventDefault();
               }
           }
       </script>
    </head>
    <body>
        <header class="header">           
            <a href="#" class="logo">MedFinder</a>
            <nav class="navbar">
            <a href="SearchMedicine.html">Home</a>
            <a href="profile.html">Profile</a>
            <a href="about.html">About Us</a>
            <a href="#">Contact</a>
            <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
            </nav>
        </header>
        <div class="form-container">
            <div class="form-box" style="width: 30%;">
                <form method="POST" name="payment-portal" onsubmit="validateForm()">
                    <h2 style="text-align: center;">Payment Portal</h2>
                    <br>
                    <div id="error-alert" style="color: red; text-align: center; font-weight: bold;"></div>
                    <div class="input-group">
                        <label for="nameOnCard">Name on Card</label>
                        <input type="text" name="nameOnCard" required>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="cardNumber">Card Number</label>
                        <input type="text" name="cardNumber" required>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="expiry">Expiry Date</label>
                        <input type="month" name="expiry" required>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="cvv">CVV</label>
                        <input type="password" name="cvv" required>
                    </div>  
                    <br>
                    <div class="input-group">
                        <label for="billingAddress">Billing Address</label>
                        <textarea name="billingAddress" style="width: 65%;" required></textarea>
                    </div>                       
                    <br>    
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" name = "submit" class="button-80">Submit Payment</button>
                   </div>                   
                    <br>
                </form>
            </div>
        </div>
        <%!
            String to, from, subject, body;
            HttpSession sess; 
            String mailUsername, mailPassword;
            String email;
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
            if(request.getParameter("submit")!=null){
                sess = request.getSession(false);
                if(sess!=null)
                    email = sess.getAttribute("email").toString();
                //OTP generation code starts
                Random random = new Random();
                int x=0;
                while(x<1000)
                    x=random.nextInt(9999);
                body = "\n Your OTP is: "+x;
                //OTP generation code ends
                sess.setAttribute("otp",x);
                to = email;
                subject = "OTP FOR PLACING ORDER";
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
                try{
                    Message message = new MimeMessage(session1);
                    message.setFrom(new InternetAddress(username));
                    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
                    message.setSubject(subject);
                    message.setText(body);
                    Transport.send(message);
                }catch (MessagingException ex) {
                    out.println("<h2 style='color: red'>"+ex.getMessage()+"</h2>");
                }   
        %>
                <script>
                    alert("Verify the OTP sent to your mail to confirm order");
                    location.href="http://localhost:8080/MinorWebApp/PageServes/VerifyOTP.jsp";
                </script>
        <%
            }
        %>
    </body>
</html>

