import xml.etree.ElementTree as ET
import os
import json

file = './force-app/main/default/labels/CustomLabels.labels-meta.xml'
outFile = file
house_accounts = []
org_label_dict = {}
other_label_dict = {}
uri = ''
uri_namespace = ''


def build_org_label_dict():
    dict = {}
    dict["External_Relations"] = "External Relations"
    dict["Undergrad"] = "D. Eccles School of Business"
    dict["AccountId"] = "Executive Education"
    dict["Executive_Education"] = "Executive Education"
    return dict


def build_other_label_dict():
    dict = {}
    dict["EB_Exception_Emails"] = "salesforce@eccles.utah.edu"
    return dict


def write_xml_file():
    print('write_xml_file')
    tree = ET.ElementTree(root)
    tree.write(outFile, encoding='UTF-8',  xml_declaration=True)


def get_house_accounts():
    print('get_house_accounts')
    org = input(
        'Enter name of sfdx org alias. To see a list of your authorized orgs, type "help"')
    if org == 'help':
        command = '''sfdx force:org:list'''
        os.system(command)
        return None
    else:
        command = '''sfdx force:data:soql:query -q "SELECT Id, Name FROM Account WHERE recordtype.Name = 'Eccles House Account'" --json -u ''' + org
        output = os.popen(command).read()
        parsed = json.loads(output)
        records = parsed["result"]["records"]
        return records


def get_house_account_id_by_name(name, data):
    account = next((item for item in data if item.get("Name") == name), None)
    if account != None:
        print('account ------> ', account)
        print('account id ------> ', account["Id"])
        return account["Id"]
    else:
        return 'Unknown'


def build_uri(root):
    uriIndex = root.tag.find('}')
    if uriIndex != -1:
        uriIndex += 1
    return root.tag[0:uriIndex]


def build_uri_namespace(uri):
    return uri.strip('{}')


tree = ET.parse(file)
root = tree.getroot()
uri = build_uri(root)


uri_namespace = build_uri_namespace(uri)
ET.register_namespace('', uri_namespace)
house_accounts = get_house_accounts()

if house_accounts != None:
    org_label_dict = build_org_label_dict()
    other_label_dict = build_other_label_dict()

    for child in root:
        full_name = child.find(uri+"fullName").text
        if org_label_dict.get(full_name):
            name = org_label_dict.get(full_name)
            value = get_house_account_id_by_name(name, house_accounts)
            print('name --> ' + name)
            print('value --> ' + value)
            child.find(uri+"value").text = value
        elif other_label_dict.get(full_name):
            value = other_label_dict.get(full_name)
            print('name --> ' + name)
            print('value --> ' + value)
            child.find(uri+"value").text = value

    write_xml_file()
