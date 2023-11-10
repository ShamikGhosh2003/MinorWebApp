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

@WebServlet(name = "AddToCart", urlPatterns = {"/AddToCart"})
public class AddToCart extends HttpServlet {

    String btnval,table,userType,status="CART",qty,oid,oidNum,cid,pid,mid,tbQty;
    OracleConnection oconn;
    OraclePreparedStatement ops;
    OracleResultSet ors;
    String query = "SELECT NVL((SELECT * FROM (SELECT OID FROM ORDERS ORDER BY OID DESC) WHERE ROWNUM <=1),'0') AS OID FROM DUAL";
    
    // Oconn connection handling, change the classname in the try line: classname.class.getClassLoader()
    private String oconnUrl;
    private String oconnUsername;
    private String oconnPassword;

    @Override
    public void init() throws ServletException {
        super.init();

        try (InputStream input = RegisterPharmacy.class.getClassLoader().getResourceAsStream("db.properties")) {
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
            throws ServletException, IOException, SQLException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AddToCart</title>");            
            out.println("</head>");
            out.println("<body>");
            /*HttpSession sess = request.getSession(false);
            if(sess!=null)
                userType = sess.getAttribute("userType").toString();*/
            btnval = request.getParameter("cart");
            qty = request.getParameter(btnval);
            int i = btnval.indexOf(",");
            table = btnval.substring(0,i);
            int j = btnval.indexOf(",",i+1);
            int k = btnval.indexOf(",",j+1);
            int l = btnval.lastIndexOf(",");
            cid = btnval.substring(i+1,j);
            tbQty = btnval.substring(j+1,k);
            pid = btnval.substring(k+1,l);
            mid = btnval.substring(l+1);
            if(Integer.parseInt(tbQty)<Integer.parseInt(qty)){
                out.println("<script>");
                out.println("alert('Number of items is greater than stock, try again!');");
                out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp';");
                out.println("</script>");
            }else{                
                try {
                    DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
                    oconn = (OracleConnection) DriverManager.getConnection(oconnUrl, oconnUsername, oconnPassword);
                    ops = (OraclePreparedStatement) oconn.prepareCall(query);
                    ors = (OracleResultSet) ops.executeQuery();
                    ors.next();
                    String lastOID = ors.getString("OID");   
                    if(lastOID.equals("0"))
                    {
                        oid = "O1000000000";
                    }           
                    else
                    {
                        //Getting the PID number
                        int lastOIDNum = Integer.parseInt(lastOID.substring(1));
                        oidNum = ""+(lastOIDNum+1);
                        //Setting the new PID
                        oid = "O"+oidNum;
                    }
                    query = "INSERT INTO "+table+" (OID,CID,PID,MID,QTY,STATUS) VALUES(?,?,?,?,?,?)";
                    ops = (OraclePreparedStatement) oconn.prepareCall(query);
                    ops.setString(1, oid);
                    ops.setString(2, cid);
                    ops.setString(3, pid);
                    ops.setString(4, mid);
                    ops.setString(5, qty);
                    ops.setString(6, status);
                    int x = ops.executeUpdate();
                    if(x>0){
                        out.println("<script>");
                        out.println("alert('Item added to Cart');");
                        out.println("location.href='http://localhost:8080/MinorWebApp/PageServes/SearchMedicine.jsp';");
                        out.println("</script>");
                    }else{
                        out.println("<script>");
                        out.println("alert('No changes to the database');");
                        out.println("</script>");
                    }
                }catch (SQLException ex) {
                    Logger.getLogger(RegisterPharmacy.class.getName()).log(Level.SEVERE, null, ex);
                    out.println("<h2 style='color:red'>Error is: "+ ex.toString() + "</h2>");
                }
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
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(AddToCart.class.getName()).log(Level.SEVERE, null, ex);
        }
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
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(AddToCart.class.getName()).log(Level.SEVERE, null, ex);
        }
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