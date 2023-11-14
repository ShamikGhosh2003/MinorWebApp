<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Edit Customer</title>
        <script src="/MinorWebApp/scripts/showResponse.js"></script>
        <script>
            window.onload = function() {
                document.forms['register'].addEventListener('submit', function(event) {
                    if(!validateForm()) {
                        event.preventDefault();
                    } else {
                        window.location.hash = '';
                    }
                });
            };
            
            function validateForm() {
                var fname = document.forms['register']['fname'].value;
                var lname = document.forms['register']['lname'].value;
                //var email = document.forms['register']['email'].value;
                var phone = document.forms['register']['phone'].value;
                var age = document.forms['register']['age'].value;
                var address = document.forms['register']['address'].value;
                var city = document.forms['register']['city'].value;
                var pincode = document.forms['register']['pincode'].value;
                var gender = document.forms['register']['gender'].value;
                var sques = document.forms['register']['sques'].value;
                var sans = document.forms['register']['sans'].value;
                var password = document.forms['register']['password'].value;
                var confirmPassword = document.forms['register']['confirm-password'].value;
        
                if(fname === "" || lname === "" || phone === "" || age === "" || address === "" || city === "" || pincode === "" || gender === "" || sques === "" || sans === "" || password === "" || confirmPassword === "") {
                    showError("All fields are required.");
                    return false;
                }
                if(phone.length !== 10 || isNaN(phone)) {
                    showError("Please a enter valid phone number.");
                    return false;
                }
                if(pincode.length !== 6 || isNaN(pincode)) {
                    showError("Please enter a valid pincode.");
                    return false;
                }
                if(password.length < 8) {
                    showError("Password must be at least 8 characters.");
                    return false;
                }
                if(password !== confirmPassword) {
                    showError("Passwords do not match.");
                    return false;
                }
                return true;
            }

            function maxInputNumber(element, maxLength) {
                if(element.value.length > maxLength) {
                    element.value = element.value.slice(0, maxLength);
                }
            }
        </script>        
    </head>
    <body>
        <%! 
        OracleConnection oconn;
        OraclePreparedStatement ops;
        OracleResultSet ors; //Store the data in the webpage from oracle
        OracleResultSetMetaData orsm;
        String query, email, userType, btnval, table, cid, cemail, password, fname, lname, gender, age, address, phone, pincode, sques, sans, city;
        java.util.Properties props = new java.util.Properties();
        HttpSession sess;
        String oconnUrl, oconnUsername, oconnPassword;
    %>
    <%
        try{
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
        if(sess!=null){
            email = sess.getAttribute("email").toString();
            userType = sess.getAttribute("userType").toString();
        }
        if(request.getParameter("submit")==null){
            btnval = request.getParameter("Modify");
            int i = btnval.indexOf(",");
            table = btnval.substring(0,i);
            cid = btnval.substring(i+1);
        }
        try{
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);        
            query = "SELECT * FROM CUSTOMER WHERE CID = ?";
            ops = (OraclePreparedStatement) oconn.prepareCall(query);
            ops.setString(1, cid);
            ors = (OracleResultSet) ops.executeQuery();
            ors.next();
            cemail = ors.getString("EMAIL");
            fname = ors.getString("FNAME");
            lname = ors.getString("LNAME");
            gender = ors.getString("GENDER");
            age = ors.getString("AGE");
            address = ors.getString("ADDRESS");
            phone = ors.getString("PHONE");
            pincode = ors.getString("PINCODE");
            sques = ors.getString("SQUES");
            sans = ors.getString("SANS");
            city = ors.getString("CITY");
            password = ors.getString("PASSWORD");

            if(request.getParameter("submit")!=null){
                fname = request.getParameter("fname");
                lname = request.getParameter("lname");
                gender = request.getParameter("gender");
                age = request.getParameter("age");
                address = request.getParameter("address");
                phone = request.getParameter("phone");
                pincode = request.getParameter("pincode");
                sques = request.getParameter("sques");
                sans = request.getParameter("sans");
                city = request.getParameter("city");
                if(userType.equals("ADMIN"))
                   password = request.getParameter("password");
                if(userType.equals("CUSTOMER"))
                    query = "UPDATE CUSTOMER SET FNAME = ?, LNAME = ?, GENDER = ?, AGE = ?, ADDRESS = ?, PHONE = ?, PINCODE = ?, SQUES = ?, SANS = ?, CITY = ? WHERE CID = ?";
                else
                    query = "UPDATE CUSTOMER SET FNAME = ?, LNAME = ?, GENDER = ?, AGE = ?, ADDRESS = ?, PHONE = ?, PINCODE = ?, SQUES = ?, SANS = ?, CITY = ?, PASSWORD = ? WHERE CID = ?";

                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ops.setString(1, fname);
                ops.setString(2, lname);
                ops.setString(3, gender);
                ops.setString(4, age);
                ops.setString(5, address);
                ops.setString(6, phone);
                ops.setString(7, pincode);
                ops.setString(8, sques);
                ops.setString(9, sans);
                ops.setString(10, city);                        
                if(userType.equals("ADMIN")){
                    ops.setString(11, password);
                    ops.setString(12, cid);
                }else{
                    ops.setString(11, cid);
                }            
                int x = ops.executeUpdate();
                if(x>0){
                    if(userType.equals("ADMIN")){
        %>
                    <script>
                        alert("Data modified successfully!");
                        location.href="http://localhost:8080/MinorWebApp/PageServes/customer.jsp";
                    </script>
        <%
                    }else{
        %>
                    <script>
                        alert("Data modified successfully!");
                        //TODO Redirect to profile page of user.
                        //location.href="http://localhost:8080/MinorWebApp/PageServes/customer.jsp";
                    </script>
        <%
                    }
                }else{
                    if(userType.equals("ADMIN")){
        %>
                    <script>
                        alert("No changes to the database");
                        location.href="http://localhost:8080/MinorWebApp/PageServes/customer.jsp";
                    </script>
        <%
                    }else{
        %>
                    <script>
                        alert("No changes to the database");
                        //TODO Redirect to profile page of user.
                        //location.href="http://localhost:8080/MinorWebApp/PageServes/customer.jsp";
                    </script>
        <%
                    }
                    oconn.close();
                    ops.close();
                }
            }else{
                
                //sess.setAttribute("btnval", btnval);
            }
        }catch(SQLException ex){
            out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
        }
    %>
        <header>
            <img src="http://localhost:8080/MinorWebApp/media/logo.png" class="logo">
            <span class="heading">MedFinder</span>
            <nav class="navbar">
            <a href="index.html">Home</a>
            <a href="registerUser.html">Register</a>
            <a href="about.html">About Us</a>
            <a href="#">Contact</a>
            <a href="http://localhost:8080/MinorWebApp/SessLogOut">Log Out</a>
            </nav>
        </header>
        <main>
            <div class="form-container">
                <div class="form-box">
                    <form method="POST" name="register">
                        <h2>Edit Customer Details</h2>
                        <br>
                        <div id="error-alert"></div>
                        <br>
                        <%
                            if(userType.equals("ADMIN")){
                        %>
                          <br>
                          <div class="input-group">
                            <label for="cid">Customer ID:</label>
                            <input type="text" id="cid" name="cid" value="<%=cid%>" readonly/>
                          </div>
                        <%
                            }
                        %>
                        <div class="input-group">
                            <label for="email">Email:</label>
                            <input type="email" id="email" name="email" value="<%=cemail%>" readonly/>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="fname">First Name:</label>
                            <input type="text" id="fname" name="fname" value="<%=fname%>" placeholder="<%=fname%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="lname">Last Name:</label>
                            <input type="text" id ="lname" name="lname" value="<%=lname%>" placeholder="<%=lname%>">
                        </div>
                        <br>                        
                        <div class="input-group">
                            <label for="phone">Phone:</label>
                            <input type="text" id="phone" name="phone" value="<%=phone%>" placeholder="<%=phone%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="age">Age:</label>
                            <input type="text" name="age" value="<%=age%>" placeholder="<%=age%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="address">Address:</label>
                            <input type="text" name="address" value="<%=address%>" placeholder="<%=address%>">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="city">City:</label>
                            <select id="city" name="city">
                                <option value="" selected disabled hidden>Select a city</option>
                                <option value="KOLKATA">Kolkata</option>
                                <option value="HOWRAH">Howrah</option>
                                <option value="BURDWAN">Burdwan</option>
                                <option value="DURGAPUR">Durgapur</option>
                            </select>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="pincode">Pincode:</label>
                            <input type="number" name="pincode" value="<%=pincode%>" placeholder="<%=pincode%>" oninput="maxInputNumber(this,6)">
                        </div>
                        <br>
                        <div class="input-group radio-group">
                        <label for="gender">Gender: </label>
                        <%
                            if(gender.equals("M")){
                        %>                        
                            <input type="radio" name="gender" value="M" checked/>Male
                            <input type="radio" name="gender" value="F">Female
                        <%
                            }else{
                        %>
                            <input type="radio" name="gender" value="M">Male
                            <input type="radio" name="gender" value="F" checked/>Female
                        <%
                            }
                        %>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="sques">Security Question:</label>
                            <select id="sques" name="sques" >
                                <option value="" selected disabled hidden>Select Security Question</option>
                                <option value="CHILDHOOD NICKNAME?">Childhood nickname?</option>
                                <option value="WHAT IS YOUR MOTHER'S MAIDEN NAME?">What is your mother's maiden name?</option>
                                <option value="WHAT SCHOOL DID YOU GO TO?">What school did you go to?</option>
                            </select>
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="sans">Security Answer:</label>
                            <input type="text" name="sans" id="sans" value="<%=sans%>" placeholder="<%=sans%>">
                        </div>
                        <%                        
                            if(userType.equals("ADMIN")){
                        %>                        
                        <br>
                        <div class="input-group">
                            <label for="password">Password:</label>
                            <input type="password" name="password" value="<%=password%>" placeholder="********">
                        </div>
                        <br>
                        <div class="input-group">
                            <label for="confirm-password">Confirm password:</label>
                            <input type="password" name="confirm-password" value="<%=password%>" placeholder="********">
                        </div> 
                        <%
                            }
                        %>                        
                        <br>    
                        <div class="input-group button-group">
                            <label></label>
                            <button type="submit" name="submit" class="button-80">Submit</button>
                            <button type="reset" class="button-80">Clear</button>
                    </div>
                    </form>
                </div>
            </div>
        </main>
    </body>
</html>

