<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Properties"%>
<%@page import="java.io.InputStream"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="main-style.css">
        <title>Register</title>
        <script>
            function validateForm() {
               var mname = document.forms['register']['mname'].value;
               if(mname === ""){
                    document.getElementById('error-alert').innerHTML = "Fields is required.";
                    event.preventDefault();
               }
           }
       </script>
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
        <div class="form-container">
            <div class="form-box" style="width: 45%;">
                <form method="POST" name="register" onsubmit="validateForm()">
                    <h2 style="text-align: center;">ADD MEDICINE</h2>
                    <br>
                    <div id="error-alert" style="color: red; text-align: center; font-weight: bold;"></div>
                    <div class="input-group">
                        <label for="mname">Medicine Name:</label>
                        <input type="text" name="mname" placeholder="Enter a new Medicine" required>
                    </div>
                    <br>
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" name="submit" class="button-80">Submit</button>
                        <button type="reset" class="button-80">Clear</button>
                   </div>              
                </form>
            </div>
        </div>
        <%!
            String mname, query, mid, email, pid, pname;
            OracleConnection oconn;
            OraclePreparedStatement ops;
            OracleResultSet ors = null;           
            HttpSession sess;
            String oconnUrl, oconnUsername, oconnPassword;
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
            if(request.getParameter("submit")!=null){
                sess = request.getSession(false);
                if(sess!=null)
                    email = sess.getAttribute("email").toString();
                mname = request.getParameter("mname");
                sess.setAttribute("mname",mname);
                //mname = mname.toUpperCase();
                try{
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                    query = "SELECT * FROM PHARM_MED_STOCK WHERE MID = (SELECT MID FROM MEDICINE WHERE MNAME = ?) AND PID = (SELECT PID FROM PHARMACY WHERE EMAIL = ?)";
                    ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                    ops.setString(1,mname);
                    ops.setString(2,email);
                    ors = (OracleResultSet)ops.executeQuery();
                    if(ors.next())
                    {
            %>
                        <script>
                            alert("The medicine already exisits in your stock!!");
                            location.href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html";
                        </script>
            <%
                    }else{
                        query = "SELECT * FROM MEDICINE WHERE MNAME = ?";
                        ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                        ops.setString(1,mname);
                        ors = (OracleResultSet)ops.executeQuery();
                        if(ors.next())
                        {
                            mid = ors.getString("MID");
                            query = "SELECT * FROM PHARMACY WHERE EMAIL = ?";
                            ops = (OraclePreparedStatement) oconn.prepareStatement(query);
                            ops.setString(1,email);
                            ors = (OracleResultSet) ops.executeQuery();
                            ors.next();
                            pid = ors.getString("PID");
                            query = "INSERT INTO PHARM_MED_STOCK (PID, MID) VALUES (?,?)";
                            ops = (OraclePreparedStatement) oconn.prepareCall(query);
                            ops.setString(1,pid);
                            ops.setString(2,mid);
                            int x = ops.executeUpdate();
                            if(x>0){
                    %>
                                <script>
                                    alert("Data Inserted Successfully!!");
                                    location.href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html";
                                </script>
                    <%
                            }   
                            else{
                    %>
                                <script>
                                    alert("No changes in the PHARM_MED_STOCK database!!!");
                                    location.href="http://localhost:8080/MinorWebApp/StatPages/PharmacyHome.html";

                                </script>
                    <%
                            }
                        }    
                        else{
                    %>
                            <script>
                                alert("Medicine does not exist in Medicine database of the website!!");
                                alert("Directing you to Add New Medicine Registration page");
                                //Change the link here or make a system so it automatically creates a new medicine in the database
                                location.href="http://localhost:8080/MinorWebApp/PageServes/AddNewMedicine.jsp";
                            </script>
                    <%            
                        }
                    }
                }catch (SQLException ex) {
                    out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
                }
            }
        %>
    </body>
</html>

