<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>VerifyQuestion JSP</title>
        <script>
            function funClose()
            {
                if(window.parent) 
                    if(confirm("Closing window......") === true)  
                        window.parent.window.close();    
                else if(confirm("Closing window......") === true) 
                    window.close();   
            }
        </script>
    </head>
    <body style="background-color: antiquewhite">
        <%! 
            String email, ques, ans, userType, table, query;
            OracleConnection oconn;
            OraclePreparedStatement ops;
            OracleResultSet ors = null;
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
            
            email = request.getParameter("pemail");
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            oconn = (OracleConnection) DriverManager.getConnection(oconnUrl,oconnUsername,oconnPassword);
            HttpSession sess = request.getSession(false);
            if(sess!=null)
            {
                userType = sess.getAttribute("userType").toString();
            }
            if(userType.equals("CUSTOMER"))
                table = "CUSTOMER";
            if(userType.equals("PHARMACY"))
                table = "PHARMACY";
            query = "SELECT * FROM "+table+" WHERE EMAIL=?";
            ops = (OraclePreparedStatement) oconn.prepareStatement(query);
            ops.setString(1,email);
            ors = (OracleResultSet) ops.executeQuery();
            if(ors.next())
            {
                ques = ors.getString("SQUES");
                ans = ors.getString("SANS");
            }
            else
            {
                %>
                <script>
                    alert("Do not try any malaligned URL. \nYou can only use the link received in email");
                    window.close();
                </script>
                <%
            }
            ops.close();
            oconn.close();
            if(request.getParameter("bVerify")!=null)
            {
                if(request.getParameter("tbAns").equals(ans))
                {
                %>
                <script>
                    alert("Security Answer verified Successfully!!!");
                    location.href="http://localhost:8080/MinorWebApp/PageServes/NewPassword.jsp?pemail=<%=email%>";
                </script>
                <%
                }
                else
                {
                    %>
                    <h3 style="color: red">Wrong Answer. Please Try Again!!</h3>
                    <%
                }
            }
            else
            {
                %>
                <h3 style="color: blueviolet">Please verify your security credentials</h3>
                <%
            }
            %>

        <h2>THIS IS A SECURITY QUESTION AND ANSWER VERIFICATION PAGE!</h2>
        <form name="frmSecurity" method="POST" action="http://localhost:8080/MinorWebApp/PageServes/VerifyQuestion.jsp?pemail=<%=email%>">
            <div>
                <table border="1">
                    <thead>
                        <tr><th colspan="2">SECURITY VERIFICATION FORM</th></tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>QUESTION</td>
                            <td><input type="text" size="30" name="tbQues" value="<%=ques%>" readonly /></td>
                        </tr>
                        <tr>
                            <td>ANSWER</td>
                            <td><input type="text" size="30" name="tbAns" required/></td>
                        </tr>
                        <tr>
                            <td>
                                <button type="submit" name="bVerify">Verify</button>
                            </td>
                            <td>
                                <button type="reset" name="bReset">Reset</button>
                                <button type="button" name="bClose" onclick="funClose();">Close</button>
                            </td>
                        </tr>
                    </tbody>
                    <tfoot>
                        <tr><th colspan="2">&copy;Techno India Technologies ; Limited &reg;</th></tr>
                    </tfoot>
                </table>
            </div>
        </form>
    </body>
</html>
