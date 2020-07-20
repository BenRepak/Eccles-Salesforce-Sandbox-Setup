import os

ORG_AUTH_MESSAGE = '''
This script is intended to assist admins in setting up a new sandbox. 
Full details can be found in the project's readme: https://github.com/BenRepak/Eccles-Salesforce-Sandbox-Setup
To begin, enter the name of the default org for this project here >>>   
'''

_sfdx_org = 'bentest'


def set_sfdx_org():
    global _sfdx_org
    _sfdx_org = input(ORG_AUTH_MESSAGE)
    command = '''sfdx force:config:set defaultusername=''' + _sfdx_org
    os.system(command)


def sfdx_execute_anonymous(script_path):
    command = 'sfdx force:apex:execute -f ' + script_path + ' -u ' + _sfdx_org
    os.system(command)


def sfdx_retreive_source(source_path):
    command = 'sfdx force:source:retrieve --sourcepath ' + \
        source_path + ' -u ' + _sfdx_org
    os.system(command)


def sfdx_deploy_source(source_path):
    command = 'sfdx force:source:deploy --sourcepath ' + \
        source_path + ' -u ' + _sfdx_org
    os.system(command)


def sfdx_execute_query(query_string):
    command = 'sfdx force:data:soql:query -q ' + \
        query_string + ' --json -u ' + _sfdx_org
    return os.popen(command).read()
