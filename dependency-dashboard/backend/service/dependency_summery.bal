import ballerina/io;
import ballerina/sql;
import ballerinax/jdbc;

jdbc:Client dependencyUpdatesDb = new({
        url: "jdbc:mysql://192.168.100.66:3306/WSO2_PRODUCT_COMPONENT",
        username: "admin",
        password: "admin",
        poolOptions: { maximumPoolSize: 5 },
        dbOptions: { useSSL: false }
    });

type Summery record {
    int summaryId;
    int repoId;
    int usingLatestVersion;
    int nextVersion;
    int nextIncremental;
    int nextMinor;
    int nextMajor;
    string repoName;
    string orgName;
    string productName;

};

type Product record {
    string repoName;
    string orgName;
    string productName;
};

public function getSummeryData() returns (json) {
    string statement = "Select DEPENDENCY_SUMMARY.* , PRODUCT_REPOS.REPO_NAME,REPO_ORGS.ORG_NAME,PRODUCT.PRODUCT_NAME
    from DEPENDENCY_SUMMARY,PRODUCT_REPOS,REPO_ORGS,PRODUCT where PRODUCT.PRODUCT_ID=PRODUCT_REPOS.PRODUCT_ID &&
    REPO_ORGS.ORG_ID=PRODUCT_REPOS.ORG_ID && PRODUCT_REPOS.REPO_ID = DEPENDENCY_SUMMARY.REPO_ID;";
    var selectRet = dependencyUpdatesDb->select(statement, Summery);
    if (selectRet is table<Summery>) {
        var jsonConversionRet = json.convert(selectRet);
        if (jsonConversionRet is json) {
            return jsonConversionRet;
        } else {
            io:println("Error in table to json conversion");
        }
    } else {
        io:println("Select data from student table failed: "
                + <string>selectRet.detail().message);
    }
}

public function getProductDetails() returns (json) {
    string statement = "Select PRODUCT_REPOS.REPO_NAME,REPO_ORGS.ORG_NAME,PRODUCT.PRODUCT_NAME from PRODUCT_REPOS,PRODUCT,
    REPO_ORGS where PRODUCT.PRODUCT_ID=PRODUCT_REPOS.PRODUCT_ID && REPO_ORGS.ORG_ID=PRODUCT_REPOS.ORG_ID";
    var selectRet = dependencyUpdatesDb->select(statement, Product);
    if (selectRet is table<Product>) {
        var jsonConversionRet = json.convert(selectRet);
        if (jsonConversionRet is json) {
            return jsonConversionRet;
        } else {
            io:println("Error in table to json conversion");
        }
    } else {
        io:println("Select data from student table failed: "
                + <string>selectRet.detail().message);
    }
}

