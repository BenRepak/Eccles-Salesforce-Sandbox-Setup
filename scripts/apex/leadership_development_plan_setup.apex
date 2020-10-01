public static List<LDRPrograms__c> plans = new List<LDRPrograms__c>();
public static List<Account> accounts = new List<Account>();

public static Id COLRD_RT_ID = Schema.SObjectType.LDRPrograms__c.getRecordTypeInfosByDeveloperName().get('CO_LDR').getRecordTypeId();
public static Id ACCT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();

// check if sandbox org
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {

    system.debug('in sandbox');

    // build accounts
    buildAccount('LDR Account 1', 'SLC', 'UT');
    buildAccount('LDR Account 2', 'SLC', 'UT');
    buildAccount('LDR Account 3', 'NYC', 'NY');
    buildAccount('LDR Account 4', 'NYC', 'NY');
    buildAccount('LDR Account 5', 'NYC', 'NY');
    buildAccount('LDR Account 6', 'NYC', 'NY');
    buildAccount('LDR Account 7', 'Dallas', 'TX');
    buildAccount('LDR Account 8', 'Dallas', 'TX');
    buildAccount('LDR Account 9', 'Denver', 'CO');
    buildAccount('LDR Account 10', 'Denver', 'CO');
    createRecords(accounts);

    // build plans
    for(Account a : accounts) {
        buildLeadershipDevPlan(a,false, true); // not expired, published
        buildLeadershipDevPlan(a,true, false); // expired, not published
        buildLeadershipDevPlan(a,false, false); // not expired, not published
        buildLeadershipDevPlan(a,true, true); //  expired,  published
    }
    createRecords(plans);

} else {
    system.debug('in production');
}


public static void buildAccount(String name, String city, String state){
    Account a = new Account();
    a.recordtypeid = ACCT_RT_ID;
    a.name = name;
    a.billingcity = city;
    a.BillingState = state;
    accounts.add(a);
}

public static void buildLeadershipDevPlan(Account a, boolean isExpired, boolean isPublished){
    String name = ' -- ';

    if(isExpired == true){
        name += 'expired ';
    } else {
        name += 'not expired ';
    }

    if(isPublished == true) {
        name += 'published';
    } else {
        name += 'not published';
    }

    LDRPrograms__c p = new LDRPrograms__c();
    p.Organization__c = a.id;
    p.recordtypeid = COLRD_RT_ID;
    p.Program_Name__c = a.name + name;
    p.Description_Short__c = 'Description_Short__c';
    p.Description_Long__c = 'Description_Long__c';
    p.Requirements__c = 'Requirements__c';
    p.Program_Link__c = 'Program_Link__c';
    p.Majors__c = 'Information Systems';
    p.Location__c = 'Location__c';
    p.Preferences__c = 'Preferences__c';
    p.MinGPA__c = true;
    p.Start_Dates__c = 'Start_Dates__c';
    p.Application_Period__c = 'Application_Period__c';
    p.Expired__c = isExpired;
    p.publish_to_website__c = isPublished;
    
    plans.add(p);
}


public static void createRecords(List<Sobject> objs) {
if(objs.size() > 0) {
    insert objs;
    }
}