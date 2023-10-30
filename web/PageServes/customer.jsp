<%-- 
    Document   : customer
    Created on : 30 Oct, 2023, 3:26:13 AM
    Author     : ADMIN
--%>

<%@page import="java.sql.DriverManager"%>
<%@page import="oracle.jdbc.OracleResultSetMetaData"%>
<%@page import="oracle.jdbc.OracleResultSet"%>
<%@page import="oracle.jdbc.OraclePreparedStatement"%>
<%@page import="oracle.jdbc.OracleConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Customer Displayer JSP</title>
        <style>
            table,tr,td
            {
                padding: 10px;
                border: 5px solid yellow;
                border-collapse: collapse;
                color: white;
            }
            th{
                padding: 10px;
                border: 5px solid greenyellow;
                border-collapse: collapse;
                color: chartreuse;
            }
        </style>
    </head>
    <%! 
        //DECLARATION
        OracleConnection oconn;
        OraclePreparedStatement ops;
        OracleResultSet ors; //Store the data in the webpage from oracle
        OracleResultSetMetaData orsm;
        int reccounter; //record counter
        String query;        
    %>
    <body style="background-color: black; color: belge;">
        <!--STAGE3: REGISTERING THE DRIVER MANAGER-->
        <%
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());

            //STAGE4: INSTANTIATING THE ORACLE OBJECTS
            oconn = (OracleConnection) DriverManager.getConnection("jdbc:oracle:thin:@DESKTOP-CPL2IQA:1521:orcl","MINOR","DATABASE");

            //STAGE5: CREATING THE QUERY
            query = "SELECT * FROM CUSTOMER ORDER BY CID ASC";

            //STAGE6: INSTATNTIATING THE STATEMENT OBJECT
            ops = (OraclePreparedStatement) oconn.prepareCall(query);

            //STAGE7: EXECTUTING THE QUERY AND HENCE FETCHING THE DATA
            ors = (OracleResultSet) ops.executeQuery();

            //STAGE8: GETTING THE META DATA
            orsm = (OracleResultSetMetaData) ors.getMetaData();
        %>
        <!-- STAGE1: TABLE CREATION -->
        <table>
            <thead>
                <%
                    for(int i=1; i<=orsm.getColumnCount(); i++)
                    {
                %>
                <th><%=orsm.getColumnName(i)%></th>
                <%
                    }
                %>
                <th>ACTIONS</th>            
            </thead>
            <tbody>
                <%  
                    // STEP10: GENERATING THE RECORDS(ROWS)
                    while(ors.next()==true) //To check if a row is available
                    {
                %>
                <tr>
                    <%
                        // STEP11: GENERATING COLUMN DATA FOR EACH RECORD
                        for(int i=1; i<=orsm.getColumnCount(); i++) //To get the column
                        {
                    %>
                    <td><%=ors.getString(i)%></td>
                    <% 
                        }
                    %>
                    <td>
                        <form>
                            <button type="button" name="Modify">MODIFY</button>
                            <button type="submit" name="Delete">DELETE</button>
                        </form>
                    </td>
                </tr>    
                <% 
                    }
                %>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="11">&copy;MedFinder&reg;</th>
                </tr>
            </tfoot>
        </table>
    </body>
</html>
