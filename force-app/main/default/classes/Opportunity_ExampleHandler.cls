/**
 * @description Sample handler class for Opportunity trigger context.
*/

public with sharing class Opportunity_ExampleHandler implements nebc.BeforeInsert {

    /**
     * @description Example of a before insert handler.
     * @param newList List of new SObjects being inserted
     */
    public void handleBeforeInsert(List<SObject> newList) {
        //Grab the context instance for this trigger execution
        OpportunityContext context = OpportunityContext.getInstance();
        
        //example of accessing related account information in a trigger context
        for(SObject record : newList) {
            Opportunity opp = (Opportunity)record;
            Account relatedAccount = context.getRelatedAccount(opp);
            if(relatedAccount != null && relatedAccount.Type == 'Customer') {
                opp.Description = 'This opportunity is related to a customer account.';
            }
        }
    }
}