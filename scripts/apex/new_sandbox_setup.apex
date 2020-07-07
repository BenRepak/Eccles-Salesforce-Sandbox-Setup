/**
Run the following in execute anonymous to:
1 - create sample House Accounts
2- update Admin email addresses 

TODO after running
1 - update Custom Labels to have valid org ID

*/





/**
* Step 1 -- check if in sandbox org
* avoids whoospie in production
*/

Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {
System.debug('in sandbox');

/**
*Step 2 -- decide which operations to run
*-createHouseAccounts --> creates organizations(Accoutns) that are of record type "Eccles School House Account"
*-updateAdminEmail --> removes ".invald" from admin email addresses, triggering an email reset email to be sent to admins
*/    

Boolean createHouseAccounts = TRUE;
Boolean updateAdminEmail = TRUE;

/**
*
*Step 3 -- create house account orgs if createHouseAccounts is TRUE
// TODO - when done, go to Custom Labels and update all the values to an org id in the "Org Labels" list 
*
*/

if(createHouseAccounts) {
    Id HouseAcctRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Eccles House Account').getRecordTypeId();
    List<Account> accts = new List<Account>();
    Set<String> names = new Set<String>();
    names.add('D. Eccles School of Business');
    names.add('External Relations');
    names.add('Executive Education');
    names.add('Exec Ed Other');
    names.add('Graduate Programs');
    names.add('MAcc');
    names.add('Business Scholars House Account');
    
    for(String s : names) {
        Account a = new Account();
        a.name = s;
        a.RecordTypeId = HouseAcctRecTypeid;
        accts.add(a);  
    }
    
    if(accts.size()>0) {
        insert accts;
    }
}


/**
*Step 4 -- update admin email addresses if updateAdminEmail is TRUE
*https://help.salesforce.com/articleView?id=000193090&type=1
* salesforce changed from using @example.com to appending .invalid
*/
if(updateAdminEmail) {
    
    List<User> adminUsers = new List<User>();
    List<User> adminUsersUpdate = new List<User>();
    
    
    String oldBadEmailString = '@example.com';
    String newBadEmailString = '.invalid';
    
    adminUsers = [SELECT id, email 
                  FROM User 
                  WHERE isactive = true AND usertype = 'standard' AND userrole.name = 'Admin'];
    
    for(user u : adminUsers) {
        if (u.email.contains(oldBadEmailString)) {
            u.email = u.email.removeEnd(oldBadEmailString);
            u.email = u.email.replace('=','@');
        } else if (u.email.contains(newBadEmailString)){
            u.email = u.email.removeEnd(newBadEmailString);
        } 
        
        adminUsersUpdate.add(u);
    }
    
    for(User u  : adminUsersUpdate) {
        system.debug('User>>> ' + u);
    }
    
     update adminUsersUpdate;
}
} else {
system.debug('in production');
}