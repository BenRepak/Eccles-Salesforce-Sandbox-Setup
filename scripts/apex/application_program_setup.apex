public static List<Contact> contacts = new List<Contact>();
public static List<Application_Program__c> appPrograms = new List<Application_Program__c>();
public static Account acct = new Account();

public static Id CONTACT_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
public static Id AP_FR_RT_ID = Schema.SObjectType.Application_Program__c.getRecordTypeInfosByDeveloperName().get('Business_Scholars').getRecordTypeId();
public static Id AP_TR_RT_ID = Schema.SObjectType.Application_Program__c.getRecordTypeInfosByDeveloperName().get('TR_Business_Scholars').getRecordTypeId();
public static Id AP_OS_RT_ID = Schema.SObjectType.Application_Program__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Scholar').getRecordTypeId();
public static Id AP_FA_RT_ID = Schema.SObjectType.Application_Program__c.getRecordTypeInfosByDeveloperName().get('First_Ascent').getRecordTypeId();


// check if sandbox org
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {

    system.debug('in sandbox');

    // get or created account
    acct = getAccount('D. Eccles School of Business');

    // build contacts
    Contact frbsCon = buildContact('FR Business Scholar', 'Tester', 'salesforce@eccles.utah.edu'); 
    Contact trbsCon = buildContact('TR Business Scholar', 'Tester', 'salesforce@eccles.utah.edu'); 
    Contact osCon = buildContact('Opportunity Scholar', 'Tester', 'salesforce@eccles.utah.edu'); 
    Contact faCon = buildContact('First Ascent Scholar', 'Tester', 'salesforce@eccles.utah.edu'); 
    createRecords(contacts);

    // build apps
    integer i = 0;
    while(i < 10) {
        buildApplication(AP_FR_RT_ID,'Pending',frbsCon);
        buildApplication(AP_TR_RT_ID,'Pending',trbsCon);
        buildApplication(AP_OS_RT_ID,'Pending',osCon);
        buildApplication(AP_FA_RT_ID,'Pending',faCon);
        i++;
    }
    createRecords(appPrograms);
} else {
    system.debug('in production');
}

public static Contact buildContact(String firstName, String lastName, String email) {
    Contact c = new Contact();
    c.FirstName = firstname;
    c.lastName = lastname;
    c.Email = email;
    c.birthdate = date.valueOf('1999-01-01');
    c.recordTypeId = CONTACT_RT_ID;
    c.accountId = acct.id;
    contacts.add(c);
    return c;
}


public static void buildApplication(String applicationTypeId, String applicationStatus, Contact c){
    Application_Program__c app = new Application_Program__c();
    app.ContactLU__c = c.id;
    app.recordTypeId = applicationTypeId;
    app.first_name__c = c.firstname;
    app.last_name__c = c.lastname;
    app.E_mail__c = c.email;
    app.term_desired__c = 'Fall 1999';
    app.Application_Decision__c = applicationStatus;
    appPrograms.add(app);
}


public static Account getAccount(String acctName){
    Account a = new Account();
    a = [SELECT Id FROM Account WHERE Name =: acctName LIMIT 1];

    if(a.id == null) {
        a.Name = acctName;
        a.BillingCity = 'SLC';
        a.BillingState = 'UT';
        insert a;
    }
   return a;
}

public static void createRecords(List<Sobject> objs) {
if(objs.size() > 0) {
    insert objs;
    }
}