import xml.etree.ElementTree as ET
import os
import json
import sfdx_helper as sh

file = './force-app/main/default/labels/CustomLabels.labels-meta.xml'
outFile = file
house_accounts = []
org_label_dict = {}
other_label_dict = {}
uri_namespace = ''
uri = ''
tree = ET.parse(file)


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
    global tree
    global outFile
    tree = ET.ElementTree(root)
    tree.write(outFile, encoding='UTF-8',  xml_declaration=True)


def get_house_accounts():
    query_string = '''"SELECT Id, Name FROM Account WHERE recordtype.Name = 'Eccles House Account'"'''
    output = sh.sfdx_execute_query(query_string)
    parsed = json.loads(output)
    records = parsed["result"]["records"]
    return records


def get_house_account_id_by_name(name, data):
    account = next((item for item in data if item.get("Name") == name), None)
    if account != None:
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


def main_custom_label_process():
    global tree
    global root
    global uri
    global uri_namespace
    global house_accounts
    global org_label_dict
    global other_label_dict

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
                child.find(uri+"value").text = value
            elif other_label_dict.get(full_name):
                value = other_label_dict.get(full_name)
                child.find(uri+"value").text = value
        write_xml_file()
