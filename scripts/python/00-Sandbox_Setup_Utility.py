import os

ORG_AUTH_MESSAGE = '''

This script is intended to assist admins in setting up a new sandbox. 

Full details can be found in the project's readme: https://github.com/BenRepak/Eccles-Salesforce-Sandbox-Setup

To begin, enter the name of the default org for this project here >>>   
'''

_sfdx_org = ''


def set_sfdx_org():
    org = input(ORG_AUTH_MESSAGE)
    command = '''sfdx force:config:set defaultusername='''+org
    os.system(command)
    return org


def sfdx_execute_anonymous(script_path, org):
    command = 'sfdx force:apex:execute -f ' + script_path + ' -u ' + org
    os.system(command)


def sfdx_retreive_source(source_path, org):
    command = 'sfdx force:source:retrieve --sourcepath ' + source_path + ' -u ' + org
    os.system(command)


def sfdx_deploy_source(source_path, org):
    command = 'sfdx force:source:retrieve --sourcepath ' + source_path + ' -u ' + org
    os.system(command)


# set default org
print('setting default sfdx org started....')
_sfdx_org = set_sfdx_org()
print('setting default sfdx org....COMPLETE!')


# build house accounts
print('building house accounts started....')
path_house_account = '''./scripts/apex/01-house_account_setup.apex'''
sfdx_execute_anonymous(path_house_account, _sfdx_org)
print('building house accounts....COMPLETE!')

# update admin users
print('updating admin email addresses started....')
path_admin_update = '''./scripts/apex/02-admin_email_update.apex'''
sfdx_execute_anonymous(path_admin_update, _sfdx_org)
print('updating admin email addresses....COMPLETE!')

# retrieve CustomLabels source
print('retreiving CustomLabel metadata source started....')
path_custom_labels = '''./force-app/main/default/labels/CustomLabels.labels-meta.xml'''
sfdx_retreive_source(path_custom_labels, _sfdx_org)
print('retreiving CustomLabel metadata source....COMPLETE!')

# update CustomLabels source
# TODO
print('pending implementation of updating custom labels')

# deploy CustomLabels source
print('deploying CustomLabel metadata source started....')
path_custom_labels = '''./force-app/main/default/labels/CustomLabels.labels-meta.xml'''
sfdx_deploy_source(path_custom_labels, _sfdx_org)
print('deploying CustomLabel metadata source....COMPLETE!')

#
