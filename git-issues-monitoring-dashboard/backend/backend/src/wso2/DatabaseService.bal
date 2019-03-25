//Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/mysql;
import ballerina/log;
import ballerina/time;
import ballerina/config;

mysql:Client productRepoTable = new({
        host: config:getAsString("DB_HOST"),
        port: config:getAsInt("DB_PORT"),
        name: config:getAsString("DB_NAME"),
        username: config:getAsString("UNAME"),
        password: config:getAsString("PASS"),
        poolOptions: { maximumPoolSize: 10 },
        dbOptions: { useSSL: false }
    });

function retreaveRepositoriesFromDatabase(string productName) returns (json) {
    string selectQuery = "SELECT PRODUCT_REPOS.REPO_NAME,REPO_ORGS.ORG_NAME FROM PRODUCT_REPOS,
    PRODUCT, REPO_ORGS where PRODUCT_REPOS.ORG_ID = REPO_ORGS.ORG_ID and PRODUCT.PRODUCT_ID = PRODUCT_REPOS.PRODUCT_ID
    and PRODUCT.PRODUCT_NAME = '" + productName + "'";

    var repoNames = productRepoTable->select(selectQuery, ());

    if (repoNames is table< record {} >) {
        var jsonConvertedRepo = json.convert(repoNames);
        if jsonConvertedRepo is error{
            log:printError("Error occured while retreaving data from product table", err = jsonConvertedRepo);
        } else {
            return jsonConvertedRepo;
        }
    }
}

function retreaveRepositoryDetailsByRepoName(string repoName) returns (json) {
    var selectQuery = "SELECT REPO_ORGS.ORG_NAME, PRODUCT_REPOS.REPO_NAME FROM
    PRODUCT_REPOS Inner Join REPO_ORGS On PRODUCT_REPOS.ORG_ID = REPO_ORGS.ORG_ID
    and REPO_NAME ='" + repoName + "'";
    var repoDetails = productRepoTable->select(selectQuery, ());

    if (repoDetails is table< record {} >) {
        var repoDetailsJson = json.convert(repoDetails);
        if (repoDetailsJson is json) {
            return repoDetailsJson;
        } else if (repoDetailsJson is error){
            log:printError("Error occured while retreaving data from product table", err = repoDetailsJson);
        }
    } else {
        log:printError("Retreaving Repository Details By RepoName failed: "
                + <string>repoDetails.detail().message);
    }
}

function getAllProductNames() returns (json) {
    var productNames = productRepoTable->select("SELECT PRODUCT_NAME FROM PRODUCT", ());
    if (productNames is table< record {} >) {
        var productNamesJson = json.convert(productNames);
        if (productNamesJson is json) {
            return productNamesJson;
        } else {
            log:printError("Error occured while converting the retreaved product names to json", err = productNamesJson)
            ;
        }
    } else {
        log:printError("Error occured while retreaving the product names from Database", err = productNames);
    }
}

function insertIntoIssueCountTable(json message) {
    int productIterator = 0;
    time:Time currentTime = time:currentTime();

    while (productIterator < message.length()) {
        string productName = <string>message[productIterator].Product;
        int totalIssueCount = <int>message[productIterator].TotalCount;
        int l1IssueCount = <int>message[productIterator].L1IssueCount;
        int l2IssueCount = <int>message[productIterator].L2IssueCount;
        int l3IssueCount = <int>message[productIterator].L3IssueCount;

        var ret = productRepoTable->update("INSERT INTO GIT_ISSUE_COUNT(TimeStamp, ProductName, TotalIssueCount,
        L1IssueCount, L2IssueCount,L3IssueCount) Values ( \"" + currentTime.time + "\",\"" + productName + "\"," +
                totalIssueCount + ","
                + l1IssueCount + "," + l2IssueCount + ","
                + l3IssueCount + ") ON DUPLICATE KEY UPDATE TimeStamp=" + currentTime.time + ", TotalIssueCount=" +
                totalIssueCount + ", L1IssueCount= "
                + l1IssueCount + ", L2IssueCount=" + l2IssueCount + ", L3IssueCount=" + l3IssueCount);

        handleUpdate(ret, "Insert to IssueCount table with no parameters");
        productIterator = productIterator + 1;
    }
}

function handleUpdate(int|error returned, string message) {
    if (returned is int) {
        log:printDebug(message + " status: " + returned);
    } else {
        log:printError(message + " failed: " + <string>returned.detail().message);
    }
}


