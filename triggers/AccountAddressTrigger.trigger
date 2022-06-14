trigger AccountAddressTrigger on Account (before insert) {
//Added a Comment
    for(Account acc : Trigger.New) {
        if(acc.Match_Billing_Address__c){
            acc.ShippingPostalCode = acc.BillingPostalCode;
        }
    }
}