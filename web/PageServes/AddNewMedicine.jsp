<%@page import="javax.mail.MessagingException"%>
<%@page import="javax.mail.Transport"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.PasswordAuthentication"%>
<%@page import="javax.mail.Session"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Add New Medicine</title>
    </head>
    <body>
        <header>
            <a href="#"><img src="../media/logo.png" class="logo"></a>
            <a href="#" class="heading">MedFinder</a>
            <nav class="navbar">
            <a href="../StatPages/PharmacyHome.html">Home</a>
            <a href="registerUser.html">Register</a>
            <a href="about.html">About Us</a>
            <a href="#">Contact</a>
            </nav>
        </header>
        <div class="form-container">
            <div class="form-box" style="width: 45%;">
                <form method="POST" name="register">
                    <h2 style="text-align: center;">REGISTER MEDICINE</h2>
                    <br>
                    <div id="error-alert" style="color: red; text-align: center; font-weight: bold;"></div>
                    <div class="input-group">
                        <label for="mname">Medicine Name:</label>
                        <input type="text" id="mname" name="mname" placeholder="<%=mname%>" readonly>
                    </div>
                    <br>
                    <div class="input-group">
                        <label for="mcategory">Medicine Category:</label>
                        <select id="mcategory" name="mcategory" required>
                            <option value="" selected disabled hidden>Select a Category</option>
                            <option value="TABLET">Tablet</option>
                            <option value="INJECTION">Injection</option>
                            <option value="SYRUP">Syrup</option>
                            <option value="CREAM">Cream</option>
                            <option value="SPRAY">Spray</option>
                            <option value="POWDER">Powder</option>
                        </select>
                    </div>
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" class="button-80" name="submit">Submit</button>
                        <button type="reset" class="button-80">Clear</button>
                   </div> 
                </form>
            </div>
        </div>
        <%!
            String mname, query, mid, midNum, email, mcategory;
            String to, from, subject, body;
            OracleConnection oconn;
            OraclePreparedStatement ops; 
            OracleResultSet ors = null;
            HttpSession sess; 
            String oconnUrl, oconnUsername, oconnPassword;
            String mailUsername, mailPassword;
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
            sess = request.getSession(false);
            if(sess!=null){
                email = sess.getAttribute("email").toString();
                mname = sess.getAttribute("mname").toString();
            }
            mcategory = request.getParameter("mcategory"); 
            if(request.getParameter("submit")!=null){
                try{
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                    query = "SELECT NVL((SELECT * FROM (SELECT MID FROM MEDICINE ORDER BY MID DESC) WHERE ROWNUM <=1),'0') AS MID FROM DUAL";
                    ops = (OraclePreparedStatement) oconn.prepareCall(query);
                    ors = (OracleResultSet) ops.executeQuery();
                    ors.next();
                    //Getting the last MID from the database
                    String lastMID = ors.getString("MID");   
                    if(lastMID.equals("0"))
                    {
                        mid = "M0001";                    
                    }
                    else
                    {
                        //Getting the MID number
                        int lastMIDNum = Integer.parseInt(lastMID.substring(1));
                        midNum = ""+(lastMIDNum+1);
                        //Setting the new MID
                        if(Integer.parseInt(midNum)<10)
                            mid = "M000"+midNum;
                        else if(Integer.parseInt(midNum)<100)
                            mid = "M00"+midNum;
                        else if(Integer.parseInt(midNum)<1000)
                            mid = "M0"+midNum;
                        else
                            mid = "M"+midNum;
                    }
                    query = "INSERT INTO MEDICINE (MID,MNAME,MCAT) VALUES(?,?,?)";
                    ops = (OraclePreparedStatement) oconn.prepareCall(query);
                    ops.setString(1,mid);
                    ops.setString(2,mname);
                    ops.setString(3,mcategory);
                    int x = ops.executeUpdate();
                    if(x>0){                        
                %>
                            <script>
                                alert("Medicine Inserted Successfully!!");
                                alert("Redirecting You to Add Medicine Page, add this new medicine now!!")
                                location.href="http://localhost:8080/MinorWebApp/PageServes/AddMedicine.jsp";
                            </script>
                    <%      to = mailUsername;
                            subject = "REVIEW NEW MEDICINE ADDED";
                            body = "New Medicine added to MEDICINE table by PHARMACY bearing the email: "+email+"\nPlease review this new medicine.\nNew medicine name: "+mname;
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
                        }   
                        else{
                %>
                            <script>
                                alert("No changes in the MEDICINE table!!!");
                                location.href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html";

                            </script>
                <%
                        }
                }catch (SQLException ex) {
                    out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
                }
            }
        %>
    </body>
</html>
