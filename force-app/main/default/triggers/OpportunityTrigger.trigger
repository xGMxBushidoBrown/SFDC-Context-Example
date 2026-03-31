trigger OpportunityTrigger on SOBJECT (before insert) {
    //Reset the context at the beginning of the trigger execution to ensure a clean slate for each transaction
    OpportunityContext.getInstance().resetContext();
    //Call metadata based trigger handler framework
    new nebc.MetadataTriggerManager(Opportunity.SObjectType).handle();
}