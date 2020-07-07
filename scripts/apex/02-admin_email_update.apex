// only execute if in Sandbox environment
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
if(currentOrg.isSandbox) {
    System.debug('in sandbox');
    AdminEmailUpdateUtility adminEmailUtility = new AdminEmailUpdateUtility();
}


public class AdminEmailUpdateUtility{
    private List<User> exisingAdminUsers = new List<User>();
    private List<User> usersToUpdate = new List<User>();

    String oldBadEmailSuffixString = '@example.com';
    String newBadEmailSuffixString = '.invalid';
    // constructor
    public AdminEmailUpdateUtility(){
        getExistingAdminUser();
        processInvalidUserEmailSuffixes();
        updateUsers();
    }

   
   private void getExistingAdminUser(){
       exisingAdminUsers = [SELECT id, email FROM User WHERE isactive = true AND usertype = 'standard' AND userrole.name = 'Admin'];
       system.debug('exisingAdminUsers -----------------------------> ' + exisingAdminUsers);
   }

   private void processInvalidUserEmailSuffixes(){
       for(user u : exisingAdminUsers) {
           Boolean requiresUpdate = false;
            if (u.email.contains(oldBadEmailSuffixString)) {
                u.email = u.email.removeEnd(oldBadEmailSuffixString);
                u.email = u.email.replace('=','@');
                requiresUpdate = true;
            } else if (u.email.contains(newBadEmailSuffixString)){
                requiresUpdate = true;
                u.email = u.email.removeEnd(newBadEmailSuffixString);
            } 
            if(requiresUpdate){
                usersToUpdate.add(u);
            }
        }
       system.debug('usersToUpdate -----------------------------> ' + usersToUpdate);
   }
   
   private void updateUsers(){
       if(usersToUpdate.size() > 0) {
           update usersToUpdate;
       }
   }

} // end of class