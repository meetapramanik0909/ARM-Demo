/**
 * An apex page controller that exposes the site forgot password functionality // 3/05 description
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}  
    //added comment on June 08    
    public ForgotPasswordController() {}
    
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username); //store variables
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        if (success) {              
            return pr;
        }
        return null;
    }
}