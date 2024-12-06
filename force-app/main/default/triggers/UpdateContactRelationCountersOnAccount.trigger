trigger UpdateContactRelationCountersOnAccount on AccountContactRelation (after insert, after update, after delete, after undelete) {

    final String businessUsersRoleName = 'Business User';
    final String decisionMakersRoleName = 'Decision Maker';
    final List<String> relationRolesToCheck = new List<String> {
            businessUsersRoleName,
            decisionMakersRoleName
    };

    List<AccountContactRelation> relationsToProcess = new List<AccountContactRelation>();
    Set<String> newRoles;
    Set<String> oldRoles;
    if (Trigger.isUpdate) {
        for (AccountContactRelation newRelation : Trigger.new) {
            AccountContactRelation oldRelation = Trigger.oldMap.get(newRelation.Id);
            newRoles = String.isNotBlank(newRelation.Roles)
                    ? new Set<String>(newRelation.Roles.split(';'))
                    : new Set<String>();
            oldRoles = String.isNotBlank(oldRelation.Roles)
                    ? new Set<String>(oldRelation.Roles.split(';'))
                    : new Set<String>();
            newRoles.retainAll(relationRolesToCheck);
            oldRoles.retainAll(relationRolesToCheck);
            // If a relation contains or contained at least one of the roles and target roles were changed or active status was changed
            if ((!newRoles.isEmpty() || !oldRoles.isEmpty())
                    && (!newRoles.containsAll(oldRoles) || !oldRoles.containsAll(newRoles) || newRelation.IsActive != oldRelation.IsActive)) {
                relationsToProcess.add(newRelation);
            }
        }
    } else if (Trigger.isInsert || Trigger.isUndelete) {
        for (AccountContactRelation newRelation : Trigger.new) {
            newRoles = String.isNotBlank(newRelation.Roles)
                    ? new Set<String>(newRelation.Roles.split(';'))
                    : new Set<String>();
            newRoles.retainAll(relationRolesToCheck);
            // If a relation contains at least one of the roles and is active
            if (!newRoles.isEmpty() && newRelation.IsActive == true) {
                relationsToProcess.add(newRelation);
            }
        }
    } else if (Trigger.isDelete) {
        for (AccountContactRelation oldRelation : Trigger.old) {
            oldRoles = String.isNotBlank(oldRelation.Roles)
                    ? new Set<String>(oldRelation.Roles.split(';'))
                    : new Set<String>();
            oldRoles.retainAll(relationRolesToCheck);
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
            WHERE AccountId IN :accountIds AND Roles INCLUDES ('Business User', 'Decision Maker')
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
        Integer businessUsersCounter = 0;
        Integer decisionMakersCounter = 0;
        List<AccountContactRelation> accountRelations = accountIdToRelations?.get(account.Id);
        if (accountRelations != null) {
            for (AccountContactRelation relation : accountRelations) {
                if (relation.Roles.contains(businessUsersRoleName)) {
                    businessUsersCounter++;
                }
                if (relation.Roles.contains(decisionMakersRoleName)) {
                    decisionMakersCounter++;
                }
            }
        }
        if (account.Business_Users__c != businessUsersCounter || account.Decision_Makers__c != decisionMakersCounter) {
            account.Business_Users__c = businessUsersCounter;
            account.Decision_Makers__c = decisionMakersCounter;
            accountsToUpdate.add(account);
        }
    }

    if (!accountsToUpdate.isEmpty()) update accountsToUpdate;
}