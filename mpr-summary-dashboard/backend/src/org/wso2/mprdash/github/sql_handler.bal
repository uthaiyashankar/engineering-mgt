//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

package src.org.wso2.mprdash.github;

import ballerina.data.sql;
import ballerina.time;
import ballerina.collections;
import ballerina.io;
import ballerina.config;
import ballerina.log;
import src.org.wso2.mprdash.github.email;

const string constAll = "all";

@Description {value:"Corresponds to PRODUCT TABLE"}
public struct ProductRecord {
    int productId;
    string productName;
}

@Description {value:"Corresponds to PRODUCT_REPOS TABLE"}
public struct ProductRepoRecord {
    int repoId;
    string repoName;
    string repoUrl;
    string buildUrl;
    int productId;
    int orgId;
    string repoOwner;
}

@Description {value:"Corresponds to PRODUCT_VERSIONS TABLE"}
public struct ProductVersionRecord {
    int versionId;
    string ver;
    int productId;
}

@Description {value:"Corresponds to REPO_BRANCHES TABLE"}
public struct RepoBranchRecord {
    int branchId;
    string branchName;
    int repoId;
    int versionId;
}

@Description {value:"Corresponds to REPO_ORGS TABLE"}
public struct RepoOrgRecord {
    int orgId;
    string orgName;
}

@Description {value:"Corresponds to PRODUCT_PR TABLE"}
public struct ProductPrRecord {
    int prId;
    string prAuthor;
    string prUrl;
    string prTitle;
    time:Time createdDate;
    time:Time mergedDate;
    int docStatus;
    int marketingStatus;
    string milestone;
    int productId;
    int repoId;
}

@Description {value:"Corresponds to PRODUCT_MILESTONES TABLE"}
public struct ProductMilestoneRecord {
    int milestoneId;
    string milestoneName;
    time:Time startDate;
    time:Time endDate;
    int versionId;
}

public struct PRCountRecord {
    int docStatus;
    int count;
}

public struct TotPRCountRecord {
    int count;
}

public struct ProductMilestone {
    int milestoneId;
    string milestoneName;
    time:Time startDate;
    time:Time endDate;
    string productName;
    string ver;
}

struct GithubIdRecord {
    int userId;
    string emailAddress;
    string gitId;
}

public const int DocStatusNotStarted = 0;
public const int DocStatusDraftReceived = 1;
public const int DocStatusNoDraft = 2;
public const int DocStatusIssuesPending = 4;
public const int DocStatusNoImpact= 6;
public const int MarketingStatusNotStarted = 0;

const string DEFAULT_VERSION = "unknown";

map mapRepoToProduct = {};
map mapIdToProduct = {};
map mapProductToId = {};
map mapRepoToRepoId = {};
map mapOrgToId = {};
boolean productsLoaded = false;
boolean orgsLoaded = false;

string dbName;
string dbUser;
string dbPassword;
string dbHost;
int dbPort;
string dbURL;
boolean dbConfigLoaded;

public function loadDbConfig (string dbName_, string dbUser_,
                              string dbPassword_, string dbHost_, string dbPort_) {
    dbName = dbName_;
    dbUser = dbUser_;
    dbPassword = dbPassword_;
    dbHost = dbHost_;
    dbPort, _ = <int>dbPort_;
    dbURL = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "?verifyServerCertificate=false&useSSL=true&requireSSL=false";
    //dbURL = "jdbc:mysql://db-apps.wso2.com:3306/WSO2_PRODUCT_COMPONENT?autoReconnect=true&amp;verifyServerCertificate=false&amp;useSSL=true&amp;requireSSL=true";
    dbConfigLoaded = true;

    loadProducts();
    loadOrgs();
}

// Load orgs from db and save in mapOrgToId
function loadOrgs () {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    table dtOrgs = testDB.select("SELECT ORG_ID,ORG_NAME FROM REPO_ORGS", null, typeof RepoOrgRecord);
    while (dtOrgs.hasNext()) {
        var rs, _ = (RepoOrgRecord)dtOrgs.getNext();
        mapOrgToId[rs.orgName] = rs.orgId + "";
    }

    orgsLoaded = true;
    testDB.close();
}

public function getOrgs () (string[]) {
    if (!orgsLoaded) {
        loadOrgs();
    }
    return mapOrgToId.keys();
}

public function getReposInOrg (string orgName) (string[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }
    if (!orgsLoaded) {
        loadOrgs();
    }
    string[] repos = [];
    if (mapOrgToId.hasKey(orgName)) {
        var orgId, _ = (string)mapOrgToId[orgName];
        string strSql = "SELECT REPO_ID,REPO_NAME,REPO_URL,BUILD_URL,PRODUCT_ID,ORG_ID,REPO_OWNER
                        FROM PRODUCT_REPOS WHERE ORG_ID='" + orgId + "'";
        table tdRepos = testDB.select(strSql, null, typeof ProductRepoRecord);
        int i = 0;
        while (tdRepos.hasNext()) {
            var rs, _ = (ProductRepoRecord)tdRepos.getNext();
            repos[i] = rs.repoName;
            i = i + 1;
        }
    }

    testDB.close();
    return repos;
}

// Load products from db and save in mapRepoToProduct
function loadProducts () {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    table dtProducts = testDB.select("SELECT PRODUCT_ID,PRODUCT_NAME from PRODUCT ORDER BY PRODUCT_NAME", null, typeof ProductRecord);
    while (dtProducts.hasNext()) {
        var rs, _ = (ProductRecord)dtProducts.getNext();
        mapIdToProduct[rs.productId + ""] = rs.productName;
        mapProductToId[rs.productName] = rs.productId + "";
    }

    table dt = testDB.select("SELECT REPO_ID,REPO_NAME,REPO_URL,BUILD_URL,PRODUCT_ID,ORG_ID,REPO_OWNER
                             FROM PRODUCT_REPOS ORDER BY REPO_NAME", null, typeof ProductRepoRecord);
    while (dt.hasNext()) {
        var rs, _ = (ProductRepoRecord)dt.getNext();
        mapRepoToProduct[rs.repoName] = mapIdToProduct[rs.productId + ""];
        mapRepoToRepoId[rs.repoName] = rs.repoId + "";
    }
    productsLoaded = true;
    testDB.close();
}

public function getRepos () (string[]) {
    if (!productsLoaded) {
        loadProducts();
    }
    return mapRepoToProduct.keys();
}

//Get the product name given the repository name
public function getProduct (string repo) (string) {
    string product;
    if (mapRepoToProduct.hasKey(repo)) {
        var p, _ = (string)mapRepoToProduct[repo];
        product = p;
    } else if (!productsLoaded) {
        loadProducts();
    }

    if (mapRepoToProduct.hasKey(repo)) {
        var p, _ = (string)mapRepoToProduct[repo];
        product = p;
    } else {
        product = "unknown";
    }

    return product;
}

// Return the sql parameters given a pull request record
function getPullRequestParams (ProductPrRecord record) (sql:Parameter[]) {
    sql:Parameter p1 = {sqlType:sql:Type.VARCHAR, value:record.prAuthor};
    sql:Parameter p2 = {sqlType:sql:Type.VARCHAR, value:record.prUrl};
    sql:Parameter p3 = {sqlType:sql:Type.VARCHAR, value:record.prTitle};
    sql:Parameter p4 = {sqlType:sql:Type.DATETIME, value:record.createdDate.toString()};
    sql:Parameter p5 = {sqlType:sql:Type.DATETIME, value:record.mergedDate.toString()};
    sql:Parameter p6 = {sqlType:sql:Type.INTEGER, value:record.docStatus};
    sql:Parameter p7 = {sqlType:sql:Type.INTEGER, value:record.marketingStatus};
    sql:Parameter p8 = {sqlType:sql:Type.VARCHAR, value:record.milestone};
    sql:Parameter p9 = {sqlType:sql:Type.INTEGER, value:record.productId};
    sql:Parameter p10 = {sqlType:sql:Type.INTEGER, value:record.repoId};
    sql:Parameter[] p = [p1,p2, p3, p4, p5, p6, p7, p8, p9, p10];
    return p;
}

function updatePullRequests (sql:Parameter[][] bPara, string[] urls) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    int i = 0;
    foreach para in bPara {
        string sqlUpdate = string `
        INSERT INTO PRODUCT_PRS (PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,MERGED_DATE,
                                   DOC_STATUS,MARKETING_STATUS,MILESTONE, PRODUCT_ID, REPO_ID)
        SELECT * FROM (SELECT ? AS PR_AUTHOR, ? AS PR_URL,? AS PR_TITLE,? AS CREATED_DATE,? AS MERGED_DATE,
                            ? AS DOC_STATUS, ? AS MARKETING_STATUS, ? AS MILESTONE, ? AS PRODUCT_ID, ? AS REPO_ID) AS tmp
        WHERE NOT EXISTS (
            SELECT * FROM PRODUCT_PRS WHERE PR_URL = '<URL>'
        ) LIMIT 1;`;
        sqlUpdate = sqlUpdate.replace("<URL>", urls[i]);
        int c = testDB.update(sqlUpdate, para);
        i = i + 1;
    }
    testDB.close();
}

function getBranchId (string repoName, string branchName) (int) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    if (!productsLoaded) {
        loadProducts();
    }

    int branchId = -1;

    if (mapRepoToRepoId.hasKey(repoName)) {
        var repoId, _ = (string)mapRepoToRepoId[repoName];
        string strSql = "SELECT * from REPO_BRANCHES " +
                        "WHERE REPO_ID='" + repoId + "' AND " +
                        "BRANCH_NAME='" + branchName + "'";
        table dt = testDB.select(strSql, null, typeof RepoBranchRecord);
        if (dt.hasNext()) {
            var rs, _ = (RepoBranchRecord)dt.getNext();
            branchId = rs.branchId;
        }

        if(dt.hasNext()) {
            log:printError("Multiple branches for repo '" + repoName +
                            "' , branch '" + branchName + "'.");
        }
    }
    testDB.close();
    return branchId;
}

function getRepo (string repoName) (ProductRepoRecord) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
            sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
            {maximumPoolSize:5, url:dbURL});
    }

    ProductRepoRecord repo;

    string strSql = "SELECT REPO_ID,REPO_NAME,REPO_URL,BUILD_URL,PRODUCT_ID,ORG_ID,REPO_OWNER
                    FROM PRODUCT_REPOS WHERE REPO_NAME='" + repoName + "'";
    table dt = testDB.select(strSql, null, typeof ProductRepoRecord);
    if (dt.hasNext()) {
        var rs, _ = (ProductRepoRecord)dt.getNext();
        repo = rs;
    }

    testDB.close();
    return repo;
}

function getVersionId (int productId, string versionName) (int) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
            sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
            {maximumPoolSize:5, url:dbURL});
    }

    int versionId = -1;

    string strSql = "SELECT * from PRODUCT_VERSIONS WHERE PRODUCT_ID='" + productId + "' AND VERSION='" + versionName + "'";
    table dt = testDB.select(strSql, null, typeof ProductVersionRecord);
    if (dt.hasNext()) {
        var rs, _ = (ProductVersionRecord)dt.getNext();
        versionId = rs.versionId;
    }

    testDB.close();
    return versionId;
}

public function insertPullRequests (collections:Vector records) {
    if (records == null) {
        return;
    }
    int i = 0;
    int j = 0;
    sql:Parameter[][] bPara = [];
    string[] urls = [];
    while (i < records.size()) {
        var pr, _ = (PullRequest)records.get(i);
        ProductPrRecord prR = {};
        pr.title = pr.title.replace("\"", "\\\"");
        prR.prTitle = pr.title;
        prR.prUrl = pr.prUrl;
        prR.prAuthor = pr.author;
        prR.createdDate = pr.createdAt;
        prR.mergedDate = pr.mergedAt;
        prR.docStatus = pr.docStatus;
        prR.milestone = pr.milestone;
        prR.marketingStatus = MarketingStatusNotStarted;
        i = i + 1;

        //int branchId = getBranchId(pr.repoName, pr.base);
        //if (branchId < 1) {
        ProductRepoRecord repo = getRepo(pr.repoName);
            if (repo == null) {
                log:printError("product was not found according to the repository.");
                next;
            }

            //int versionId = getVersionId(repo.productId, DEFAULT_VERSION);
            //if (versionId < 1) {
            //    insertDefaultVersion(repo.productId);
            //    versionId = getVersionId(repo.productId, DEFAULT_VERSION);
            //}

            //insertBranch(pr.base, repo.repoId, versionId);

            if (mapRepoToProduct.hasKey(pr.repoName)) {
                var prod,_=(string)mapRepoToProduct[pr.repoName];
                var prodId,_= (string)mapProductToId[prod];
                prR.productId,_= <int>prodId;
            }
            if (mapRepoToRepoId.hasKey(pr.repoName)) {
                var repoStr,_=(string)mapRepoToRepoId[pr.repoName];
                prR.repoId,_= <int>repoStr;
            }
            //branchId = getBranchId(pr.repoName, pr.base);
        //}

        //prR.branchId = branchId;

        bPara[j] = getPullRequestParams(prR);
        urls[j] = prR.prUrl;
        j = j + 1;
    }

    updatePullRequests(bPara, urls);
}

public function insertBranch (string branchName, int repoId, int versionId) {

    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    sql:Parameter branchNameParam = {sqlType:sql:Type.VARCHAR, value:branchName};
    sql:Parameter repoIdParam = {sqlType:sql:Type.INTEGER, value:repoId};
    sql:Parameter versionIdParam = {sqlType:sql:Type.INTEGER, value:versionId};
    sql:Parameter[] params = [branchNameParam, repoIdParam, versionIdParam];

    int res = testDB.update("INSERT INTO REPO_BRANCHES(BRANCH_NAME,REPO_ID,VERSION_ID) VALUES (?,?,?)", params);

    testDB.close();

}

public function insertDefaultVersion (int productId) {

    endpoint<sql:ClientConnector> testDB {
    create sql:ClientConnector(
    sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
    {maximumPoolSize:5, url:dbURL});
    }

    sql:Parameter versionParam = {sqlType:sql:Type.VARCHAR, value:DEFAULT_VERSION};
    sql:Parameter productIdParam = {sqlType:sql:Type.INTEGER, value:productId};
    sql:Parameter[] params = [versionParam, productIdParam];

    int res = testDB.update("INSERT INTO PRODUCT_VERSIONS(VERSION,PRODUCT_ID) VALUES (?,?)", params);

    testDB.close();

}

public function getProducts () (string[]) {
    string[] products = [];
    int i = 0;

    if (!productsLoaded) {
        loadProducts();
    }

    string[] excludeProducts = ["Unknown", "Other"];

    foreach value in mapIdToProduct.values() {
        var s, _ = (string)value;
        var excludeProduct = false;
        foreach exProduct in excludeProducts {
            if (s == exProduct) {
                excludeProduct = true;
            }
        }
        if (excludeProduct) {
            next;
        }
        products[i] = s;
        i = i + 1;
    }
    return products;
}

public function getVersions (string product) (string[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    string[] versions = [];

    if (!productsLoaded) {
        loadProducts();
    }

    int i = 0;
    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];
        string strSql = "SELECT DISTINCT PRODUCT_ID, MILESTONE FROM PRODUCT_PRS
                        WHERE PRODUCT_ID = \'<ID>\' GROUP BY PRODUCT_ID,MILESTONE
                        ORDER BY MILESTONE;";
        strSql = strSql.replace("<ID>", productId);
        table dtVersions = testDB.select(strSql, null, typeof ProductVersionRecord);
        while (dtVersions.hasNext()) {
            var rs, _ = (ProductVersionRecord)dtVersions.getNext();
            versions[i] = rs.ver;
            i = i + 1;
        }
    }

    testDB.close();
    return versions;
}

public function getBranches (string product, string ver) (RepoBranchRecord[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    RepoBranchRecord[] branches = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];
        string strSql = "SELECT * from PRODUCT_VERSIONS where PRODUCT_ID=\'<ID>\' AND VERSION=\'<VERSION>\'";
        strSql = strSql.replace("<ID>", productId);
        strSql = strSql.replace("<VERSION>", ver);
        table dtVersions = testDB.select(strSql, null, typeof ProductVersionRecord);
        if (dtVersions.hasNext()) {
            var rs, _ = (ProductVersionRecord)dtVersions.getNext();
            string versionId = rs.versionId + "";
            strSql = "SELECT * from REPO_BRANCHES where VERSION_ID=\'<ID>\'";
            strSql = strSql.replace("<ID>", versionId);
            table dtBranches = testDB.select(strSql, null, typeof RepoBranchRecord);
            int i = 0;
            while (dtBranches.hasNext()) {
                var rb, _ = (RepoBranchRecord)dtBranches.getNext();
                branches[i] = rb;
                i = i + 1;
            }
        }
    }
    testDB.close();
    return branches;
}

public function getBarnchesInRepos (string product) (RepoBranchRecord[]) {
    endpoint<sql:ClientConnector> testDB {
    create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    RepoBranchRecord[] branches = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];
        string strSql = "SELECT * from PRODUCT_REPOS where PRODUCT_ID=\'<ID>\'";
        strSql = strSql.replace("<ID>", productId);

        table dtVersions = testDB.select(strSql, null, typeof ProductRepoRecord);
        int i = 0;
        while (dtVersions.hasNext()) {
            var rs, _ = (ProductRepoRecord)dtVersions.getNext();
            string repoId = rs.repoId + "";
            strSql = "SELECT * from REPO_BRANCHES where REPO_ID=\'<ID>\'";
            strSql = strSql.replace("<ID>", repoId);
            table dtBranches = testDB.select(strSql, null, typeof RepoBranchRecord);
            while (dtBranches.hasNext()) {
                var rb, _ = (RepoBranchRecord)dtBranches.getNext();
                branches[i] = rb;
                i = i + 1;
            }
        }
    }
    testDB.close();
    return branches;
}

public function getPullReqsForVersionByStatus(string product, string ver, time:Time start,
    time:Time end, string docState) (ProductPrRecord[]) {

    endpoint<sql:ClientConnector> testDB {
    create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] prs = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];

        sql:Parameter param1 = {sqlType:sql:Type.INTEGER, value:productId};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:ver};
        sql:Parameter param3 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param4 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter param5 = {sqlType:sql:Type.INTEGER, value:docState};
        sql:Parameter[] params = [param1, param2, param3, param4, param5];

        string strSql = "SELECT PR_ID,PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,
                        MERGED_DATE,DOC_STATUS,MARKETING_STATUS,MILESTONE,PRODUCT_ID
                        FROM PRODUCT_PRS WHERE PRODUCT_ID=? AND MILESTONE=? AND
                        MERGED_DATE>=? AND MERGED_DATE<=? AND DOC_STATUS=?";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        int i = 0;
        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            prs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return prs;
}

public function getPullReqsForVersion(string product, string ver, time:Time start,
    time:Time end) (ProductPrRecord[]) {

    endpoint<sql:ClientConnector> testDB {
    create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] prs = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];

        sql:Parameter param1 = {sqlType:sql:Type.INTEGER, value:productId};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:ver};
        sql:Parameter param3 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param4 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter[] params = [param1, param2, param3, param4];

        string strSql = "SELECT PR_ID,PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,
                        MERGED_DATE,DOC_STATUS,MARKETING_STATUS,MILESTONE,PRODUCT_ID
                        FROM PRODUCT_PRS WHERE PRODUCT_ID=? AND MILESTONE=? AND
                        MERGED_DATE>=? AND MERGED_DATE<=?";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        int i = 0;
        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            prs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return prs;
}

public function getPullReqsForAllVersionsByStatus(string product, time:Time start,
    time:Time end, string docState) (ProductPrRecord[]) {

    endpoint<sql:ClientConnector> testDB {
    create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] prs = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];

        sql:Parameter param1 = {sqlType:sql:Type.INTEGER, value:productId};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param3 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter param4 = {sqlType:sql:Type.INTEGER, value:docState};
        sql:Parameter[] params = [param1, param2, param3, param4];

        string strSql = "SELECT PR_ID,PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,
                        MERGED_DATE,DOC_STATUS,MARKETING_STATUS,MILESTONE,PRODUCT_ID
                        FROM PRODUCT_PRS WHERE PRODUCT_ID=? AND
                        MERGED_DATE>=? AND MERGED_DATE<=? AND DOC_STATUS=?";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        int i = 0;
        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            prs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return prs;
}

public function getPullReqsForAllVersions(string product, time:Time start,
    time:Time end) (ProductPrRecord[]) {

    endpoint<sql:ClientConnector> testDB {
    create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] prs = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];

        sql:Parameter param1 = {sqlType:sql:Type.INTEGER, value:productId};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param3 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter[] params = [param1, param2, param3];

        string strSql = "SELECT PR_ID,PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,
                        MERGED_DATE,DOC_STATUS,MARKETING_STATUS,MILESTONE,PRODUCT_ID
                        FROM PRODUCT_PRS WHERE PRODUCT_ID=? AND
                        MERGED_DATE>=? AND MERGED_DATE<=?";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        int i = 0;
        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            prs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return prs;
}

public function getPrsForVersion (string product, string ver) (ProductPrRecord[]) {
    endpoint<sql:ClientConnector> testDB {
    create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] prs = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];
        string strSql = "SELECT PR_ID,PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,
                        MERGED_DATE,DOC_STATUS,MARKETING_STATUS,MILESTONE,PRODUCT_ID
                        FROM PRODUCT_PRS
                        WHERE PRODUCT_ID=\'<ID>\' AND MILESTONE=\'<VERSION>\'";
        strSql = strSql.replace("<ID>", productId);
        strSql = strSql.replace("<VERSION>", ver);
        table dtPRs = testDB.select(strSql, null, typeof ProductPrRecord);
        int i = 0;
        while (dtPRs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPRs.getNext();
            prs[i] = rb;
            i = i + 1;
        }

    }
    testDB.close();
    return prs;
}

public function getPullRequestsInBranch (RepoBranchRecord[] branches, time:Time start,
                                         time:Time end) (ProductPrRecord[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] prs = [];

    int i = 0;
    foreach branch in branches {

        sql:Parameter param1 = {sqlType:sql:Type.INTEGER, value:branch.branchId};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param3 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter[] params = [param1, param2, param3];

        string strSql = "SELECT * from PRODUCT_PRS where BRANCH_ID=? AND
                        MERGED_DATE>=? AND MERGED_DATE<=?";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            prs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return prs;
}

public function getPullRequestsByStatus (ProductPrRecord[] prs, time:Time start,
    time:Time end, string docState) (ProductPrRecord[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] filteredPrs = [];

    int i = 0;
    foreach pr in prs {

        sql:Parameter param1 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter param3 = {sqlType:sql:Type.INTEGER, value:docState};
        sql:Parameter[] params = [param1, param2, param3];

        string strSql = "SELECT PR_ID,PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,
                        MERGED_DATE,DOC_STATUS,MARKETING_STATUS,MILESTONE,PRODUCT_ID
                        FROM PRODUCT_PRS WHERE
                        MERGED_DATE>=? AND MERGED_DATE<=? AND DOC_STATUS=?";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            filteredPrs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return filteredPrs;
}

public function getPullRequests (ProductPrRecord[] prs, time:Time start,
    time:Time end) (ProductPrRecord[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] filteredPrs = [];

    int i = 0;
    foreach pr in prs {

        sql:Parameter param1 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter[] params = [param1, param2];

        string strSql = "SELECT PR_ID,PR_AUTHOR,PR_URL,PR_TITLE,CREATED_DATE,
                        MERGED_DATE,DOC_STATUS,MARKETING_STATUS,MILESTONE,PRODUCT_ID
                        FROM PRODUCT_PRS WHERE
                        MERGED_DATE>=? AND MERGED_DATE<=? ";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            filteredPrs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return filteredPrs;
}

public function getPullRequestsInBranchwithDocState (RepoBranchRecord[] branches, time:Time start,
    time:Time end, string docState) (ProductPrRecord[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    ProductPrRecord[] prs = [];

    int i = 0;
    foreach branch in branches {

        sql:Parameter param1 = {sqlType:sql:Type.INTEGER, value:branch.branchId};
        sql:Parameter param2 = {sqlType:sql:Type.VARCHAR, value:start.toString()};
        sql:Parameter param3 = {sqlType:sql:Type.VARCHAR, value:end.toString()};
        sql:Parameter param4 = {sqlType:sql:Type.INTEGER, value:docState};
        sql:Parameter[] params = [param1, param2, param3, param4];

        string strSql = "SELECT * from PRODUCT_PRS where BRANCH_ID=? AND
                            MERGED_DATE>=? AND MERGED_DATE<=? AND DOC_STATUS=?";

        table dtPrs = testDB.select(strSql, params, typeof ProductPrRecord);

        while (dtPrs.hasNext()) {
            var rb, _ = (ProductPrRecord)dtPrs.getNext();
            prs[i] = rb;
            i = i + 1;
        }
    }
    testDB.close();
    return prs;
}

function getEmailDetails(ProductPrRecord[] prs) (string[][]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }
    string[][] emails = [];
    int i = 0;

    foreach pr in prs {
        string strSql = "SELECT * FROM GITHUB_USERS WHERE USERNAME='" + pr.prAuthor + "'";
        table dtGitIds = testDB.select(strSql, null, typeof GithubIdRecord);
        if(dtGitIds.hasNext()) {
            var rb, _ = (GithubIdRecord)dtGitIds.getNext();
            if(rb.emailAddress=="") {
                log:printError("Email address not found for GitHub ID '" + pr.prAuthor + "'.");
                next;
            }
            emails[i] = [rb.emailAddress,pr.prUrl];
            i = i + 1;
        } else {
            log:printError("GitHub ID '" + pr.prAuthor + "' not found.");
        }
    }

    testDB.close();
    return emails;
}

public function updateState (json records) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }
    ProductPrRecord[] prsToNotify = [];
    int i = 0;
    foreach record in records {
        var docStatus, _ = (int)record["docStatus"];
        var marketingStatus, _ = (int)record["marketingStatus"];
        var id, _ = (int)record["prId"];
        string strSql = "UPDATE PRODUCT_PRS SET DOC_STATUS='" + docStatus + "'";
        strSql = strSql + " WHERE PR_ID='" + id + "'";
        int c = testDB.update(strSql, null);
        strSql = "UPDATE PRODUCT_PRS SET MARKETING_STATUS='" + marketingStatus + "'";
        strSql = strSql + " WHERE PR_ID='" + id + "'";
        c = testDB.update(strSql, null);

        try {
            var sendEmail,_ = (boolean)record["docSendEmail"];
            if(sendEmail) {
                strSql = "SELECT PR_ID, PR_AUTHOR, PR_URL, PR_TITLE, CREATED_DATE,
                          MERGED_DATE, DOC_STATUS, MARKETING_STATUS, MILESTONE,
                          PRODUCT_ID, REPO_ID
                          FROM PRODUCT_PRS WHERE PR_ID='" + id + "'";
                table dtPrs = testDB.select(strSql, null, typeof ProductPrRecord);
                if(dtPrs.hasNext()) {
                    var rb, _ = (ProductPrRecord)dtPrs.getNext();
                    prsToNotify[i] = rb;
                    i = i + 1;
                }
            }
        } catch(error e) {
            log:printError(e.message);
        }
    }

    testDB.close();

    string[][] emailDetails = getEmailDetails(prsToNotify);
    if((lengthof emailDetails)>0) {
        email:notifyPrIssues(emailDetails);
    }
}

public function insertMilestone(string name,string product,string ver,
                                time:Time start,time:Time end) (boolean) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    if (!productsLoaded) {
        loadProducts();
    }

    string strSql = "SELECT * from PRODUCT_MILESTONES where MILESTONE_NAME='"+name+"'";
    table dtMilestones = testDB.select(strSql, null, typeof ProductMilestoneRecord );
    if(dtMilestones.hasNext()) {
        testDB.close();
        return false;
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];
        strSql = "SELECT * from PRODUCT_VERSIONS where PRODUCT_ID=\'<ID>\' AND VERSION=\'<VERSION>\'";
        strSql = strSql.replace("<ID>", productId);
        strSql = strSql.replace("<VERSION>", ver);
        table dtVersions = testDB.select(strSql, null, typeof ProductVersionRecord);
        if (dtVersions.hasNext()) {
            var rs, _ = (ProductVersionRecord)dtVersions.getNext();
            sql:Parameter p1 = {sqlType:sql:Type.VARCHAR, value:name};
            sql:Parameter p2 = {sqlType:sql:Type.DATETIME, value:start.toString()};
            sql:Parameter p3 = {sqlType:sql:Type.DATETIME, value:end.toString()};
            sql:Parameter p4 = {sqlType:sql:Type.INTEGER, value:rs.versionId};

            sql:Parameter[] para = [p1,p2,p3,p4];

            string sqlUpdate = string `INSERT INTO PRODUCT_MILESTONES(
                MILESTONE_NAME,
                START_DATE,
                END_DATE,
                VERSION_ID
            ) VALUES(?,?,?,?)`;

            int c = testDB.update(sqlUpdate, para);
        }
    }
    testDB.close();
    return true;
}

function getMilestoneRecords()(ProductMilestoneRecord[]) {
     endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    if (!productsLoaded) {
        loadProducts();
    }

    ProductMilestoneRecord[] milestones = [];

    string strSql = "SELECT * from PRODUCT_MILESTONES";
    table dtMilestones = testDB.select(strSql, null, typeof ProductMilestoneRecord );
    int i = 0;
    while(dtMilestones.hasNext()) {
        var rs, _ = (ProductMilestoneRecord)dtMilestones.getNext();
        milestones[i] = rs;
        i = i + 1;
    }
    testDB.close();
    return milestones;
}

function getProductAndVersion(int versionId)(string,string) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    string strSql = "SELECT * from PRODUCT_VERSIONS where VERSION_ID='" +
    versionId + "'";
    table dtVersions = testDB.select(strSql, null, typeof ProductVersionRecord);
    if(dtVersions.hasNext()) {
        var rv, _ = (ProductVersionRecord)dtVersions.getNext();
        var productName, _ = (string)mapIdToProduct[""+rv.productId];
        testDB.close();
        return productName,rv.ver;
    }
    testDB.close();
    return null,null;
}

public function getMilestones()(ProductMilestone[]) {
    if (!productsLoaded) {
        loadProducts();
    }

    ProductMilestone[] milestones = [];

    ProductMilestoneRecord[] records = getMilestoneRecords();
    int i = 0;
    foreach record in records {
        ProductMilestone milestone = {};
        milestone.milestoneId = record.milestoneId;
        milestone.milestoneName = record.milestoneName;
        milestone.startDate = record.startDate;
        milestone.endDate = record.endDate;
        var productName,ver = getProductAndVersion(record.versionId);
        milestone.productName = productName;
        milestone.ver = ver;
        milestones[i] = milestone;
        i = i + 1;
    }
    return milestones;
}

public function deleteMilestones(json records) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    string strSql = "DELETE from PRODUCT_MILESTONES where MILESTONE_ID='";

    foreach record in records {
        var id,_ = (int)record["id"];
        int c = testDB.update(strSql+id+"'", null);
    }
    testDB.close();
}

public function getPRCount (string product, string productVersion) (PRCountRecord[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    PRCountRecord[] prCount = [];

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];
        string strSql = "";
        if(productVersion.toLowerCase() == constAll){
            strSql = "SELECT DOC_STATUS,COUNT(PR_ID) FROM PRODUCT_PRS
                      WHERE DOC_STATUS IN (0,1,2,3,4)
                      AND PRODUCT_ID=\'<ID>\'
                      GROUP BY DOC_STATUS;";

            strSql = strSql.replace("<ID>", productId);
        } else {
            strSql = "SELECT DOC_STATUS,COUNT(PR_ID) FROM PRODUCT_PRS
                      WHERE DOC_STATUS IN (0,1,2,3,4)
                      AND MILESTONE=\'<VERSION>\'
                      AND PRODUCT_ID=\'<ID>\'
                      GROUP BY DOC_STATUS;";

            strSql = strSql.replace("<ID>", productId);
            strSql = strSql.replace("<VERSION>", productVersion);
        }
        table dtPRCount = testDB.select(strSql, null, typeof PRCountRecord);
        int i = 0;
        while (dtPRCount.hasNext()) {
            var res, _ = (PRCountRecord)dtPRCount.getNext();
            prCount[i] = res;
            i = i + 1;
        }
    }
    testDB.close();
    return prCount;
}

public function getTotalPRCount (string product, string productVersion) (TotPRCountRecord) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, dbHost, dbPort, dbName, dbUser, dbPassword,
        {maximumPoolSize:5, url:dbURL});
    }

    TotPRCountRecord prCount;

    if (!productsLoaded) {
        loadProducts();
    }

    if (mapProductToId.hasKey(product)) {
        var productId, _ = (string)mapProductToId[product];
        string strSql = "";

        if(productVersion.toLowerCase() == constAll){
            strSql = "SELECT COUNT(PR_ID) FROM PRODUCT_PRS
                      WHERE DOC_STATUS IN (0,1,2,3,4) AND PRODUCT_ID=\'<ID>\';";
            strSql = strSql.replace("<ID>", productId);
        }else {
            strSql = "SELECT COUNT(PR_ID) FROM PRODUCT_PRS
                      WHERE DOC_STATUS IN (0,1,2,3,4) AND PRODUCT_ID=\'<ID>\'
                      AND MILESTONE=\'<VERSION>\';";
            strSql = strSql.replace("<ID>", productId);
            strSql = strSql.replace("<VERSION>", productVersion);
        }

        table dtPRCount = testDB.select(strSql, null, typeof TotPRCountRecord);
        var res, _ = (TotPRCountRecord)dtPRCount.getNext();
        prCount = res;
        dtPRCount.close();
    }
    testDB.close();
    return prCount;
}
