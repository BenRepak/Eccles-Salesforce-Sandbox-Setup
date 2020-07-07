# Salesforce Sandbox Setup Overview

Instructions TBD

## Script Descriptions

The following scripts can be run using execute anonymous commands. For example:

`sfdx force:apex:execute -f ./directory/sub_directory/file_name.apex`

Descriptions and snippets to execute common scripts are below. Be sure to replace instances of <<sandbox>> with the desired destination sandbox that has been authorized in the CLI.

More information on the sfdx CLI commands can be found here: https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_apex.htm

### 01-house_account_setup.apex

Creates Accounts with a record type of Eccles House Account for commonly used house accounts (e.g. D. Eccles School of Business, Executive Education, External Relations, etc). The code will only create records if an existing account with a matching name and record type does not already exist.

`sfdx force:apex:execute -f ./scripts/apex/01-house_account_setup.apex -u <<sandbox>>`

### 02-admin_email_update.apex

Updates invalid email addresses for active users with Admin role.

`sfdx force:apex:execute -f ./scripts/apex/02-admin_email_update.apex -u <<sandbox>>`
