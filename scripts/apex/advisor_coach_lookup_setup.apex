public static Map<String, Contact> contacts = new Map<String, Contact>();

public static Integer contactCounter = 1;
public static User bcsUser = new User();
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
bcsUser = getUser('UCMC User');
acct = getAccount('D. Eccles School of Business');

// create contacts
buildContact(true, true); // hasAdvisor && hasCoach 
buildContact(true, false); // hasAdvisor && !hasCoach
buildContact(false, true); // !hasAdvisor && hasCoach
buildContact(false, false); //!hasAdvisor && !hasCoach
createRecords(contacts.values());

for(Contact c : contacts.values()) {
    system.debug('value of contact >> ' + c);
}
// system.debug('value of uasUser >>>>>> ' + uasUser);
// system.debug('value of bcsUser >>>>>> ' + bcsUser);

} else {
system.debug('in production');
}

public static void buildContact(Boolean hasAdvisor, Boolean hasCoach) {
    Contact c = new Contact();
    c.FirstName = 'LookupFN' + contactCounter;
    c.LastName = 'LookupLN' + contactCounter;
    c.Email = 'Email'+contactCounter+'@invalid.com';
    c.student_id_number__c = 'u000000'+contactCounter;
    c.recordTypeId = CONTACT_RT_ID;
    c.accountId = acct.id;
    if(hasAdvisor) {
        c.FirstName += ' hasAdvisor';
        c.advisor_assigned__c = uasUser.id;
    }
    if(hasCoach){
        c.FirstName += ' hasCoach';
        c.Career_Coach__c = bcsUser.id;
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