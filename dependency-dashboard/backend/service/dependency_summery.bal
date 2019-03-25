import ballerina/io;
import ballerina/sql;
import ballerinax/jdbc;
import ballerina/config;

jdbc:Client dependencyUpdatesDb = new({
        url: config:getAsString("DATABASE_URL"),
        username: config:getAsString("DATABASE_USERNAME"),
        password: config:getAsString("DATABASE_PASSWORD"),
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
            log:printInfo("Successfully retrived summary data");
            return jsonConversionRet;
        } else {
            log:printError("Error in table to json conversion");
        }
    } else {
        log:printError("Select data from DEPENDENCY_SUMMARY table failed: "
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
            log:printInfo("Successfully retrived product data");
            return jsonConversionRet;
        } else {
            log:printError("Error in table to json conversion");
        }
    } else {
        log:printError("Select data from student table failed: "
                + <string>selectRet.detail().message);
    }
}

