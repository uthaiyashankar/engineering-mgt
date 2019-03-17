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

import ballerina/http;
import ballerina/log;
import ballerina/io;

http:Client clientEP = new("https://api.github.com/repos/");
string issues = "issues";

function getAllIssues(json repoDetails, string labels, string authKey) returns (json) {
    http:Request req = new;
    req.addHeader("Authorization", "token " + authKey);
    string reqURL = "";
    if (labels != "") {
        reqURL = "/" + <string>repoDetails.ORG_NAME + "/" + <string>repoDetails.REPO_NAME + "/" +
                    issues + "?labels=" + labels + "&";
    } else {
        reqURL = "/" + <string>repoDetails.ORG_NAME + "/" + <string>repoDetails.REPO_NAME + "/" +
                    issues + "?";
    }
    json[]|error issueDetailsJson = getissuesFromGit(reqURL, req);

    json[] issuesJson = [];
    int gitIssueIterator = 0;
    int i = 0;
    if (issueDetailsJson is json[]) {
        int numberOfissues = issueDetailsJson.length();
        while (gitIssueIterator < numberOfissues) {
            if (issueDetailsJson[gitIssueIterator].pull_request != null) {
                gitIssueIterator = gitIssueIterator + 1;
            } else if (issueDetailsJson[gitIssueIterator].title == null || issueDetailsJson[gitIssueIterator].title.
                length() == 0){
                gitIssueIterator = gitIssueIterator + 1;
            } else {
                issuesJson[i] = {};
                issuesJson[i].repositoryName = repoDetails.REPO_NAME;
                issuesJson[i].issueTitle = issueDetailsJson[gitIssueIterator].title;
                issuesJson[i].issueLabels = getIssueLabels(issueDetailsJson[gitIssueIterator].labels);
                issuesJson[i].url = issueDetailsJson[gitIssueIterator].html_url;
                gitIssueIterator = gitIssueIterator + 1;
                i = i + 1;
            }
        }
        return issuesJson;
    } else {
        log:printError("Error while converting responce payload to json for the repository "
                + <string>repoDetails.REPO_NAME, err = issueDetailsJson);
    }
}


function getIssueCountFromGit(json repoDetails, string authKey) returns int {
    http:Request req = new;
    req.addHeader("Authorization", "token " + authKey);
    int count = 0;

    string reqURL = "/" + <string>repoDetails.ORG_NAME + "/" + <string>repoDetails.REPO_NAME;
    var response = clientEP->get(reqURL, message = req);


    if (response is http:Response) {
        var repoData = response.getJsonPayload();
        if (repoData is json) {
            if (repoData.length() > 0) {
                var issueCount = repoData.open_issues_count;

                if (issueCount is int) {
                    count = issueCount;
                } else {
                    log:printError("Error occured while retreaving issue count for repository " + <string>repoDetails.
                            REPO_NAME);
                    return -1;
                }
            }
        } else {
            log:printError("Error occured while converting data to json " + <string>repoDetails.REPO_NAME, err
                = repoData);
        }
    } else {
        log:printError("Error occured while retreaving issue count for repository " + <string>repoDetails.REPO_NAME);
    }
    return count;
}

function getIssueLabelsFromGit(json repoDetails, string authKey) returns json[] {
    http:Request req = new;
    req.addHeader("Authorization", "token " + authKey);
    int count = 0;
    string reqURL = "/" + <string>repoDetails.ORG_NAME + "/" + <string>repoDetails.REPO_NAME +
                "labels?page=0&per_page=100";
    var response = clientEP->get(reqURL, message = req);
    json[] labels = [];


    if (response is http:Response) {
        var issueLabelDetails = response.getJsonPayload();
        if (issueLabelDetails is json) {
            var labelIterator = 0;

            while (labelIterator < issueLabelDetails.length()) {
                labels[labelIterator] = issueLabelDetails[labelIterator].name;
            }
        } else {
            log:printError("Error occured while converting data to json after recieving labels from git
            " + <string>repoDetails.REPO_NAME, err = issueLabelDetails);
        }
    } else {
        log:printError("Error occured while retreaving labels from github for repository " +
                <string>repoDetails.REPO_NAME);
    }
    return labels;
}

function getIssueLabels(json issueLabels) returns (json) {
    int i = 0;
    int numOfLabels = issueLabels.length();
    json labels = [];

    while (i < numOfLabels) {
        labels[i] = issueLabels[i].name;
        i = i + 1;
    }
    return labels;
}

function getissuesFromGit(string path, http:Request req) returns json[]|error {
    int page = 1;
    json[] finalIssueArray = [];
    json issuesArray;
    var response = clientEP->get(path + "page=" + page + "&per_page=100", message = req);

    if (response is http:Response) {

        issuesArray = check response.getJsonPayload();
        if issuesArray.length() > 0 {
            finalIssueArray = check json[].convert(issuesArray);
            page = page + 1;
        } else {
            return finalIssueArray;
        }
        if (response.hasHeader("Link")) {
            while (issuesArray.length() > 0) {
                http:Response response2 = check clientEP->get(path + "page=" + page + "&per_page=100", message = req);
                issuesArray = check response2.getJsonPayload();
                if (issuesArray.length() > 0) {
                    var z = check json[].convert(issuesArray);
                    foreach var issue in z {
                        finalIssueArray[finalIssueArray.length()] = issue;
                    }
                    page = page + 1;
                } else {
                    return finalIssueArray;
                }

            }
            return finalIssueArray;
        }
    } else {
        log:printError("Error occured while retrieving data from GitHub api", err = response);
    }
    return finalIssueArray;
}

