# Salesforce Sandbox Setup Overview

Use this package to setup sandboxes in the Eccles Salesforce org.

## Prerequisites

- Microsoft VS Code installed
- SFDX CLI is installed
- Python is installed
- Destination sandbox is authorized using `sfdx force:auth ....` command (more info https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_auth.htm)

## Running Setup Scripts

Running the Sandbox_Setup_Utility script will execute various commands to setup the sandbox (see Python Script Descriptions below)

Execute using python2:

- `python ./scripts/python/Sandbox_Setup_Utility.py`

Execute using python3:

- `python3 ./scripts/python/Sandbox_Setup_Utility.py`

## Python Script Descriptions

The following scripts are used to run commands in the SFDX CLI.

### Sandbox_Setup_Utility.py

Prompts admin to login to authorized SFDX org and then runs the following apex scripts:

- ./scripts/apex/01-house_account_setup.apex
- ./scripts/apex/02-admin_email_update.apex

Pending implementation

- ./scripts/apex/advisor_coach_lookup_setup.apex
- ./scripts/apex/course_petitoin-app_setup.apex
- ./scripts/apex/cps_events_setup.apex
- ./scripts/apex/ee_open_enrollment_setup.apex
- ./scripts/apex/undergrad_core_lookup_set.apex

### Custom_Label_Updater.py

- Updates Org Custom Labels with new Account Ids (Undergrad, External Relations, Executive Education, AccountId)
- Changes value in EB Exception Emails to "salesforce@eccles.utah.edu"

### sfdx_helper.py

Contains some helper functions for interacting with the SFDX CLI used in other python scrtips.

## Apex Script Descriptions

The following scripts can be run using execute anonymous command as desired. For example:

`sfdx force:apex:execute -f ./directory/sub_directory/file_name.apex`

Descriptions and snippets to execute common scripts are below. Be sure to replace instances of `<<sandbox>>` with the desired destination sandbox that has been authorized in the CLI.

More information on the sfdx CLI commands can be found here: https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_apex.htm

### 01-house_account_setup.apex

Creates Accounts with a record type of Eccles House Account for commonly used house accounts (e.g. D. Eccles School of Business, Executive Education, External Relations, etc). The code will only create records if an existing account with a matching name and record type does not already exist.

`sfdx force:apex:execute -f ./scripts/apex/01-house_account_setup.apex -u <<sandbox>>`

### 02-admin_email_update.apex

Updates invalid email addresses for active users with Admin role.

`sfdx force:apex:execute -f ./scripts/apex/02-admin_email_update.apex -u <<sandbox>>`

### advisor_coach_lookup_setup.apex

Creates sample data for advisor / coach lookup app. More info: https://sites.google.com/a/gcloud.utah.edu/salesforce-knowledge-base/admin-only/force-com-sites/undergrad

`sfdx force:apex:execute -f ./scripts/apex/advisor_coach_lookup_setup.apex -u <<sandbox>>`

### application_program_setup.apex

Creates sample contact and application program records for the cohort programs. Currently 1 contact per program and 10 applications per contact.

`sfdx force:apex:execute -f ./scripts/apex/application_program_setup.apex -u <<sandbox>>`

### course_petition_app_setup.apex

Creates sample data for course petition app. More info: https://sites.google.com/a/gcloud.utah.edu/salesforce-knowledge-base/admin-only/force-com-sites/undergrad

`sfdx force:apex:execute -f ./scripts/apex/course_petition_app_setup.apex -u <<sandbox>>`

### cps_events_setup.apex

Creates sample data for CPS Event, Session, Session attendee app. More info: https://sites.google.com/a/gcloud.utah.edu/salesforce-knowledge-base/admin-only/app-setup/cps-events

`sfdx force:apex:execute -f ./scripts/apex/cps_events_setup.apex -u <<sandbox>>`

### ee_open_enrollment_setup.apex

Creates sample data for EE Open Enrollment app. More onfo: https://sites.google.com/a/gcloud.utah.edu/salesforce-knowledge-base/admin-only/force-com-sites/execedapplication

`sfdx force:apex:execute -f ./scripts/apex/ee_open_enrollment_setup.apex -u <<sandbox>>`


### leadership_development_program_setup.apex

Creates sample account and lrdprogram__c data for Leadership Development Program page for BCS site

`sfdx force:apex:execute -f ./scripts/apex/leadership_development_program_setup.apex -u <<sandbox>>`

### undergrad_core_lookup_setup.apex

Creates sample data for undergraduate curriculum lookup app. More info: https://sites.google.com/a/gcloud.utah.edu/salesforce-knowledge-base/admin-only/force-com-sites/undergrad

`sfdx force:apex:execute -f ./scripts/apex/undergrad_core_lookup_setup.apex -u <<sandbox>>`
