/**
 * An apex page controller that exposes the change password functionality June 28
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public String changePassword {get; set;} 
        Account acc = [select id, name from Account Limit 1]; 

    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
     public ChangePasswordController() {
        //return Site.verifyNewPassword (newPassword, changePassword , oldpassword);    

     }
     public void standard() {
     list<Account>listOfAccounts = [select id, name from account limit 100];
    // iteration over the list of accounts
    for(Account Acc : listOfAccounts){
    //your logic
    }
}
}