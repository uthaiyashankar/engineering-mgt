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
import ballerina/http;
import ballerina/log;
import ballerina/internal;
import ballerina/time;
import ballerina/task;
import ballerina/config;

task:Timer? timer = ();

listener http:Listener httpListener = new(9095);
string TRIGGER_AUTH_KEY = config:getAsString("TRIGGER_AUTH_KEY");
string GENERAL_AUTH_KEY = config:getAsString("GENERAL_AUTH_KEY");

@http:ServiceConfig {
    basePath: "/gitIssues"
}
service githubIssueService on httpListener {
    // Resource that handles the HTTP GET requests that are directed to a specific


    @http:ResourceConfig {
        methods: ["GET"],
        path: "/product/{productName}"
    }
    resource function retreaveAllIssuesByProduct(http:Caller caller, http:Request request, string productName) {
        // Find the requested order from the map and retrieve it in JSON format.
        time:Time startTime = time:currentTime();
        http:Response response = new;
        json[] issuesJson = [];
        int readArrayIndex = 0;
        json[] partialIssueJson = [];
        string labelFilter = "";
        json|error labelsJson = "";

        map<string> filterValues = request.getQueryParams();
        string? labelsString = filterValues["labels"];

        if labelsString is string{
            labelsJson = internal:parseJson(labelsString);
            if (labelsJson is json) {
                if (labelsJson.length() > 0) {
                    int numberOfLabels = labelsJson.length();
                    int labelsIterator = 0;
                    while (labelsIterator < numberOfLabels) {
                        labelFilter = labelFilter + <string>labelsJson[labelsIterator] + ",";
                        labelsIterator = labelsIterator + 1;
                    }
                }
            } else if (labelsJson is error){
                log:printError("Error occured while retreaving issue details", err = labelsJson);
            }
        }

        json repoDetails = retreaveRepositoriesFromDatabase(untaint productName);

        while (readArrayIndex < repoDetails.length()) {
            (partialIssueJson, readArrayIndex) = spliceArray(readArrayIndex, repoDetails);
            json[] intermediantIssueJson = executeReceiveIssuesFromGit(partialIssueJson, labelFilter, GENERAL_AUTH_KEY);

            foreach var item in intermediantIssueJson {
                issuesJson[issuesJson.length()] = item;
            }
        }

        response.setJsonPayload(untaint issuesJson);
        time:Time endTime = time:currentTime();
        int totalTime = endTime.time - startTime.time;
        // Send response to the client.
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/repository/label"
    }
    resource function retreaveIssuesFromRepoByLabel(http:Caller caller, http:Request request) {
        http:Response response = new;
        string labelFilter = "";
        json|error labelsJson = "";
        json issuesJson = [];
        json|error repoNamesJson = "";
        int readArrayIndex = 0;
        json[] partialIssueJson = [];
        json[] allRepodetails = [];

        map<string> filterValues = request.getQueryParams();
        string? labelsString = filterValues["labels"];
        string? repoNames = filterValues["repos"];

        if labelsString is string{
            labelsJson = internal:parseJson(labelsString);
            if (labelsJson is json) {
                if (labelsJson.length() > 0) {
                    int numberOfLabels = labelsJson.length();
                    int labelsIterator = 0;
                    while (labelsIterator < numberOfLabels) {
                        labelFilter = labelFilter + <string>labelsJson[labelsIterator] + ",";
                        labelsIterator = labelsIterator + 1;
                    }
                }
            } else if (labelsJson is error){
                log:printError("Error occured while retreaving issue details", err = labelsJson);
            }
        }

        if repoNames is string{
            repoNamesJson = internal:parseJson(repoNames);

            if repoNamesJson is json {
                if repoNamesJson != "" {
                    int numberOfRepos = repoNamesJson.length();
                    int repoNamesIterator = 0;
                    while (repoNamesIterator < numberOfRepos) {
                        json repoDetails = retreaveRepositoryDetailsByRepoName(untaint <string>repoNamesJson[
                            repoNamesIterator]);
                        allRepodetails[repoNamesIterator] = repoDetails[0];
                        repoNamesIterator = repoNamesIterator + 1;
                    }

                    while (readArrayIndex < allRepodetails.length()) {
                        (partialIssueJson, readArrayIndex) = spliceArray(readArrayIndex, allRepodetails);
                        json[] intermediantIssueJson = executeReceiveIssuesFromGit(partialIssueJson, labelFilter,
                            GENERAL_AUTH_KEY);

                        foreach var item in intermediantIssueJson {
                            issuesJson[issuesJson.length()] = item;
                        }
                    }
                }
            } else if (repoNamesJson is error){
                log:printError("Error occured while retreaving issue details", err = repoNamesJson);
            }
        } else {
            log:printError("Error occured while extracting the repo name");
        }

        response.setJsonPayload(untaint issuesJson);

        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/product/count"
    }
    resource function retreaveIssueCount(http:Caller caller, http:Request request) {
        http:Response response = new;

        var issueCountByProduct = triggerRetreaveIssueCount();
        if issueCountByProduct is json{
            response.setJsonPayload(untaint issueCountByProduct);
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        } else {
            log:printError("Error occured while retreaving issue count", err = issueCountByProduct);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/repos/"
    }
    resource function getAllRepos(http:Caller caller, http:Request request) {
        http:Response response = new;
        json[] repoNames = [];
        map<string> filterValues = request.getQueryParams();
        string? productName = filterValues["product"];

        if productName is string{
            if productName != "all"{
                int repoIterator = 0;
                json repoDetails = retreaveRepositoriesFromDatabase(untaint productName);

                while (repoIterator < repoDetails.length()) {
                    repoNames[repoNames.length()] = repoDetails[repoIterator].REPO_NAME;
                    repoIterator = repoIterator + 1;
                }
            } else {
                json productNames = getAllProductNames();
                int productNamesIterator = 0;
                while (productNamesIterator < productNames.length()) {
                    int repoIterator = 0;
                    json repoDetails = retreaveRepositoriesFromDatabase(untaint <string>productNames[
                        productNamesIterator].PRODUCT_NAME);

                    while (repoIterator < repoDetails.length()) {
                        repoNames[repoNames.length()] = repoDetails[repoIterator].REPO_NAME;
                        repoIterator = repoIterator + 1;
                    }
                    productNamesIterator = productNamesIterator + 1;
                }
            }
        }
        response.setJsonPayload(untaint repoNames);
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }

    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/products/"
    }
    resource function getAllProducts(http:Caller caller, http:Request request) {
        http:Response response = new;
        json[] productNamesArray = [];
        int productIterator = 0;

        json productNames = getAllProductNames();

        while (productIterator < productNames.length()) {
            productNamesArray[productIterator] = <string>productNames[productIterator].PRODUCT_NAME;
            productIterator = productIterator + 1;
        }

        response.setJsonPayload(untaint productNamesArray);
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }

    }
}

function triggerRetreaveIssueCount() returns json|error? {
    json productNames = getAllProductNames();

    json[] issueCountByProduct = [];
    int productIterator = 0;
    int numberOfProducts = productNames.length();
    json[] partialIssueJson = [];
    json[] allRepodetails = [];

    while (productIterator < numberOfProducts) {
        json repoDetails = retreaveRepositoriesFromDatabase(untaint <string>productNames[productIterator].PRODUCT_NAME);
        int readArrayIndex = 0;
        int repoCount = repoDetails.length();
        int repoIterator = 0;
        int count = 0;
        json[] issuesJson = [];
        int totalIssueCount = 0;
        int l1IssueCount = 0;
        int l2IssueCount = 0;
        int l3IssueCount = 0;

        while (readArrayIndex < repoDetails.length()) {
            (partialIssueJson, readArrayIndex) = spliceArray(readArrayIndex, repoDetails);
            json[] intermediantIssueCountJson = executeGetIssueCountFromGit(partialIssueJson, TRIGGER_AUTH_KEY);

            foreach var item in intermediantIssueCountJson {
                issuesJson[issuesJson.length()] = item;
            }
        }
        json issueCount = {};

        foreach var item in issuesJson {
            totalIssueCount = totalIssueCount + <int>item.totalIssueCount;
            l1IssueCount = l1IssueCount + <int>item.l1IssuesJson;
            l2IssueCount = l2IssueCount + <int>item.l2IssuesJson;
            l3IssueCount = l3IssueCount + <int>item.l3IssuesJson;
        }


        issueCount.Product = productNames[productIterator].PRODUCT_NAME;
        issueCount.TotalCount = totalIssueCount;
        issueCount.L1IssueCount = l1IssueCount;
        issueCount.L2IssueCount = l2IssueCount;
        issueCount.L3IssueCount = l3IssueCount;
        issueCountByProduct[productIterator] = issueCount;
        productIterator = productIterator + 1;
    }
    insertIntoIssueCountTable(untaint issueCountByProduct);
    return issueCountByProduct;
}

function onTriggerFunction() returns error? {
    var issueCounts = check triggerRetreaveIssueCount();
}

function spliceArray(int key, json array) returns (json[], int) {
    int i = 0;
    json[] newArray = [];
    while (i + key < array.length() && i < 5) {
        newArray[i] = array[i + key];
        i = i + 1;
    }
    return (newArray, i + key);
}

public function main() {
    function (error) onErrorFunction = cleanupError;

    timer = new task:Timer(onTriggerFunction, onErrorFunction, 3600000,
        delay = 3600000);

    timer.start();
}

function cleanupError(error e) {
    log:printError("Error occured while triggering the database  ", err = e);
}


