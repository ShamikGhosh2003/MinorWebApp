
package Webpack;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.OraclePreparedStatement;
import oracle.jdbc.OracleResultSet;


@WebServlet(name = "RegisterUser", urlPatterns = {"/RegisterUser"})
public class RegisterUser extends HttpServlet {
    String cid, fname, lname, email, phone, address, pincode, password, gender, age, sques, sans, cidNum, city;
    String query = "SELECT NVL((SELECT * FROM (SELECT CID FROM CUSTOMER ORDER BY CID DESC) WHERE ROWNUM <=1),'0') AS CID FROM DUAL";
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors;
    
    // Oconn connection handling, change the classname in the try line: classname.class.getClassLoader()
    private String oconnUrl;
    private String oconnUsername;
    private String oconnPassword;

    @Override
    public void init() throws ServletException {
        super.init();

        try (InputStream input = RegisterUser.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties props = new Properties();
            props.load(input);
            oconnUrl = "jdbc:oracle:thin:@" + props.getProperty("hostname") + ":"
                  + props.getProperty("port") + ":" + props.getProperty("SID");
            oconnUsername = props.getProperty("username");
            oconnPassword = props.getProperty("password");
        } catch (IOException ex) {
            throw new ServletException(ex);
        }
    }
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet register</title>");            
            out.println("</head>");
            out.println("<body>");
            email = request.getParameter("email");
            password = request.getParameter("password");
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
            try {
                DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                ops = (OraclePreparedStatement) oconn.prepareCall(query);
                ors = (OracleResultSet) ops.executeQuery();
                ors.next();
                //Getting the last CID in the database
                String lastCID = ors.getString("CID");   
                if(lastCID.equals("0"))
                {
                    cid = "C1000";                    
                }
                else
                {
                    //Getting the CID number
                    int lastCIDNum = Integer.parseInt(lastCID.substring(1));
                    cidNum = ""+(lastCIDNum+1);
                    //Setting the new CID
                    cid = "C"+cidNum;
                }
                email = email.toLowerCase();
                fname = fname.toUpperCase();
                lname = lname.toUpperCase();
                address = address.toUpperCase();
                //password = hash.passwordHash(password);
                out.println("<h1>Displaying the HTML input values in this servlet...</h1>");
                out.println("<h3>CID: "+cid+"</h3>");
                out.println("<h3>Email: "+email+"</h3>");
                out.println("<h3>Password: "+password+"</h3>");
                out.println("<h3>First Name: "+fname+"</h3>");
                out.println("<h3>Last Name: "+lname+"</h3>");
                out.println("<h3>Gender: "+gender+"</h3>");
                out.println("<h3>Age: "+age+"</h3>");
                out.println("<h3>Address: "+address+"</h3>");
                out.println("<h3>City: "+city+"</h3>");
                out.println("<h3>Phone: "+phone+"</h3>");
                out.println("<h3>Pincode: "+pincode+"</h3>");
                out.println("<h3>Security Question: "+sques+"</h3>");
                out.println("<h3>Security Answer: "+sans+"</h3>");                
                ops = (OraclePreparedStatement) oconn.prepareCall("INSERT INTO CUSTOMER(CID,EMAIL,PASSWORD,FNAME,LNAME,GENDER,AGE,ADDRESS,PHONE,PINCODE,SQUES,SANS,CITY) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)");
                ops.setString(1,cid);
                ops.setString(2,email);
                ops.setString(3,password);
                ops.setString(4,fname);
                ops.setString(5,lname);
                ops.setString(6,gender);
                ops.setString(7,age);
                ops.setString(8,address);
                ops.setString(9,phone);
                ops.setString(10,pincode);
                ops.setString(11,sques);
                ops.setString(12,sans); 
                ops.setString(13,city); 
                int x = ops.executeUpdate();
                if(x>0)
                    out.println("<h3 style='color:green'>Data inserted Successfully....</h3>");
                else
                    out.println("<h3 style='color:Red'>No Data Changes....</h3>");
                
                oconn.close();
                ops.close();
            } catch (SQLException ex) {
                Logger.getLogger(RegisterUser.class.getName()).log(Level.SEVERE, null, ex);
                out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
            }
            
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
