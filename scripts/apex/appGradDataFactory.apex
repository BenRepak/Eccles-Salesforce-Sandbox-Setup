Boolean enableRollback = false;

public static Id AG_MHA_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MHA').getRecordTypeId();
public static Id AG_MRED_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MRED').getRecordTypeId();
public static Id AG_MSBA_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MSBA').getRecordTypeId();
public static Id AG_MSF_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MSF').getRecordTypeId();
public static Id AG_MSIS_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MSIS').getRecordTypeId();
public static Id AG_MSISO_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MSISO').getRecordTypeId();
public static Id AG_MACC_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MACC').getRecordTypeId();
public static Id AG_EMBA_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('EMBA').getRecordTypeId();
public static Id AG_FTMBA_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('FTMBA').getRecordTypeId();
public static Id AG_MBAO_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('MBAO').getRecordTypeId();
public static Id AG_PMBA_REC_TYPE_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByName().get('PMBA').getRecordTypeId();
public static Id CONTACT_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();

public static Account acct = new Account();
public static List<Contact> contactsToInsert = new List<Contact>();
public static List<Application_Graduate__c> appsToInsert = new List<Application_Graduate__c>(); 

// used to change the starting value for each contact
public boolean isSubmittedSetter = false;


public Map<String,Id> agRecordTypeMap = new Map<String,Id>{
    'Accounting MAC' => AG_MHA_REC_TYPE_ID,
    'Executive MBA' => AG_EMBA_REC_TYPE_ID,
    'Full-Time MBA' => AG_FTMBA_REC_TYPE_ID,
    'MBA Online' => AG_MBAO_REC_TYPE_ID,
    'Professional MBA' => AG_PMBA_REC_TYPE_ID,
    'Master of Science in Information Systems (MSIS)' => AG_MSIS_REC_TYPE_ID,
    'Master of Science in Finance (MSF)' => AG_MSF_REC_TYPE_ID,
    'Master of Science in Business Analytics' => AG_MSBA_REC_TYPE_ID,
    'Master Real Estate Development (MRED)' => AG_MRED_REC_TYPE_ID,
    'Master of Healthcare Administration (MHA)' => AG_MHA_REC_TYPE_ID,
    'Master of Science in Information Systems - Online' => AG_MSISO_REC_TYPE_ID
};

Date todayDate = System.today();
String dynamicTerm = calcDynamicSemester(todayDate);



// check if sandbox org
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {
    system.debug('in sandbox');
    Savepoint sp = Database.setSavepoint();
    acct = getAccount('App Grad Testers');

    
    Integer counter = 0;
    Integer ceiling = 10;
    Boolean isFemale = true;


    // build contacts
    while(counter < ceiling){
        isFemale = !isFemale;
        counter++;
        String firstname = 'AG';
        String lastname = 'Tester ' + counter;
        String email = firstname + '.'+lastname+'@invalid.com';
        email = email.replace(' ','');
        Contact c = buildContact(firstname,lastname,email);
        c.Years_of_Work_Experience__c = counter;
        c.gender__c = isFemale? 'Female':'Male';
        c.Student_ID_Number__c = unidBuilder(counter);
        contactsToInsert.add(c);
    }

    // insert contacts
    createRecords(contactsToInsert);

    // build apps
    for(Contact c : contactsToInsert){
        isSubmittedSetter = !isSubmittedSetter; // change starting with false / true each contact
        Boolean isSubmitted = isSubmittedSetter;
        for(String program : agRecordTypeMap.keySet()){
            Application_Graduate__c a = buildApplication(program,isSubmitted,c);
            a.gender__c = c.gender__c;
            a.Non_Citizen_Status__c = 'Permanent resident';
            a.Verified_Undergrad_GPA__c = '3.75';
            appsToInsert.add(a);
            isSubmitted = !isSubmitted; // every other app for the contact will but submitted
        }
    }

    // insert apps
    createRecords(appsToInsert);
    if(enableRollback){
        Database.rollback( sp );
    }
} else {
    system.debug('in prod');
}



public static Account getAccount(String acctName){
    Account a = new Account();
    List<Account> accts = [SELECT Id FROM Account WHERE Name =: acctName LIMIT 1];
    if(accts.size() > 0){
        a = accts[0];
    } else {
       	a.Name = acctName;
        a.BillingCity = 'SLC';
        a.BillingState = 'UT';
        insert a; 
    }
   return a;
}

public static Contact buildContact(String firstName, String lastName, String email) {
    Contact c = new Contact();
    c.FirstName = firstname;
    c.lastName = lastname;
    c.Email = email;
    c.birthdate = date.valueOf('1999-01-01');
    c.recordTypeId = CONTACT_RT_ID;
    c.accountId = acct.id;
    return c;
}

public static Application_Graduate__c buildApplication(string programDesired, Boolean isSubmitted, Contact c){
    Application_Graduate__c a = new Application_Graduate__c();
    a.contact__c = c.id;
    a.recordtypeid = agRecordTypeMap.get(programDesired);
    String appStatus = isSubmitted ? 'Application Submitted' : 'Application Started';
    a.started__c = true;
    a.submitted__c = issubmitted;
    a.graduate_pipeline_stage_category__c = 'Pending Completion';
    a.graduate_pipeline_stage__c = appStatus;
    a.graduate_pipeline_term__c = dynamicTerm;
    a.Term_Desired__c = dynamicTerm;
    a.graduate_pipeline_term__c = dynamicTerm;
    a.Application_Created_Date__c = todayDate;
    a.Application_Last_Updated__c = todayDate;
    a.Application_Last_Accessed__c = todayDate;
    a.Application_Submitted_Date__c = isSubmitted ? todayDate : null;
    a.Program_Desired__c = programDesired;
    a.RecordTypeId = agRecordTypeMap.get(programDesired); 
    a.Months_Work_Since_Bachelors__c = '100';
    a.Country_of_Citizenship__c = 'Switzerland';
    a.Country_of_Residence__c = 'United States';
    // a.Client_ID__c = '979';
    // a.Applicant_ID_AY__c = 'macupsub';

    //  a.Emphasis__c = '';
    return a;
}

public static void createRecords(List<Sobject> objs) {
if(objs.size() > 0) {
    insert objs;
    }
}



private static string calcDynamicSemester(Date todayDate){
    Integer month = todayDate.month();
    Integer year = todayDate.year();
    String semester = '';

    if(month < 7){
        semester = 'Fall ' + string.valueOf(year);
    } else {
        year += 1;
        semester = 'Fall ' + string.valueOf(year);
    }
    return semester;
}

private static string unidBuilder(Integer i){
    String unidNumber = string.valueOf(i);
    unidNumber = unidNumber.leftPad(7,'0');
    return 'u'+unidNumber;
}