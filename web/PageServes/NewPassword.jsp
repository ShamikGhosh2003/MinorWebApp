<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Password Reset Page</title>
    </head>
    <body style="background-color: blue">
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
                    email = sess1.getAttribute("email").toString();
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
                    if(sess!=null)
                        userType = sess.getAttribute("userType").toString();
                    if(userType.equals("CUSTOMER"))
                        table = "CUSTOMER";
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
        <form>
            <div>
                <br/><br/><br/><br/>
                <table border="1" style="font-size: 100%; color:whitesmoke; background-color: black">
                    <thead>
                        <tr><th colspan="2">RESET YOUR PASSWORD</th></tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>NEW PASSWORD</td>
                            <td><input type="password" name="tpass" id="tpass" required></td>
                        </tr>
                        <tr>
                            <td>CONFIRM PASSWORD</td>
                            <td><input type="password" name="cpass" id="cpass" required></td>
                        </tr>
                        <tr><td><button type="submit" style="font-size: 50%" name="bConfirm">Confirm</button></td>
                            <td>
                                <button type="reset" style="font-size: 50%" name="bClear">Clear</button>
                            </td>
                    </tbody>
                    <tfoot>
                        <th  colspan="2"> &copy; TECHNO INDIA TECHNOLOGIES &reg;</th>
                    </tfoot>
                </table>
            </div>
        </form>
    </body>
</html>
