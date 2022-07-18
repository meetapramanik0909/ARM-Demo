/**
 * An apex page controller that exposes the change password functionality July 18
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public String changePassword {get; set;} 
        Account acc = [select id, name from Account Limit 10]; 

    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
     public ChangePasswordController() {
        //return Site.verifyNewPassword (newPassword, changePassword , oldpassword);    

     }
     
}