global class Meeta_Scheduled Implements Schedulable
    {
        global void execute(SchedulableContext sc)
        {
            setToMiko();
        }

        public void setToMiko()
        {
            List<Account> listAccounts = new List<Account>();
            listAccounts = [SELECT ID,Name FROM Account WHERE Name = null];

            for(Account acc : listAccounts)
            {
                acc.Name = 'Meeta';
            }

            update listAccounts;
        }
    }