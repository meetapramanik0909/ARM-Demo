/****************************************
Created Date: 06/12/21
Last Modified By: Meeta Pramanik
Comments: UST-001/Sp-21001
Description : sample class for Demo purpose only
Last Modified Date: 06/12/21
*****************************************/

public with sharing class WrapperExampleController 
{
// the list of accounts that will be displayed in the page
private List<Account> accs;

// the list of row wrappers that contain a transposed view of the account
private List<RowWrapper> rows;

// the footers for the row wrappers table
private RowWrapper footers;

// retrieves the list of accounts backing the page
    public List<Account> getAccounts()
        {
        if (null==accs)
        {
            accs=[select id, Name, BillingStreet, BillingCity, BillingPostalCode from Account 
            where BillingCity != null and BillingPostalCode!=null limit 3];
            }
        
        return accs; 
    }

    // retrieves the row wrapper containing the wrapped account Footings
    public RowWrapper getFootWrap()
    {
    // set up the footers
        if (null==footers)
            {
                footers=new RowWrapper();
                    for (Integer idx=1; idx<=getAccounts().size(); idx++)
                    {
                    footers.addValue('Account ' + idx);
                }
            }
                 
        return footers;
    }

    // retrieves the list of row wrappers
    public List<RowWrapper> getRowWrappers()
    {
        if (null==rows)
        {
            rows=new List<RowWrapper>();
            
            // create a row for each field - there are 4 of these, Name, Street, City and PostCode
            for (Integer idx=0; idx<4; idx++)
            {
        rows.add(new RowWrapper());
    }

    // iterate the accounts and populate the rows
    for (Integer idx=0; idx<getAccounts().size(); idx++)
    {
            rows[0].addValue(getAccounts()[idx].Name);
            rows[1].addValue(getAccounts()[idx].BillingStreet);
            rows[2].addValue(getAccounts()[idx].BillingCity);
            rows[3].addValue(getAccounts()[idx].BillingPostalCode);
            }
        }
        
        return rows;
    }
    /*****************************
    Created Date: 06/12/21
    Last Modified By: Meeta Pramanik
    Comments: UST-001/Sp-21001
    Description : Test Method
    *****************************/
    // nested class that wraps information about a row - in this case simply a list of strings 
    public class RowWrapper
        {
        // the values (cells) making up this row
        public List<String> values {get; set;}
        
        // constructor
            public RowWrapper()
            {
            values=new List<String>();
            }
            
            // append a value (cell) to the row
            public void addValue(String value)
            {
            values.add(value);
        }
    }
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/
    // Public method
    public void sendMail(String address, String subject, String body) {
        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        // Pass this email message to the built-in sendEmail method 
        // of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
             new Messaging.SingleEmailMessage[] { mail });
        
        // Call a helper method to inspect the returned results
        inspectResults(results);
    }
    
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/

    // Helper method
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
    Boolean sendResult = true;
    
    // sendEmail returns an array of result objects.
    // Iterate through the list to inspect results. 
    // In this class, the methods send only one email, 
    // so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
            System.debug('Email sent successfully');
            }
        else {
            sendResult = false;
            System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
        
        return sendResult;
    }
    
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/

    public void accCreate(){
    // Create the account sObject 
        Account acct = new Account(Name='Acme', Phone='(415)555-1212', NumberOfEmployees=100);
        // Insert the account by using DML
        insert acct;
        // Get the new ID on the inserted sObject argument
        ID acctID = acct.Id;
        // Display this ID in the debug log
        System.debug('ID = ' + acctID);
        // Debug log result (the ID will be different in your case)
        // DEBUG|ID = 001D000000JmKkeIAF
    }
    
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/

    public void accContact(){
    // Create a list of contacts
    List<Contact> conList = new List<Contact> {
    new Contact(FirstName='Joe',LastName='Smith',Department='Finance'),
    new Contact(FirstName='Kathy',LastName='Smith',Department='Technology'),
    new Contact(FirstName='Caroline',LastName='Roth',Department='Finance'),
    new Contact(FirstName='Kim',LastName='Shain',Department='Education')};
    
    // Bulk insert all contacts with one DML call
    insert conList;
    // List to hold the new contacts to update
    List<Contact> listToUpdate = new List<Contact>();
    // Iterate through the list and add a title only
    //   if the department is Finance
        for(Contact con : conList) {
            if (con.Department == 'Finance') {
            con.Title = 'Financial analyst';
            // Add updated contact sObject to the list.
            listToUpdate.add(con);
            }
        }
        // Bulk update all contacts with one DML call
        update listToUpdate;
        
    }
    
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/
        
    public void inSertContact(){
    // Insert the Josh contact
    Contact josh = new Contact(FirstName='Josh',LastName='Kaplan',Department='Finance');       
    insert josh;
    // Josh's record has been inserted
    //   so the variable josh has now an ID
    //   which will be used to match the records by upsert
    josh.Description = 'Josh\'s record has been updated by the upsert operation.';
    // Create the Kathy contact, but don't persist it in the database
    Contact kathy = new Contact(FirstName='Kathy',LastName='Brown',Department='Technology');
    // List to hold the new contacts to upsert
    List<Contact> contacts = new List<Contact> { josh, kathy };
    // Call upsert
    upsert contacts;
    // Result: Josh is updated and Kathy is created.
    
    }

        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/
        
    public void accContactDebug(){
    Contact jane = new Contact(FirstName='Jane',
    LastName='Smith',
    Email='jane.smith@example.com',
    Description='Contact of the day');
    insert jane;
    // 1. Upsert using an idLookup field
    // Create a second sObject variable.
    // This variable doesn’t have any ID set.
    Contact jane2 = new Contact(FirstName='Jane',
    LastName='Smith',  
    Email='jane.smith@example.com',
    Description='Prefers to be contacted by email.');
    // Upsert the contact by using the idLookup field for matching.
    upsert jane2 Contact.fields.Email;
    // Verify that the contact has been updated
    System.assertEquals('Prefers to be contacted by email.',
    [SELECT Description FROM Contact WHERE Id=:jane.Id].Description);
        try {
        // This causes an exception because 
        //   the required Name field is not provided.
        Account acct = new Account();
        // Insert the account 
        insert acct;
        } catch (DmlException e) {
        System.debug('A DML exception has occurred: ' +
        e.getMessage());
        }
    
    }
    
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/

    public void accContactDML(){
    // Create a list of contacts
    List<Contact> conList = new List<Contact> {
    new Contact(FirstName='Joe',LastName='Smith',Department='Finance'),
    new Contact(FirstName='Kathy',LastName='Smith',Department='Technology'),
    new Contact(FirstName='Caroline',LastName='Roth',Department='Finance'),
    new Contact()};
    
    // Bulk insert all contacts with one DML call
    Database.SaveResult[] srList = Database.insert(conList, false);
    // Iterate through each returned result
    for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
        // Operation was successful, so get the ID of the record that was processed
        System.debug('Successfully inserted contact. Contact ID: ' + sr.getId());
        } else {
        // Operation failed, so get all errors
            for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Contact fields that affected this error: ' + err.getFields());
            }
        }
    }
}

        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/

    public void accSFDCAcc(){
    Account acct = new Account(Name='SFDC Account');
    insert acct;
    // Once the account is inserted, the sObject will be 
    // populated with an ID.
    // Get this ID.
    ID acctID = acct.ID;
    // Add a contact to this account.
    Contact mario = new Contact(
    FirstName='Mario',
    LastName='Ruiz',
    Phone='415.555.1212',
    AccountId=acctID);
    insert mario;
    
    }
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/

    public void updateQueriedContact(){
    // Query for the contact, which has been associated with an account.
    Contact queriedContact = [SELECT Account.Name 
    FROM Contact 
    WHERE FirstName = 'Mario' AND LastName='Ruiz'
    LIMIT 1];
    // Update the contact's phone number
    queriedContact.Phone = '(415)555-1213';
    // Update the related account industry
    queriedContact.Account.Industry = 'Technology';
    // Make two separate calls 
    // 1. This call is to update the contact's phone.
    update queriedContact;
    // 2. This call is to update the related account's Industry field.
    update queriedContact.Account; 
    
    }
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/

    public void sfdcAccc(){
    Account acct = new Account(Name='SFDC Account');
    insert acct;
    // Once the account is inserted, the sObject will be 
    // populated with an ID.
    // Get this ID.
    ID acctID = acct.ID;
    // Add a contact to this account.
    Contact mario = new Contact(
    FirstName='Mario',
    LastName='Ruiz',
    Phone='415.555.1212',
    AccountId=acctID);
    insert mario;
    
    }
    
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/
    public void aqUerContact(){
        // Query for the contact, which has been associated with an account.
        Contact queriedContact = [SELECT Account.Name 
        FROM Contact 
        WHERE FirstName = 'Mario' AND LastName='Ruiz'
        LIMIT 1];
        // Update the contact's phone number
        queriedContact.Phone = '(415)555-1213';
        // Update the related account industry
        queriedContact.Account.Industry = 'Technology';
        // Make two separate calls 
        // 1. This call is to update the contact's phone.
        update queriedContact;
        // 2. This call is to update the related account's Industry field.
        update queriedContact.Account; 
    
    }
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/
    public void accContact45(){
        List<Account> ls = new List<Account>{new Account(name='Acme Inc.'),new Account(name='Acme')};
        insert ls;
        Account masterAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme Inc.' LIMIT 1];
        Account mergeAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme' LIMIT 1];
            try {
            merge masterAcct mergeAcct;
            } catch (DmlException e) {
            // Process exception here
            }
            
            }
        public static String getTaskPriority(String leadState) {
        // Validate input
        if (String.isBlank(leadState) || leadState.length() > 2) {
        return null;
        }
        
        String taskPriority;
        
            if (leadState == 'CA') {
            taskPriority = 'High'; 
            } else {
            taskPriority = 'Normal';
            }
        
        return taskPriority;
    }
    // Takes a Fahrenheit temperature and returns the Celsius equivalent.
    public static Decimal FahrenheitToCelsius(Decimal fh) {
    Decimal cs = (fh - 32) * 5/9;
    return cs.setScale(2);
    }
        public static Integer wilt(Integer numberOfPetals){
        if(numberOfPetals >= 1){
        numberOfPetals--;
        }
    return numberOfPetals;
    }
        public static void grow(Integer height, Integer maxHeight){
        height = height + 2;
        if(height >= maxHeight){
        pollinate();
        }
    }
    public static void pollinate(){
        System.debug('Pollinating...');
    }
    // Static final variable (constant) – outer class level only
    private static final Integer MY_INT;
    
    // Non-final static variable - use this to communicate state across triggers
    // within a single request)
    public static String sharedState;
    
    // Static method - outer class level only
    public static Integer getInt() { return MY_INT; }
    
    // Static initialization (can be included where the variable is defined)
    static {
    MY_INT = 2; 
    }
    
    // Member variable for outer class
    private final String m;
    
    // Instance initialization block - can be done where the variable is declared, 
    // or in a constructor
    {
    m = 'a';  
    }
    
    // Because no constructor is explicitly defined in this outer class, an implicit, 
    // no-argument, public constructor exists
    
    // Inner interface
    public virtual interface MyInterface { 
    
    // No access modifier is necessary for interface methods - these are always 
    // public or global depending on the interface visibility
    void myMethod(); 
    }
    
    // Interface extension
    interface MySecondInterface extends MyInterface { 
    Integer method2(Integer i); 
    }
    
    // Inner class - because it is virtual it can be extended.
    // This class implements an interface that, in turn, extends another interface.
    // Consequently the class must implement all methods.
    public virtual class InnerClass implements MySecondInterface {
    
    // Inner member variables
    private final String s;
    private final String s2;
    
    // Inner instance initialization block (this code could be located above)
    {
    this.s = 'x';
    }
    
    // Inline initialization (happens after the block above executes)
    private final Integer i = s.length();
    
    // Explicit no argument constructor
    InnerClass() {
    // This invokes another constructor that is defined later
    this('none');
    }
    
    // Constructor that assigns a final variable value
    public InnerClass(String s2) { 
    this.s2 = s2; 
    }
    
    // Instance method that implements a method from MyInterface.
    // Because it is declared virtual it can be overridden by a subclass.
    public virtual void myMethod() { /* does nothing */ }
    
    // Implementation of the second interface method above.
    // This method references member variables (with and without the "this" prefix)
    public Integer method2(Integer i) { return this.i + s.length(); }
    }
    
    // Abstract class (that subclasses the class above). No constructor is needed since
    // parent class has a no-argument constructor
    public abstract class AbstractChildClass extends InnerClass {
    
    // Override the parent class method with this signature.
    // Must use the override keyword
    public override void myMethod() { /* do something else */ }
    
    // Same name as parent class method, but different signature.
    // This is a different method (displaying polymorphism) so it does not need
    // to use the override keyword
    protected void method2() {}
    
    // Abstract method - subclasses of this class must implement this method
    abstract Integer abstractMethod();
    }
    
    // Complete the abstract class by implementing its abstract method
    public class ConcreteChildClass extends AbstractChildClass {
        // Here we expand the visibility of the parent method - note that visibility 
        // cannot be restricted by a sub-class
        public override Integer abstractMethod() { return 5; }
    }
    
    // A second sub-class of the original InnerClass
    public class AnotherChildClass extends InnerClass {
        AnotherChildClass(String s) {
        // Explicitly invoke a different super constructor than one with no arguments
        super(s);
        }
    }
    
    // Exception inner class
    public virtual class MyException extends Exception {
    // Exception class member variable
    public Double d;
    
    // Exception class constructor    
    MyException(Double d) {
    this.d = d;
    }
    
    // Exception class method, marked as protected
    protected void doIt() {}
    }
    
    // Exception classes can be abstract and implement interfaces
    public abstract class MySecondException extends Exception implements MyInterface {
    }    
    public static void createTemperatureHistory() {
        List<Integer> fillMe = new List<Integer>();        
        reference(fillMe);
        // The list is modified and contains five items
        // as expected.
        System.assertEquals(fillMe.size(),5);        
        
        List<Integer> createMe = new List<Integer>();
        referenceNew(createMe);
        // The list is not modified because it still points
        // to the original list, not the new list 
        // that the method created.
        System.assertEquals(createMe.size(),0);     
    }
    
        /*****************************
        Created Date: 06/12/21
        Last Modified By: Meeta Pramanik
        Comments: UST-001/Sp-21001
        Description : Test Method
        *****************************/
    public static void reference(List<Integer> m) {
        // Add rounded temperatures for the last five days.
        m.add(70);
        m.add(68);
        m.add(75);
        m.add(80);
        m.add(82);
        }    
        
        public static void referenceNew(List<Integer> m) {
        // Assign argument to a new List of
        // five temperature values.
        m = new List<Integer>{55, 59, 62, 60, 63};
        }   
        Public void CreateAccount(String Name, String Phone){
        account acc=new account();
        
        acc.Name=Name;
        
        acc.phone=Phone;
        
        insert acc;
        
        System.debug('Account Inserted :'+acc.name);
        }
        Public static void FetchAccName(String p) { 
        Set<String> s1= new Set<String>();
        
        List<Account> acc=[Select id, Name From Account where phone=:p];
        
        for(Account a:acc)
    
    {
    
        String s =a.name;
        
        s1.add(s);
        
        }
        
        System.debug('The Account Record Matching the Phone' +s1);
        }
        public static void Createrecords(String n)
        
        {
        
        Account a = new Account();
        
        a.Name=n;
        
        insert a;
        
        System.debug('Account :' +a.name);
        
        Contact c = new Contact();
        
        c.LastName='Dinesh';
        
        c.AccountId=a.id;//Id of the Account which we have created above
        
        insert c;
        
        System.debug('Contact :' +c.Lastname);
        
        Opportunity opp= new Opportunity();
        
        opp.Name='Test Opportunity Record';
        
        Date d= Date.newinstance(2012,2,17);
        opp.CloseDate=d;
        opp.StageName='Closed Lost';
        opp.Accountid=a.id;  //Id of the Account which we have created above
        
        insert opp;
        
        System.debug('Opportunity :' +opp.name);
    } 
    public static void createaccount(List<account> accts){
        List<account> failedList =new List<account>();
        Map<account, String> errorMap =new Map<account, String>();    
        Database.SaveResult[] srList = Database.insert(accts, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
        }
        //Collecting failed List
        for (Integer i = 0; i < accts.size(); i++) {
        Database.SaveResult s = srList[i];
        account origRecord = accts[i];
        if (!s.isSuccess()) {
        List<Database.Error> e= s.getErrors();  
        errorMap.put(origRecord,e[0].getMessage());
        failedList.add(origRecord);     
        } 
    
    }
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {'youremail@email.com'};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Below insertion of the accounts have been failed ');
    mail.setPlainTextBody('Failed Account List'+errorMap);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    }
    
    public static Integer myValue = 0;  //Class Member variable
    public static String myString = ''; //Class Member variable
    
    public static Integer getCalculatedValue () {
    // Method definition and body
    // do some calculation
    myValue = myValue+10;
    return myValue;
    }  
}