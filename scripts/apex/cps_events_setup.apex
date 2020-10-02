public static List<String> degreeNames = new List<String>();
public static Map<String, Degree__c> degrees = new Map<String, Degree__c>();

public static List<String> ProgramNames = new List<String>();
public static Map<String, CPS_Program__c> programs = new Map<String,CPS_Program__c>();

public static List<Location__c> locations = new List<Location__c>();

public static List<String> eventNames = new List<String>();
public static List<Event__c> events = new List<Event__c>();
public static List<Event_Session__c> sessions = new List<Event_Session__c>();

public static Id EVENT_EVT_RT_ID = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
public static Id EXTERNAL_RELATIONS_RT_ID = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get('External_Relations_Event').getRecordTypeId();
public static Id POLICY_INST_EVT_RT_ID = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get('Policy_Institute').getRecordTypeId();

public static Id EVENT_SES_RT_ID = Schema.SObjectType.Event_Session__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();

// check if sandbox org
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {
system.debug('in sandbox');

// construct and insert programs
buildPrograms();
createRecords(programs.values());

// construct and insert degrees
buildDegrees();
createRecords(degrees.values());

// construct and insert locations
createLocations();
createRecords(locations);


// construct and insert events
createEvents();
createRecords(events);

// construct and insert sessions
createSessions();
createRecords(sessions);


} else {
    system.debug('in production');
}
public static void buildPrograms() {
    programNames.add('External Relations');
    programNames.add('Policy Institute');
    programNames.add('Full-Time MBA Program');
    programNames.add('MBA Online');
    programNames.add('Professional MBA Program');
    programNames.add('Executive Education Program');
    programNames.add('Executive MBA Program');
    programNames.add('Alumni Event');
    for(String s : programNames) {
        CPS_Program__c p = new CPS_Program__c();
        p.name = s;
        p.show_on_the_website__c = true;
        programs.put(p.name, p);
    }
}
//SELECT Location__c,Name,Program__r.name FROM Degree__c where program__r.show_on_the_website__c = true

public static void buildDegrees() {
    degreeNames.add('Policy Institute');
    degreeNames.add('Full-Time MBA Degree');
    degreeNames.add('MBA Online Degree');
    degreeNames.add('PMBA Degree');
    degreeNames.add('Exec Ed Degree');
    degreeNames.add('Executive Education');
    degreeNames.add('EMBA Degree');
    degreeNames.add('Alumni');

    for(String s : degreeNames) {
        Degree__c d = new Degree__c();
        d.name = s;
        if(s.equalsIgnoreCase('Policy Institute')) {
            d.Program__c = programs.get('Policy Institute').id;
        } else if(s.equalsIgnoreCase('Full-Time MBA Degree')) {
            d.Program__c = programs.get('Full-Time MBA Program').id;
        } else if(s.equalsIgnoreCase('MBA Online Degree')) {
            d.Program__c = programs.get('MBA Online').id;
        } else if(s.equalsIgnoreCase('PMBA Degree')) {
            d.Program__c = programs.get('Professional MBA Program').id;
        } else if(s.equalsIgnoreCase('Exec Ed Degree')) {
            d.Program__c = programs.get('Executive Education Program').id;
        } else if(s.equalsIgnoreCase('Executive Education')) {
            d.Program__c = programs.get('Executive Education Program').id;
        } else if(s.equalsIgnoreCase('EMBA Degree')) {
            d.Program__c = programs.get('Executive MBA Program').id;
        } else if(s.equalsIgnoreCase('Alumni')) {
            d.Program__c = programs.get('Alumni Event').id;
        } 
        degrees.put(d.name, d);
    }

    for(CPS_Program__c p : programs.values()) {
        Degree__c d = new Degree__c();
        d.Program__c = p.id;
        String degreeName = '';

            if(p.name.equalsIgnoreCase('Policy Institute')) {
                degreeName = 'Policy Institute';
            } else if(p.name.equalsIgnoreCase('Full-Time MBA Program')) {
                degreeName = 'Full-Time MBA Degree';
            } else if(p.name.equalsIgnoreCase('MBA Online')) {
                degreeName = 'MBA Online Degree';
            } else if(p.name.equalsIgnoreCase('Professional MBA Program')) {
                degreeName = 'PMBA Degree';
            } else if(p.name.equalsIgnoreCase('Executive Education Program')) {
                degreeName = 'Executive Education';
            } else if(p.name.equalsIgnoreCase('Executive MBA Program')) {
                degreeName = 'EMBA Degree';
            } else if(p.name.equalsIgnoreCase('Alumni Event')) {
                degreeName = 'Alumni';
            }
        
        d.Name = degreeName;
        degrees.put(d.name, d);
    }

}

public static void createLocations() {

    Integer locationCeiling = 20;
    Integer locationCounter = 1;

    while(locationCounter < locationCeiling) {
        Location__c l = new Location__c();
        l.name = 'Name ' + locationCounter;
        l.room__c = 'Room ' + locationCounter;
        l.street__c =  locationCounter + '00 Street';
        l.city__c = 'City ' + locationCounter;
        l.state__c = 'UT';
        l.postal_code__c = '12345';
        locations.add(l);
        locationCounter++;
    }
}


public static void createEvents() {
    eventNames.add('Alumni Event 1');
    eventNames.add('Alumni Event 2');
    eventNames.add('EMBA Event 1');
    eventNames.add('EMBA Event 2');
    eventNames.add('FTMBA Event 1');
    eventNames.add('FTMBA Event 2');
    eventNames.add('MBAO Event 1');
    eventNames.add('MBAO Event 2');
    eventNames.add('PMBA Event 1');
    eventNames.add('PMBA Event 2');
    eventNames.add('EE Event 1');
    eventNames.add('EE Event 2');

    for(string s : eventNames) {
        Event__c e = new Event__c();
        e.name = s;
        e.description__c = 'This is a description for the event.';
        if(s.startsWithIgnoreCase('Alumni')) {
            e.recordtypeid = EXTERNAL_RELATIONS_RT_ID;
            e.event_type__c = 'Alumni Event';
            e.programs__c = 'Alumni Event';
        }

        if(e.recordtypeid == null) {
            e.recordtypeid = EVENT_EVT_RT_ID;
        }

        if(s.startsWithIgnoreCase('EMBA')) {
            e.programs__c = 'Executive MBA Program';
            e.event_type__c = 'Executive MBA';
        } else if(s.startsWithIgnoreCase('FTMBA')) {
            e.programs__c = 'Full-Time MBA Program';
            e.event_type__c = 'Full-Time MBA';
        } else if(s.startsWithIgnoreCase('MBAO')) {
            e.programs__c = 'MBA Online';
            e.event_type__c = 'MBA Online';
        } else if(s.startsWithIgnoreCase('PMBA')) {
            e.programs__c = 'Professional MBA Program';
            e.event_type__c = 'PMBA';
        } else if(s.startsWithIgnoreCase('EE')) {
            e.programs__c = 'Executive Education Program';
            e.event_type__c = 'Executive Education';
        }

        events.add(e);
    }

}


public static void createSessions() {
    Date todayDate = system.today();
    Date futureDate = todayDate.addYears(2);
    String year = string.valueOf(futureDate.year());
    String month = string.valueOf(futureDate.month());
    String day = string.valueOf(futureDate.day());
    String futureDateString = year+'-'+month+'-'+day;


    for(Event__c e : events) {

        Event_Session__c s = new Event_Session__c();
        s.name = futureDateString + ' ' + e.name + ' Session';
        s.event__c = e.id;

        Integer randomIndex = Integer.valueof((Math.random() * 19));
        s.location__c = locations.get(randomIndex).id;

        if(e.programs__c.startsWithIgnoreCase('Executive MBA')) {
            s.degree__c = degrees.get('EMBA Degree').id;
        } else if(e.programs__c.startsWithIgnoreCase('Full-Time MBA')) {
            s.degree__c = degrees.get('Full-Time MBA Degree').id;
        } else if(e.programs__c.startsWithIgnoreCase('MBA Online')) {
            s.degree__c = degrees.get('MBA Online Degree').id;
        } else if(e.programs__c.startsWithIgnoreCase('PMBA')) {
            s.degree__c = degrees.get('PMBA Degree').id;
        } else if(e.programs__c.startsWithIgnoreCase('Alumni Event')) {
            s.degree__c = degrees.get('Alumni').id;
        } else if(e.programs__c.startsWithIgnoreCase('Executive Education Programs')) {
            s.degree__c = degrees.get('Executive Education ').id;
        } 
        s.show_on_the_website__c = true;
        s.Attendee_Special_Instructions__c = 'Special instructions for the attendee.';
        s.recordtypeid = EVENT_SES_RT_ID;
        s.Start_Date_Time__c = futureDate;
        s.End_Date_Time__c = futureDate.addDays(1);
        s.Status__c = 'Registration Open';
        sessions.add(s);
    }
}

public static void createRecords(List<Sobject> objs) {
    if(objs.size() > 0) {
        insert objs;
    }
}