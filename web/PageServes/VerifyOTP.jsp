<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="../stylesheet/main-style.css">
        <title>Verify OTP JSP</title>        
    </head>
    <body>
        <%!
            String otp,email;
            HttpSession sess;
        %>
        <%
            sess = request.getSession(false);
            if(sess!=null){
                otp = sess.getAttribute("otp").toString();
                email = sess.getAttribute("email").toString();
            } 
            if(request.getParameter("submit")!=null){
                if(request.getParameter("Totp").equals(otp))
                {
        %>
                    <script>
                        alert("OTP verified successfully!!!");
                        alert("Your Order is placed successfully!");
                        location.href="http://localhost:8080/WebApp1/PageServes/SearchMedicine.jsp";
                    </script>
        <%
                }
                else{
        %>
                    <script>
                        alert("Wrong OTP, Try again!!!");
                        alert("Your registered email id is: "+<%=email%>);
                    </script>
        <%
                    }
                }  
        %>
        <header>           
            <a href="#" class="heading">MedFinder</a>
            <nav class="navbar">
            <a href="SearchMedicine.jsp">Home</a>
            <a href="registerUser.html">Register</a>
            <a href="about.html">About Us</a>
            <a href="#">Contact</a>
            </nav>
        </header>
        <div class="form-container">
            <div class="form-box" style="width: 45%;">
                <form method="POST" name="register">
                    <h2 style="text-align: center;">VERIFY OTP</h2>
                    <br>
                    <div id="error-alert" style="color: red; text-align: center; font-weight: bold;"></div>
                    <div class="input-group">
                        <label for="Totp">Enter OTP:</label>
                        <input type="number" id="mname" size="4" name="Totp" required/>
                    </div>
                    <br>
                    <div class="input-group button-group">
                        <label></label>
                        <button type="submit" class="button-80" name="submit">Submit</button>
                        <button type="reset" class="button-80">Clear</button>
                   </div> 
                </form>
            </div>
        </div>
    </body>
</html>
