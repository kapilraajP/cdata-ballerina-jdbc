import ballerina/io;
import ballerinax/java.jdbc;
import ballerina/config;


// JDBC client created using CData JDBC driver. 
jdbc:Client cdataSalesforceDB = new ({
    url: "jdbc:salesforce:User=" + config:getAsString("username") + ";Password=" + config:getAsString("password") + ";Security Token=" + config:getAsString("token")
});

type SalesforceAccount record {
    string id; 
    string name; 
    string? accType; 
    string? accountNumber;
    string? industry;
    string? description; 
};

public function main() {

    // Get Salesforce Accounts table. 
    // var selectRet = cdataSalesforceDB->select("SELECT Id, Name, Type, AccountNumber, Industry, Description FROM Account",
    //                                 SalesforceAccount);
    var selectRet = cdataSalesforceDB->select("SELECT Id, Name, Type, AccountNumber, Industry, Description FROM Account " 
                                                + "WHERE Id IS NOT NULL",
                                    SalesforceAccount);

    if (selectRet is table<record{}>) {
        foreach var item in selectRet {
            io:print(item.toString());
        }
    } else {
        io:println("Select data from Salesforce Accounts table has failed: ",
        <string>selectRet.detail()?.message);
    }


    SalesforceAccount sampleAccount = {
        id: "ACC_000000",
        name: "Test Account", 
        accType: "Customer - Direct", 
        accountNumber: "CD355119-TEST",
        industry: "Energy", 
        description: "Test account desc."
    };

    // Create Salesforce Account
    var ret = cdataSalesforceDB->update("INSERT INTO Account (Name, Type, AccountNumber, Industry, Description) VALUES " +
                          "(?, ?, ?, ?, ?)", 
                          sampleAccount.name, 
                          sampleAccount.accType ?: "", 
                          sampleAccount.accountNumber ?: "", 
                          sampleAccount.industry ?: "", 
                          sampleAccount. description ?: "");
    if (ret is jdbc:UpdateResult) {
        io:println("Inserted row count: ", ret.updatedRowCount);
        io:println("Generated key: ", ret.generatedKeys.get("Id"));
        sampleAccount.id = ret.generatedKeys.get("Id").toString(); 
    } else {
        io:println("Insert failed: ", <string>ret.detail()?.message);
    }

    selectRet = cdataSalesforceDB->select("SELECT Id, Name, Type, AccountNumber, Industry, Description FROM Account WHERE Id = ?",
                                    SalesforceAccount, sampleAccount.id.toString());
    if (selectRet is table<record{}>) {
        foreach var item in selectRet {
            io:print(item.toString());
        }
    } else {
        io:println("Select data from Salesforce Accounts table has failed: ",
        <string>selectRet.detail()?.message);
    }
    

}