// only execute if in Sandbox environment
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
if(currentOrg.isSandbox) {
    System.debug('in sandbox');
    HouseAccountCreationUtility houseUtility = new HouseAccountCreationUtility();
}


public class HouseAccountCreationUtility{
    private Set<String> houseAccountNameList = new Set<String>();
    private Id HOUSE_ACCT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Eccles House Account').getRecordTypeId();
    private List<Account> existingHouseAccounts = new List<Account>();
    private List<Account> newHouseAccounts = new List<Account>();

    // constructor
    public HouseAccountCreationUtility(){
        buildHouseAccountNameList();
        findExistingHouseAccounts();
        removeExistingAccountsFromHouseAccountList();
        buildNewHouseAccounts();
        createNewHouseAccounts();
    }

    private void buildHouseAccountNameList(){
        houseAccountNameList.add('D. Eccles School of Business');
        houseAccountNameList.add('External Relations');
        houseAccountNameList.add('Executive Education');
        houseAccountNameList.add('Exec Ed Other');
        houseAccountNameList.add('Graduate Programs');
        houseAccountNameList.add('MAcc');
        houseAccountNameList.add('Business Scholars House Account');
        system.debug('houseAccountNameList -----------------------------> ' + houseAccountNameList);
    }

    private void findExistingHouseAccounts(){
        existingHouseAccounts = [SELECT Id, Name FROM Account WHERE recordTypeId = :HOUSE_ACCT_RECORD_TYPE_ID AND Name IN :houseAccountNameList];
        system.debug('existingHouseAccounts -----------------------------> ' + existingHouseAccounts);
    }


    private void removeExistingAccountsFromHouseAccountList(){
        for(Account a : existingHouseAccounts) {
            if(houseAccountNameList.contains(a.Name)){
                houseAccountNameList.remove(a.Name);
            }
        }
        system.debug('post removal houseAccountNameList -----------------------------> ' + houseAccountNameList);
    }

    private void buildNewHouseAccounts(){
        for(String s : houseAccountNameList) {
            Account a = new Account();
            a.name = s;
            a.recordTypeId = HOUSE_ACCT_RECORD_TYPE_ID;
            newHouseAccounts.add(a);
        }
        system.debug('newHouseAccounts -----------------------------> ' + newHouseAccounts);
    }


    private void createNewHouseAccounts() {
        if(newHouseAccounts.size() > 0) {
            insert newHouseAccounts;
        }
    }


} // end of class