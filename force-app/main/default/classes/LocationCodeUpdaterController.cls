public without sharing class LocationCodeUpdaterController {
    @auraEnabled
    public static List<Account> updateRecords(List<String> accountsName, String jsonObject){
        List<Account> csvAccounts = (List<Account>)JSON.deserialize(jsonObject, List<Account>.class);
        Map<String, Account> csvAccountsMap = new Map<String, Account>();
        for(Account account : csvAccounts){
            csvAccountsMap.put(account.Name, account);
        }

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name IN :accountsName];
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> accountsToInsert = new List<Account>();
        Set<String> existingAccountNames = new Set<String>();

        for(Account account : accounts){
            if(csvAccountsMap.containsKey(account.Name)){
                account.Location_Code__c = csvAccountsMap.get(account.Name).Location_Code__c;
                account.Active_Location__c = csvAccountsMap.get(account.Name).Active_Location__c;
                account.Location_Status__c = csvAccountsMap.get(account.Name).Location_Status__c;
                accountsToUpdate.add(account);
                existingAccountNames.add(account.Name);
            }
        }

        for(Account csvAccount : csvAccounts){
            if(!existingAccountNames.contains(csvAccount.Name)){
                if (!String.isBlank(csvAccount.ShippingStateCode) ) {
                    csvAccount.ShippingState = getStateNameByCode(csvAccount.ShippingStateCode);
                }
                accountsToInsert.add(csvAccount);
            }
        }


        update accountsToUpdate;
        insert accountsToInsert;

        accountsToUpdate.addAll(accountsToInsert);
        return accountsToUpdate;
    }

    private static String getStateNameByCode(String stateCode) {
        Map<String, String> stateCodeToNameMap = new Map<String, String>{
            'AL' => 'Alabama',
            'AK' => 'Alaska',
            'AZ' => 'Arizona',
            'AR' => 'Arkansas',
            'CA' => 'California',
            'CO' => 'Colorado',
            'CT' => 'Connecticut',
            'DE' => 'Delaware',
            'FL' => 'Florida',
            'GA' => 'Georgia',
            'HI' => 'Hawaii',
            'ID' => 'Idaho',
            'IL' => 'Illinois',
            'IN' => 'Indiana',
            'IA' => 'Iowa',
            'KS' => 'Kansas',
            'KY' => 'Kentucky',
            'LA' => 'Louisiana',
            'ME' => 'Maine',
            'MD' => 'Maryland',
            'MA' => 'Massachusetts',
            'MI' => 'Michigan',
            'MN' => 'Minnesota',
            'MS' => 'Mississippi',
            'MO' => 'Missouri',
            'MT' => 'Montana',
            'NE' => 'Nebraska',
            'NV' => 'Nevada',
            'NH' => 'New Hampshire',
            'NJ' => 'New Jersey',
            'NM' => 'New Mexico',
            'NY' => 'New York',
            'NC' => 'North Carolina',
            'ND' => 'North Dakota',
            'OH' => 'Ohio',
            'OK' => 'Oklahoma',
            'OR' => 'Oregon',
            'PA' => 'Pennsylvania',
            'RI' => 'Rhode Island',
            'SC' => 'South Carolina',
            'SD' => 'South Dakota',
            'TN' => 'Tennessee',
            'TX' => 'Texas',
            'UT' => 'Utah',
            'VT' => 'Vermont',
            'VA' => 'Virginia',
            'WA' => 'Washington',
            'WV' => 'West Virginia',
            'WI' => 'Wisconsin',
            'WY' => 'Wyoming'
        };
        return stateCodeToNameMap.get(stateCode);
    }
}