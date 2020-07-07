public static Map<String, Contact> contacts = new Map<String, Contact>();

public static Integer contactCounter = 1;
public static User uasUser = new User();
public static Account acct = new Account();

public static Id CONTACT_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();


// check if sandbox org
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {
system.debug('in sandbox');

// get users
uasUser = getUser('UAS');
acct = getAccount('D. Eccles School of Business');

// create contacts
buildContact('Integrated Core', true); // hasAdvisor 
buildContact('Integrated Core', false); // !hasAdvisor 
buildContact('Non-Integrated Core', true); // hasAdvisor 
buildContact('Non-Integrated Core', false); // !hasAdvisor 
buildContact('Undetermined', true); // hasAdvisor 
buildContact('Undetermined', false); // !hasAdvisor 
buildContact('', true); // hasAdvisor 
buildContact('', false); // !hasAdvisor 
createRecords(contacts.values());


} else {
system.debug('in production');
}

public static void buildContact(String coreType, Boolean hasAdvisor) {
    Contact c = new Contact();
    c.FirstName = 'CoreFN' + contactCounter + ' ' + coreType;
    c.LastName = 'CoreLN' + contactCounter;
    c.Email = 'EmailCore'+contactCounter+'@invalid.com';
    c.student_id_number__c = 'u100000'+contactCounter;
    c.recordTypeId = CONTACT_RT_ID;
    c.accountId = acct.id;
    c.undergraduate_curriculum__c = coreType;
     if(hasAdvisor) {
        c.FirstName += ' hasAdvisor';
        c.advisor_assigned__c = uasUser.id;
    }

    contacts.put(c.student_id_number__c, c);
    contactCounter++;
}


public static User getUser(String userRole){
    return [
        SELECT Id, FirstName, LastName, Name, AboutMe, Scheduling_Link_URL__c 
        FROM User 
        WHERE isActive = TRUE AND Scheduling_Link_URL__c != null AND UserRole.Name =: userRole 
        LIMIT 1
        ];
}

public static Account getAccount(String acctName){
    Account a = new Account();
    a = [SELECT Id FROM Account WHERE Name =: acctName LIMIT 1];

    if(a.id == null) {
        a.Name = 'D. Eccles School of Business';
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