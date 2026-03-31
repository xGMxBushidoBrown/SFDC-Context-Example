/**
 *
 * @description OpportunityContext class contains all related records used in Opportunity trigger context
 */

public without sharing class OpportunityContext extends SObjectContext {
    private static OpportunityContext instance;

    /**
     * @description private constructor to prevent direct initialization
     */
    private OpportunityContext() {}

    /**
     * @description Returns the SObject name this context applies to
     * @return String
     */
    public override String getSObjectName() {
        return 'Opportunity';
    }

    /**
     * @description Lazy loads related records. This is where query orchestration should happen.
     * @param relatedObjectKey Object key being used for lookup
     */
    protected override void lazyLoadRelatedRecords(String relatedObjectKey) {
        if(!relatedObjectsBySObjectName.containsKey(relatedObjectKey)) {
            if(relatedObjectKey.contains('Opportunity')) {
                queryOpportunities(records);
                return;
            }
            if(relatedObjectKey.contains('Account')) {
                queryRelatedAccounts(records);
                return;
            }
        }
    }

    /**
     * @description Returns the current instance of OpportunityContext
     * @return OpportunityContext
     */
    public static OpportunityContext getInstance() {
        if(instance == null) {
            instance = new OpportunityContext();
        }
        return instance;
    }

    /**
     * @description Returns all related Accounts to a given Opportunity
     * @param opportunity Opportunity to use for retrieval
     *
     * @return Account
     */
    public Account getRelatedAccount(Opportunity opportunity) {
        return (Account)getSObject('Account', opportunity.AccountId);
    }

    /**
     * @description Returns all events related to the Account on an Opportunity
     * @param opportunity Opportunity to use for retrieval
     *
     * @return List<Event>
     */
    public List<Event> getRelatedAccountEvents(Opportunity opportunity) {
        return getSObjects('Account.Event', opportunity.AccountId);
    }

    /**
     * @description Returns all tasks related to the Account on an Opportunity
     * @param opportunity Opportunity to use for retrieval
     *
     * @return List<Task>
     */
    public List<Task> getRelatedAccountTasks(Opportunity opportunity) {
        return getSObjects('Account.Task', opportunity.AccountId);
    }

    /**
     * @description Returns primary contact provided a given Opportunity
     * @param opportunity Opportunity to use for retrieval
     *
     * @return Contact
     */
    public Contact getPrimaryContact(Opportunity opportunity) {
        return (Contact)getSObject('Contact', opportunity.SalesLoft1__Primary_Contact__c);
    }

    /**
     * @description Returns all quote lines on the primary quote provided a given Opportunity
     * @param opportunity Opportunity to use for retrieval
     *
     * @return List<OpportunityLineItem>
     */
    public List<OpportunityLineItem> getOpportunityLineItems(Opportunity opportunity) {
        return getSObjects('Opportunity.OpportunityLineItem', opportunity.Id);
    }

    /**
     * @description Returns all OpportunityContactRoles provided a given Opportunity
     * @param opportunity Opportunity to use for retrieval
     *
     * @return List<OpportunityContactRole>
     */
    public List<OpportunityContactRole> getOpportunityContactRoles(Opportunity opportunity) {
        return getSObjects('Opportunity.OpportunityContactRole', opportunity.Id);
    }

    /**
     * @description Returns all OpportunityTeamMember provided a given Opportunity
     * @param opportunity Opportunity to use for retrieval
     *
     * @return List<OpportunityTeamMember>
     */
    public List<OpportunityTeamMember> getOpportunityTeamMembers(Opportunity opportunity) {
        return getSObjects('Opportunity.OpportunityTeamMember', opportunity.Id);
    }


    /**************************************************************************
    *                           QUERIES & MAPPING
    ***************************************************************************/

    /**
     * @description Queries and populates related object map with all related Accounts. Uses Opportunity Id as key.
     * @param opportunities Opportunities used for retrieval
     */
    private void queryRelatedAccounts(List<Opportunity> opportunities) {
        Set<Id> accountIds = UT_Helpers.getIds(opportunities, Opportunity.AccountId);

        List<Account> accounts = [
            SELECT
                Id,
                AccountSource,
                CreatedDate,
                Name,
                Type,
                (
                    SELECT
                        Id,
                        AccountId,
                        LastModifiedDate
                    FROM
                        Events
                    ORDER BY
                        LastModifiedDate DESC
                    LIMIT 100
                ),
                (
                    SELECT
                        Id,
                        AccountId,
                        LastModifiedDate
                    FROM
                        Tasks
                    ORDER BY
                        LastModifiedDate DESC
                    LIMIT 100
                )
            FROM
                Account
            WHERE
                Id IN :accountIds
        ];

        populateRelatedSObject(accounts, 'Account', 'Id');
        populateRelatedSObjects(accounts, 'Events', 'Account.Event', 'AccountId');
        populateRelatedSObjects(accounts, 'Tasks', 'Account.Task', 'AccountId');
    }

    /**
     * @description Queries the current trigger context Opportunities to get directly related items.
     * @param opportunities Opportunities used for retrieval
     */
    private void queryOpportunities(List<Opportunity> opportunities) {
        List<Opportunity> queriedOpportunities = [
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        ContactId,
                        OpportunityId,
                        Role,
                        IsPrimary
                    FROM
                        OpportunityContactRoles
                ),
                (
                    SELECT
                        Id,
                        Opportunity.AccountId,
                        OpportunityId,
                        Quantity
                    FROM
                        OpportunityLineItems
                ),
                (
                    SELECT
                        Name,
                        OpportunityId,
                        OpportunityAccessLevel,
                        TeamMemberRole,
                        UserId
                    FROM
                        OpportunityTeamMembers
                )
            FROM
                Opportunity
            WHERE
                Id IN :opportunities
        ];

        populateRelatedSObjects(queriedOpportunities, 'OpportunityLineItems', 'Opportunity.OpportunityLineItem', 'OpportunityId');
        populateRelatedSObjects(queriedOpportunities, 'OpportunityContactRoles', 'Opportunity.OpportunityContactRole', 'OpportunityId');
        populateRelatedSObjects(queriedOpportunities, 'OpportunityTeamMembers', 'Opportunity.OpportunityTeamMember', 'OpportunityId');
    }
}