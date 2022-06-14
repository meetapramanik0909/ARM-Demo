/********THis is a Trailheads Module Component******
 * Created Date - April 2020
 * Author - Meeta Pramanik***********************
**/

public class RandomContactFactory{
    public static List<Contact> generateRandomContacts(Integer noOfCon, String conLstNm){
        List<Contact> lstOfConts = new List<Contact>();
        for(Integer i = 1; i <= noOfCon; i++){            
            Contact con = new Contact(FirstName = 'Test '+i, LastName = conLstNm);
            lstOfConts.add(con);
        }
        
        return lstOfConts;
    }
}