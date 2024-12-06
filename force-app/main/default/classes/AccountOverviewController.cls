public with sharing class AccountOverviewController {

    @AuraEnabled(Cacheable=true)
    public static List<Account> getAccounts() {
        List<Account> accounts = [
                SELECT AnnualRevenue, Name, TickerSymbol,
                    (SELECT Name, CreatedDate FROM Contacts ORDER BY Name),
                    (SELECT Name, Amount FROM Opportunities ORDER BY Name)
                FROM Account
                ORDER BY Name
        ];
        return accounts;
    }
}