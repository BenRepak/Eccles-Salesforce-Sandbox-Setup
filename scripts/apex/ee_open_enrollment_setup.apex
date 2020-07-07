public static List<Discount__c> discounts = new List<Discount__c>();
public static List<Campaign> parentCampaigns = new List<Campaign>();
public static List<Campaign> programCampaigns = new List<Campaign>();
public static List<Campaign> sessionCampaigns = new List<Campaign>();
public static List<Campaign> classCampaigns = new List<Campaign>();
public static Id parentCampaignId;
public static Id AMT_DISC_RT_ID = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Amount_Discount').getRecordTypeId();
public static Id PERC_DISC_RT_ID = Schema.SObjectType.Discount__c.getRecordTypeInfosByDeveloperName().get('Percent_Discount').getRecordTypeId();
public static Id AUTH_GATE_RT_ID = Schema.SObjectType.ChargentBase__Gateway__c.getRecordTypeInfosByDeveloperName().get('Authorizenet').getRecordTypeId();
public static Id EE_CAMPAIGN_RT_ID = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Executive_Education').getRecordTypeId();
public static List<String> programNames = new List<String>();

// check if sandbox org
Organization currentOrg = [SELECT IsSandbox FROM Organization LIMIT 1][0];
System.debug(currentOrg);

if(currentOrg.isSandbox) {
    System.debug('in sandbox');
    
    createGateway();
    
    updateChargentSiteUrl();
    
    buildDiscounts(20);
    
    createDiscounts();
    
    // construct exec ed parent
    createParentCampaign();
    
    // construct list of program names to be used in hierarcy
    buildProgramNameList();
    
    // construct  programs
    buildProgramCampaigns();
    createCampaigns(programCampaigns);
    
    // construct  sessions
    buildCampaigns(programCampaigns, sessionCampaigns);
    createCampaigns(sessionCampaigns);
    
    // construct  classes
    buildCampaigns(sessionCampaigns, classCampaigns);
    createCampaigns(classCampaigns);
    
} else {
    system.debug('in production');
}

/**
*
* Build & insert gateway
*
*/
public static void createGateway() {
    
    List<ChargentBase__Gateway__c> gateways = [SELECT Id FROM ChargentBase__Gateway__c WHERE name = 'Authorize.net Prod' and recordtypeid = :AUTH_GATE_RT_ID LIMIT 1];
    ChargentBase__Gateway__c g = new ChargentBase__Gateway__c();
    
    g.ChargentBase__Merchant_ID__c = ''; // to be completed manually;
    g.ChargentBase__Security_Key__c = ''; // to be completed manually
    g.ChargentBase__Active__c = true;
    g.ChargentBase__Test_Mode__c = true;
    g.ChargentBase__Require_CCV__c = true;
    g.ChargentBase__Credit_Card_Data_Handling__c = 'Clear After Successful Charge';
    g.ChargentBase__Clear_CCV2_Code__c = true;
    g.ChargentBase__Available_Card_Types__c = 'Visa;Mastercard;American Express';
    g.ChargentBase__Require_CVV__c = true;
    
    if(gateways.size() > 0) {
        update g;  
    } else {
        g.recordtypeid = AUTH_GATE_RT_ID;
        g.name = 'Authorize.net Prod';
        insert g;
    }
}

/**
*
* Update Chargent Settings Site URL
*
*/
public static void updateChargentSiteUrl(){
    ChargentBase__Chargent_Settings__c cs = ChargentBase__Chargent_Settings__c.getOrgDefaults();
    String siteName = 'ExecEdApplication';
    Site mySite = [select Id from Site where Name =: siteName];
    SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
    cs.ChargentBase__SFDC_Sites_Page__c = mySiteDetail.SecureURL + '/ExecEdPurchase';
    update cs;
}  
/**
*
* Build discounts
*
*/
public static void buildDiscounts(Integer numberofDiscounts){
    system.debug('build discounts');
    Integer futureYear = System.today().year() + 2;
    Date todayDate = System.today();
    Date futureDate = date.valueOf(futureYear + '-12-31');
    
    for(Integer i = 0; i < numberOfDiscounts; i ++)  {
        Discount__c amountDiscount = new Discount__c();
        amountDiscount.recordTypeId = AMT_DISC_RT_ID;
        amountDiscount.description__c = 'Descrpition for discount ' + i;
        amountDiscount.discount_amount__c = 10*i;
        amountDiscount.code__c = i+'AMT'+ amountDiscount.discount_amount__c;
        amountDiscount.valid_start_date__c = todayDate;
        amountDiscount.valid_end_date__c = futureDate;
        discounts.add(amountDiscount);
        
        Decimal randomNumber = Math.random();
        if(randomNumber == 0) {
            randomNumber += 0.5;
        } 
        randomNumber = randomNumber.setScale(2, RoundingMode.UP);
        
        Discount__c percentageDiscount = new Discount__c();
        percentageDiscount.recordTypeId = PERC_DISC_RT_ID;
        percentageDiscount.description__c = 'Descrpition for discount ' + i;
        percentageDiscount.percentage__c = 100 * randomNumber;
        percentageDiscount.code__c = i+'PERC'+ percentageDiscount.percentage__c;
        percentageDiscount.valid_start_date__c = todayDate;
        percentageDiscount.valid_end_date__c = futureDate;
        discounts.add(percentageDiscount);        
    }
}   


/**
*
* Create discounts
*
*/
public static void createDiscounts() {
    if(discounts.size() > 0) {
        insert discounts;
    }
}

/**
*
* Build list of program names
*
*/
public static void buildProgramNameList() {
    List<Product2> products = [SELECT Name FROM product2 WHERE isActive = true];
    for(Product2 p : products) {
        programNames.add(p.Name);
    }
}

/**
*
* Build & insert parent campaign
*
*/

public static void createParentCampaign() {
    Campaign c = new Campaign();
    c.recordTypeId = EE_CAMPAIGN_RT_ID;
    c.name = 'Exec Ed';
    c.type = 'Exec Ed Program';
    c.isActive = true;
    insert c;
    parentCampaignId = c.id;
}


/**
*
* Build program campaigns
*
*/
public static void buildProgramCampaigns(){
    for(String s : programNames) {
        Campaign c = new Campaign();
        c.name = 'Program - ' + s;
        c.type = 'Exec Ed Program';
        c.recordTypeId = EE_CAMPAIGN_RT_ID;
        c.isActive = true;
        c.parentid = parentCampaignId;
        programCampaigns.add(c);
    }
}


/**
*
* Build campaigns
*
*/
public static void buildCampaigns(List<Campaign> parentCampaigns, List<Campaign> newCampaigns){
    system.debug('parentCampaigns : ' + parentCampaigns);
    system.debug('newCampaigns : ' + newCampaigns);
    Date futureDate = System.today().addYears(1);
    Integer futureYear = System.today().year()+1;
    
    for(campaign pc : parentCampaigns) {
        system.debug('pc >>> ' + pc);
        
        Campaign c = new Campaign();
        String campaignType = pc.name.substringBefore('-').trim();
        
        switch on campaignType {
            when 'Program' {
                c.name = 'Session - ' + pc.name.substringafter(' - ') + ' - Fall ' + (futureYear + parentCampaigns.indexOf(pc));
            }
            when 'Session' {
                c.name = 'Class - ' + pc.name.substringafter(' - ') + ' - Number ' + parentCampaigns.indexOf(pc);
                c.StartDate = futureDate;
                c.EndDate = futureDate;
            }
        }
        c.parentId = pc.id;
        c.type = 'Exec Ed Program';
        c.recordTypeId = EE_CAMPAIGN_RT_ID;
        c.isActive = true;
        if(c.name.length() <= 80 ) {
            newCampaigns.add(c); 
        }
    }  
}


/**
*
* Insert Campaigns
*
*/
public static void createCampaigns(List<Campaign> campaigns) {
    if(campaigns.size() > 0) {
        insert campaigns;
        system.debug('campaigns >>> ' + campaigns);
    }   
}