trigger UpdateContactRelationCountersOnAccount on AccountContactRelation (after insert, after update, after delete, after undelete) {

    final String BusinessUsersRoleName = 'Business User';
    final String DecisionMakersRoleName = 'Decision Maker';
    final List<String> relationRolesToCheck = new List<String> {
            BusinessUsersRoleName,
            DecisionMakersRoleName
    };

    List<AccountContactRelation> relationsToProcess = new List<AccountContactRelation>();
    if (Trigger.isUpdate) {
        for (AccountContactRelation newRelation : Trigger.new) {
            AccountContactRelation oldRelation = Trigger.oldMap.get(newRelation.Id);
            Set<String> newRoles = new Set<String>(newRelation.Roles.split(';'));
            Set<String> oldRoles = new Set<String>(oldRelation.Roles.split(';'));
            newRoles.retainAll(relationRolesToCheck);
            oldRoles.retainAll(relationRolesToCheck);
            // If a relation contains or contained at least one of the roles and target roles were changed or active status was changed
            if ((!newRoles.isEmpty() || !oldRoles.isEmpty())
                    && (!newRoles.containsAll(oldRoles) || newRelation.IsActive != oldRelation.IsActive)) {
                relationsToProcess.add(newRelation);
            }
        }
    } else if (Trigger.isInsert || Trigger.isUndelete) {
        for (AccountContactRelation newRelation : Trigger.new) {
            Set<String> newRoles = new Set<String>(newRelation.Roles.split(';'));
            newRoles.retainAll(relationRolesToCheck);
            // If a relation contains at least one of the roles and is active
            if (!newRoles.isEmpty() && newRelation.IsActive == true) {
                relationsToProcess.add(newRelation);
            }
        }
    } else if (Trigger.isDelete) {
        for (AccountContactRelation oldRelation : Trigger.old) {
            Set<String> oldRoles = new Set<String>(oldRelation.Roles.split(';'));
            // If a relation contained at least one of the roles and was active
            if (!oldRoles.isEmpty() && oldRelation.IsActive == true) {
                relationsToProcess.add(oldRelation);
            }
        }
    }
    if (relationsToProcess.isEmpty()) return;

    Set<Id> accountIds = new Set<Id>();
    for (AccountContactRelation relation : relationsToProcess) {
        accountIds.add(relation.AccountId);
    }
    List<Account> accounts = [
            SELECT Id, Business_Users__c, Decision_Makers__c
            FROM Account
            WHERE Id IN :accountIds
    ];
    List<AccountContactRelation> accountContactRelations = [
            SELECT Id, AccountId, Roles
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds AND Roles IN :relationRolesToCheck
    ];
    Map<Id, List<AccountContactRelation>> accountIdToRelations = new Map<Id, List<AccountContactRelation>>();
    for (AccountContactRelation relation : accountContactRelations) {
        List<AccountContactRelation> relationList = accountIdToRelations.get(relation.AccountId);
        if (relationList == null) {
            relationList = new List<AccountContactRelation>();
            accountIdToRelations.put(relation.AccountId, relationList);
        }
        relationList.add(relation);
    }
    List<Account> accountsToUpdate = new List<Account>();
    for (Account account : accounts) {
        Integer BusinessUsersCounter = 0;
        Integer DecisionMakersCounter = 0;
        List<AccountContactRelation> accountRelations = accountIdToRelations?.get(account.Id);
        if (accountRelations != null) {
            for (AccountContactRelation relation : accountRelations) {
                if (relation.Roles.contains(BusinessUsersRoleName)) {
                    BusinessUsersCounter++;
                } else if (relation.Roles.contains(DecisionMakersRoleName)) {
                    DecisionMakersCounter++;
                }
            }
        }
        if (account.Business_Users__c != BusinessUsersCounter || account.Decision_Makers__c != DecisionMakersCounter) {
            account.Business_Users__c = BusinessUsersCounter;
            account.Decision_Makers__c = DecisionMakersCounter;
            accountsToUpdate.add(account);
        }
    }

    if (!accountsToUpdate.isEmpty()) update accountsToUpdate;
}