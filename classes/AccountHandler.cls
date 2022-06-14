/*-----------------------------------------------------------------------------------------
 * Class Name:AccountHandler
 * Description: This Class have been used to find and duplicate account creation.
 * Date: 04/08/2020
 * Author: Meeta Pramanik dfdsase
test Comment
----------------------------------------- -------------------------------------------------*/
/*----------Metho Name AdditionsaSSDSAD----------*/
public class AccountHandler {
//09 Sep for Demo

    public static Account insertNewAccount(String name) {
        Account a = new Account();
        a.Name = name;
        try
        {
            insert a;
        } catch (Exception e) {
            return null;
        }
        return a;
    }
//Updated a comment on April 06
}