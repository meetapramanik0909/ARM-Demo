/**
 * An apex page controller that exposes the change password functionality June 28
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public String changePassword {get; set;} 
        
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
     public ChangePasswordController() {
        //return Site.verifyNewPassword (newPassword, changePassword , oldpassword);    

     }
     public static void  test_ChangePasswordController2() {
         //return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    

     }
}