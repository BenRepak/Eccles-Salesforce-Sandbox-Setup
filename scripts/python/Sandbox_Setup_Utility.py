import os
import sfdx_helper as sh
import Custom_Label_Updater as clu

# set default org
print('<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>')
print('setting default sfdx org started....')
sh.set_sfdx_org()
print('setting default sfdx org....COMPLETE!')


# build house accounts
print('<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>')
print('building house accounts started....')
path_house_account = '''./scripts/apex/01-house_account_setup.apex'''
sh.sfdx_execute_anonymous(path_house_account)
print('building house accounts....COMPLETE!')

# update admin users
print('<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>')
print('updating admin email addresses started....')
path_admin_update = '''./scripts/apex/02-admin_email_update.apex'''
sh.sfdx_execute_anonymous(path_admin_update)
print('updating admin email addresses....COMPLETE!')

# retrieve CustomLabels source
print('<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>')
print('retreiving CustomLabel metadata source started....')
path_custom_labels = '''./force-app/main/default/labels/CustomLabels.labels-meta.xml'''
sh.sfdx_retreive_source(path_custom_labels)
print('retreiving CustomLabel metadata source....COMPLETE!')

# update CustomLabels source
print('<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>')
print('process sh.main_custom_label_process started....')
clu.main_custom_label_process()
print('process sh.main_custom_label_process....COMPLETE!')

# deploy CustomLabels source
print('<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>')
print('deploying CustomLabel metadata source started....')
path_custom_labels = '''./force-app/main/default/labels/CustomLabels.labels-meta.xml'''
sh.sfdx_deploy_source(path_custom_labels)
print('deploying CustomLabel metadata source....COMPLETE!')

# DONE
print('<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>')
print('sandbox setup is complete. Please complete any additional manual steps as outlined in  https://github.com/BenRepak/Eccles-Salesforce-Sandbox-Setup')
