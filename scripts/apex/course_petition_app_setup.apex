public static Map<String, Contact> contacts = new Map<String, Contact>();
public static Map<String, Course_Reviewer__c> reviewers = new Map<String, Course_Reviewer__c>();
public static Map<String, Transfer_Institution__c> institutions = new Map<String, Transfer_Institution__c>();
public static Map<String, Course_Petition__c> petitions = new Map<String, Course_Petition__c>();
public static Map<String, String> subjectMap = new Map<String, String>();

public static final date VALID_FROM_DATE = system.today();
public static final date VALID_TO_DATE = system.today().addYears(2);
public static Account acct = new Account();
public static Contact con = new Contact();

public static Id CONTACT_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
public static Id DOM_PETITION_RT_ID = Schema.SObjectType.Course_Petition__c.getRecordTypeInfosByDeveloperName().get('Domestic').getRecordTypeId();
public static Id INTL_PETITION_RT_ID = Schema.SObjectType.Course_Petition__c.getRecordTypeInfosByDeveloperName().get('International').getRecordTypeId();
public static Id REVIEWER_RT_ID = Schema.SObjectType.Course_Reviewer__c.getRecordTypeInfosByDeveloperName().get('Course_Reviewer').getRecordTypeId();
public static Id DOM_INST_RT_ID = Schema.SObjectType.Transfer_Institution__c.getRecordTypeInfosByDeveloperName().get('Domestic').getRecordTypeId();
public static Id INTL_INST_RT_ID = Schema.SObjectType.Transfer_Institution__c.getRecordTypeInfosByDeveloperName().get('International').getRecordTypeId();


// check if sandbox org
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {
    system.debug('in sandbox');
    
    // get account
    acct = getAccount('D. Eccles School of Business');
    
    // build contact 
    buildContact();
    createRecords(contacts.values());
    con = getContact(contacts.values(), 0);
    
    // build reviewers
    buildCourseReviewer('Legacy', 'Reviewer', 'ACCTG;BUS;ENTP;FINAN;IS;MGT;MKTG;OIS;OM;Other;QAMO;STRAT', 'All');
    buildCourseReviewer('Michael', 'Lewis', 'ACCTG', 'All');
    buildCourseReviewer('Jessica', 'Taverna', 'BUS', 'All'); 
    buildCourseReviewer('Brad', 'Williams', 'ENTP', 'All'); 
    buildCourseReviewer('Mike', 'Cooper', 'FINAN', 'All'); 
    buildCourseReviewer('Chong', 'Oh', 'IS', 'All'); 
    buildCourseReviewer('Lindsey', 'Gibson', 'MGT', 'All'); 
    buildCourseReviewer('Steve', 'Carson', 'MKTG', 'All'); 
    buildCourseReviewer('Glen', 'Schmidt', 'OIS', 'All'); 
    buildCourseReviewer('Sue', 'Sundar', 'OM', 'All'); 
    buildCourseReviewer('Scott', 'Schaefer', 'QAMO', 'All'); 
    buildCourseReviewer('Bonita', 'Austin', 'STRAT', 'All'); 
    createRecords(reviewers.values());
    
    
    // build DOM institutions
    for(String s : getPickListValuesIntoList('Transfer_Institution__c', 'Inst__c')) {
        buildTransferInstitution('Dom Inst Name ' + s, s, '', DOM_INST_RT_ID);
        break;
    }
    // built INTL institutions
    for(String s : getPickListValuesIntoList('Transfer_Institution__c', 'Institution_Country__c')) {
        if(s.equalsIgnoreCase('United States')) {
            continue;
        }
        buildTransferInstitution('Intl Inst Name ' + s, null, s, INTL_INST_RT_ID);
        break;
    }
    createRecords(institutions.values());
    
    
    // build petitions
    for(String uCourse : buildSubjectMap()) {
        String uSubj = subjectMap.get(uCourse);
        String reviewerId = reviewers.get(uSubj).id;
        String trSubj = 'TR ' + uSubj;
        String trCourseNum = '101';
        String trTitle = 'TR ' + uCourse;
        String conId = con.id;
        for(transfer_institution__c t: institutions.values()) {
            String recType = (string.valueOf(t.id) == DOM_INST_RT_ID ? DOM_PETITION_RT_ID : INTL_PETITION_RT_ID);
            // approved petition publish to website
            buildCoursePetitions(recType,uSubj,uCourse,trSubj,trCourseNum,trTitle,true, VALID_FROM_DATE, VALID_FROM_DATE,'Approved', 'C','Approved', reviewerId,t.id, conId);
            // denied petition publish to website
            buildCoursePetitions(recType,uSubj,uCourse,trSubj,trCourseNum,trTitle,true, VALID_FROM_DATE, VALID_FROM_DATE,'Denied', '','Denied', reviewerId,t.id, conId);
            // approved petition DO NOT publish to website
            buildCoursePetitions(recType,uSubj,uCourse,trSubj,trCourseNum,trTitle,false, VALID_FROM_DATE, VALID_FROM_DATE,'Approved', 'C','Approved', reviewerId,t.id, conId);
            // denied petition DO NOT publish to website
            buildCoursePetitions(recType,uSubj,uCourse,trSubj,trCourseNum,trTitle,false, VALID_FROM_DATE, VALID_FROM_DATE,'Denied', '','Denied', reviewerId,t.id, conId);
        }
    }
    
    createRecords(petitions.values());
    
} else {
    system.debug('in production');
}

// build course reviewers
public static void buildCourseReviewer(String firstName, String lastName, String subjects, String courses) {
    Course_Reviewer__c cr = new Course_Reviewer__c();
    cr.name = firstname + ' ' + lastname;
    if(firstName.equalsIgnoreCase('Legacy')) {
        cr.reviewer_email__c = 'salesforce@eccles.utah.edu';
    } else {
        cr.reviewer_email__c = firstName + '.' + lastName + '@eccles.utah.edu.invalid';
    }
    cr.course_subjects_reviewed__c = subjects;
    cr.courses_evaluated__c = courses;
    cr.reviewer_active_status__c = true;
    cr.recordTypeId = REVIEWER_RT_ID;
    reviewers.put(cr.course_subjects_reviewed__c, cr);
}

// build transfer institutions 

public static void buildTransferInstitution(String name, String state, String country, String recType) {
    Transfer_Institution__c t = new Transfer_Institution__c();
    t.name = name;
    t.Inst__c = state;
    t.Institution_Country__c = country;
    t.recordTypeId = recType;
    institutions.put(t.name, t);
}

// build course petitions
public static void buildCoursePetitions(String recType,String uSubject, String uCourse,String trSubject,String trCourseNum, String trTitle,Boolean publishToWebsite, Date validFromDate, Date validToDate,String status, String grade, String decision,String reviewerId,String institutionId,String contactId) {
    Course_Petition__c cp = new Course_Petition__c();
    cp.uofu_course_subject__c = uSubject;
    cp.uofu_course__c = uCourse;
    cp.transfer_course_subject__c = trSubject;
    cp.transfer_course_num__c = trCourseNum;
    cp.transfer_course_title__c = trTitle;
    cp.publish_to_website__c = publishToWebsite;
    cp.valid_from_date__c = validFromDate;
    cp.valid_to_date__c = validToDate;
    cp.petition_status__c = status;
    cp.required_grade__c = grade;
    cp.reviewer_decision__c = decision;
    cp.CourseReviewer__c = reviewerId;
    cp.Transfer_Institution__c = institutionId;
    cp.contact__c = contactId;
    cp.recordTypeId = recType;
    
    petitions.put(institutionId+reviewerId+uSubject+uCourse, cp);
    
}



public static void buildContact() {
    Contact c = new Contact();
    c.FirstName = 'Petition FN';
    c.LastName = 'LookupLN';
    c.student_id_number__c = 'u8675309';
    c.Email = 'petitionemail@invalid.com';
    c.recordTypeId = CONTACT_RT_ID;
    c.accountId = acct.id;
    contacts.put(c.student_id_number__c, c);
}

public static Contact getContact(List<Contact> contactList, Integer index){
    
    return contactList[index];
    
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


public static Set<String> getPickListValuesIntoList(String objectApiName, String FieldApiName){
    String obj = objectApiName;
    String field = FieldApiName;
    
    // Get the describe for the object
    DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(obj).getDescribe();
    // Get the field dynamically
    DescribeFieldResult fieldResult = objResult.fields.getMap().get(field).getDescribe();
    
    Map<String, Schema.PicklistEntry> pickListValuesList= new Map<String, Schema.PicklistEntry>();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
        pickListValuesList.put(pickListVal.getLabel(), pickListVal);
    }     
    
    return pickListValuesList.keySet();
}


// build subject map
public static Set<String> buildSubjectMap() {
    subjectMap.put('ACCTG 2600 - Survey of Accounting','ACCTG');
    subjectMap.put('BUS 1050 - Foundations of Business Thought','BUS');
    subjectMap.put('ENTP 5776 - Entrepreneurial Analytics','ENTP');
    subjectMap.put('FINAN 3040 - Financial Management','FINAN');
    subjectMap.put('IS 4410 - Information Systems','IS');
    subjectMap.put('MGT 3000 - Principles of Management','MGT');
    subjectMap.put('MKTG 4020 - Marketing Management','MKTG');
    subjectMap.put('OIS 2340 - Business Statistics','OIS');
    subjectMap.put('QAMO 3010 - Business Economics','QAMO');
    subjectMap.put('STRAT 5700 - Strategic Management','STRAT');
    return subjectMap.keySet();
}