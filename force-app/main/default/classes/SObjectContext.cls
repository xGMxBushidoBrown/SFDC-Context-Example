/** *
 * @description Base Abstract class for handling SObject context in Apex Triggers. This class is meant to be extended for specific SObjects, where you can define the related objects you want to lazy load and the keys you want to index them off of. The context will handle lazy loading of related records and provide helper methods for accessing them efficiently.
 */

public abstract class SObjectContext {
    /**
     * @description List of current trigger context records
     */
    protected List<SObject> records;

    /**
     * @description Related objects map. Keys are defined and inserted in your specific implementation
     */
    protected Map<String, nebc.SObjectIndex> relatedObjectsBySObjectName;

    {
        resetContext();
    }

    /**
     * @description Returns the API name of the trigger SObject this context applies to
     * @return String
     * @example
     * public override String getSObjectName() {
     *     return 'Opportunity';
     * }
     */
    public abstract String getSObjectName();

    /**
     * @description Determines if we need to lazy load related records through queries
     * @param relatedObjectKey Related object key to use for testing
     * @example
     * protected override void lazyLoadRelatedRecords(String relatedObjectKey) {
     *     if(!relatedObjectsBySObjectName.containsKey(relatedObjectKey) {
     *         //specific implementations go here
     *         if(relatedObjectKey.contains('Opportunity') {
     *             queryRelatedOpportunities(records);
     *         }
     *         if(relatedObjectKey.contains('Account') {
     *             queryRelatedAccounts(records);
     *         }
     *         //...
     *     }
     * }
     */
    protected abstract void lazyLoadRelatedRecords(String relatedObjectKey);

    /**
     * @description Resets the current OpportunityContext.
     */
    public void resetContext() {
        if(!currentSObjectEquals(getSObjectName()) && !Trigger.isExecuting) {
            return;
        }
        //reset the map and records used
        relatedObjectsBySObjectName = new Map<String, nebc.SObjectIndex>();
        records = Trigger.isDelete ? Trigger.old : Trigger.new;
    }

    /**
     * @description Determines if the provided string matches the current SObject Trigger object name
     * @param sobjectApiName String representation of API name of SObject
     *
     * @return Boolean
     */
    private static Boolean currentSObjectEquals(String sobjectApiName) {
        SObject sample = Trigger.isDelete ? Trigger.old[0] : Trigger.new[0];
        String sObjectName = sample.getSObjectType().getDescribe().getName();
        return sobjectApiName == sObjectName;
    }

    /**
     * @description Returns an SObject using the provided related object key and the identifying key
     * @param relatedObjectKey Related object key
     * @param identifyingKey Identifying key
     *
     * @return SObject
     */
    protected SObject getSObject(String relatedObjectKey, String identifyingKey) {
        lazyLoadRelatedRecords(relatedObjectKey);
        return relatedObjectsBySObjectName.get(relatedObjectKey).get(identifyingKey);
    }

    /**
     * @description Returns a list of SObjects using the provided related object key and the identifying key
     * @param relatedObjectKey Related object key
     * @param identifyingKey Identifying key
     *
     * @return List<SObject>
     */
    protected List<SObject> getSObjects(String relatedObjectKey, String identifyingKey) {
        lazyLoadRelatedRecords(relatedObjectKey);
        return relatedObjectsBySObjectName.get(relatedObjectKey).getAll(identifyingKey);
    }

    /**
     * @description Returns an SObject using the provided related object key and the identifying key
     * @param relatedObjectKey Related object key
     * @param identifyingKey Identifying key map
     *
     * @return SObject
     */
    protected SObject getSObject(String relatedObjectKey, Map<String, String> identifyingKey) {
        lazyLoadRelatedRecords(relatedObjectKey);
        return relatedObjectsBySObjectName.get(relatedObjectKey).get(identifyingKey);
    }

    /**
     * @description Returns a list of SObjects using the provided related object key and the identifying key
     * @param relatedObjectKey Related object key
     * @param identifyingKey Identifying key map
     *
     * @return List<SObject>
     */
    protected List<SObject> getSObjects(String relatedObjectKey, Map<String, String> identifyingKey) {
        lazyLoadRelatedRecords(relatedObjectKey);
        return relatedObjectsBySObjectName.get(relatedObjectKey).getAll(identifyingKey);
    }

    /**
     * @description Returns a subset of all related sobjects using the details provided
     * @param relatedObjectKey Related object key
     * @param indexField Index field to check
     * @param identifyingObjects Set of values to use for validation
     *
     * @return List<SObject>
     * @example
     * return getAllRelatedSObjects('Account', 'AccountSource', new Set<String>{'Source 1', 'Source 2'});
     */
    protected List<SObject> getAllRelatedSObjects(String relatedObjectKey, String indexField, Set<Object> identifyingObjects) {
        lazyLoadRelatedRecords(relatedObjectKey);

        List<SObject> results = new List<SObject>();

        for(SObject record : relatedObjectsBySObjectName.get(relatedObjectKey).values()) {
            if(identifyingObjects.contains(record.get(indexField))) {
                results.add(record);
            }
        }
        return results;
    }

    /**
     * @description Returns a subset of all related sobjects using the details provided
     * @param relatedObjectKey Related object key
     * @param indexField Index field to check
     * @param identifyingKeys Set of Ids to use for validation
     *
     * @return List<SObject>
     * @example
     * return getAllRelatedSObjects('Account', 'Id', accountIds);
     */
    protected List<SObject> getAllRelatedSObjects(String relatedObjectKey, String indexField, Set<Id> identifyingKeys) {
        lazyLoadRelatedRecords(relatedObjectKey);

        List<SObject> results = new List<SObject>();

        for(SObject record : relatedObjectsBySObjectName.get(relatedObjectKey).values()) {
            if(identifyingKeys.contains((Id)record.get(indexField))) {
                results.add(record);
            }
        }
        return results;
    }

    /**
     * @description Returns a list of all related SObjects using the provided related object key
     * @param relatedObjectKey Related object key
     *
     * @return List<SObject>
     */
    protected List<SObject> getAllRelatedSObjects(String relatedObjectKey) {
        lazyLoadRelatedRecords(relatedObjectKey);
        return relatedObjectsBySObjectName.get(relatedObjectKey).values();
    }

    /**
     * @description Populates the relatedObjectsBySObjectName map using the provided records and variables
     * @param records The records to use for populating. We will not be adding these directly, but rather related SObjects
     * @param sObjectRelationshipName The API name of the object relation to populate
     * @param relatedObjectKey Related object key used for storing the new SObjectIndex
     * @param indexField The Field to index the SObjectIndex off of.
     */
    protected void populateRelatedSObjects(List<SObject> records, String sObjectRelationshipName, String relatedObjectKey, String indexField) {
        List<SObject> sObjects = new nebc.LazySObjectIterator(records)
            .getSObjects(sObjectRelationshipName)
            .toList();

        relatedObjectsBySObjectName.put(relatedObjectKey, new nebc.SObjectIndex(indexField).putAll(sObjects));
    }

    /**
     * @description Populates the relatedObjectsBySObjectName map using the provided records and variables
     * @param records The records to use for populating. We will not be adding these directly, but rather related SObjects
     * @param relatedObjectKey Related object key used for storing the new SObjectIndex
     * @param indexField The Field to index the SObjectIndex off of.
     */
    protected void populateRelatedSObject(List<SObject> records, String relatedObjectKey, String indexField) {
        relatedObjectsBySObjectName.put(relatedObjectKey, new nebc.SObjectIndex(indexField).putAll(records));
    }

    /**
     * @description Populates the relatedObjectsBySObjectName map using the provided records and variables
     * @param records The records to use for populating. We will not be adding these directly, but rather related SObjects
     * @param relatedObjectKey Related object key used for storing the new SObjectIndex
     * @param indexFields The list of fields to index the SObjectIndex off of.
     */
    protected void populateRelatedSObject(List<SObject> records, String relatedObjectKey, List<String> indexFields) {
        relatedObjectsBySObjectName.put(relatedObjectKey, new nebc.SObjectIndex(indexFields).putAll(records));
    }
}