trigger ClosedOpportunityTrigger on Opportunity (after insert,after update) {
    List<task> lstOfTask = new List<task>();
    
    for(Opportunity opp : Trigger.New){
        if(opp.StageName == 'Closed Won'){
            task tsk = new task();
            tsk.WhatId = opp.id;
            tsk.Subject = 'Follow Up Test Task';
            
            lstOfTask.add(tsk);
        }
    }
    
    INSERT lstOfTask;
}