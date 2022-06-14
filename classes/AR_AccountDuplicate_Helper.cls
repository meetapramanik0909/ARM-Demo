/*-----------------------------------------------------------------------------------------
 * Class Name:AR_AccountDuplicate_Helper
 * Description: This Class have been used to find and duplicate account creation.1121
 * Date: 04/08/2020
 * Author: Meeta Pramanik 
------------------------------------------------------------------------------------------*/
public class AR_AccountDuplicate_Helper {
    //Added a comment for UST 03
    //modified to test
       Public List<Account> CreateAccount(String s, String p){
        List<Account> a = new List<Account>();
            for(Account Acc:a)
            {
                Acc.Name=s;
                Acc.phone=p;
                insert a;
            }
        return a;
    }
}