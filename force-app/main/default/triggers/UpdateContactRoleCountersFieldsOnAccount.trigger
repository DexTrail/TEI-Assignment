trigger UpdateContactRoleCountersFieldsOnAccount on Contact (after insert, after update, after delete, after undelete) {

    // AccountContactRole sObject doesn't allow triggers

    List<Contact> changedContacts = Trigger.isDelete ? Trigger.old : Trigger.new;
    Set<Id> accountIds = new Set<Id>();
    for (Contact contact : changedContacts) {
        accountIds.add(contact.AccountId);
    }
    List<Account> accounts = [
            SELECT Id, Business_Users__c, Decision_Makers__c
            FROM Account
            WHERE Id IN :accountIds
    ];
    List<AccountContactRole> accountContactRoles = [
            SELECT Id, AccountId, Role
            FROM AccountContactRole
            WHERE AccountId IN :accountIds AND Role IN ('Business User', 'Decision Maker')
    ];
    Map<Id, List<AccountContactRole>> accountIdToRoles = new Map<Id, List<AccountContactRole>>();
    for (AccountContactRole role : accountContactRoles) {
        List<AccountContactRole> rolesList = accountIdToRoles.get(role.AccountId);
        if (rolesList == null) {
            rolesList = new List<AccountContactRole>();
            accountIdToRoles.put(role.AccountId, rolesList);
        }
        rolesList.add(role);
    }
    List<Account> accountsToUpdate = new List<Account>();
    for (Account account : accounts) {
        Integer BusinessUsersCounter = 0;
        Integer DecisionMakersCounter = 0;
        if (!accountIdToRoles.isEmpty()) {
            for (AccountContactRole role : accountIdToRoles.get(account.Id)) {
                if (role.Role == 'Business User') {
                    BusinessUsersCounter++;
                } else if (role.Role == 'Decision Maker') {
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