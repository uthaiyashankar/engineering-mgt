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

function executeReceiveIssuesFromGit(json[] repoDetails, string labels, string authKey) returns json[] {

    json[] responseJson = [];
    worker w1 {
        if (repoDetails.length() > 0) {
            json issuesJson = {};
            json allIssues = getAllIssues(untaint repoDetails[0], untaint labels, authKey);
            if (allIssues != null) {
                issuesJson.repositoryName = repoDetails[0].REPO_NAME;
                issuesJson.issues = allIssues;
                responseJson[responseJson.length()] = issuesJson;
            }
        }
    }

    worker w2 {
        if (repoDetails.length() > 1) {
            json allIssues = getAllIssues(untaint repoDetails[1], untaint labels, authKey);
            if (allIssues != null) {
                json issuesJson = {};
                issuesJson.repositoryName = repoDetails[1].REPO_NAME;
                issuesJson.issues = allIssues;
                responseJson[responseJson.length()] = issuesJson;
            }
        }
    }

    worker w3 {
        if (repoDetails.length() > 2) {
            json allIssues = getAllIssues(untaint repoDetails[2], untaint labels, authKey);
            if (allIssues != null) {
                json issuesJson = {};
                issuesJson.repositoryName = repoDetails[2].REPO_NAME;
                issuesJson.issues = allIssues;
                responseJson[responseJson.length()] = issuesJson;
            }
        }
    }

    worker w4 {
        if (repoDetails.length() > 3) {
            json allIssues = getAllIssues(untaint repoDetails[3], untaint labels, authKey);
            if (allIssues != null) {
                json issuesJson = {};
                issuesJson.repositoryName = repoDetails[3].REPO_NAME;
                issuesJson.issues = allIssues;
                responseJson[responseJson.length()] = issuesJson;
            }
        }
    }

    worker w5 {
        if (repoDetails.length() > 4) {
            json allIssues = getAllIssues(untaint repoDetails[4], untaint labels, authKey);
            if (allIssues != null) {
                json issuesJson = {};
                issuesJson.repositoryName = repoDetails[4].REPO_NAME;
                issuesJson.issues = allIssues;
                responseJson[responseJson.length()] = issuesJson;
            }
        }
    }

    _ = wait { w1, w2, w3, w4, w5 };
    return responseJson;
}

function executeGetIssueCountFromGit(json[] repoDetails, string authKey) returns json[] {
    string L1Issues = "Severity/Blocker";
    string L2Issues = "Severity/Critical";
    string L3Issues = "Severity/Major";
    json[] responseJson = [];
    worker w1 {
        if (repoDetails.length() > 0) {
            json issueCountJson = {};
            int gitIssueCount = getIssueCountFromGit(untaint repoDetails[0], authKey);
            if (gitIssueCount != -1) {
                int issueTotalIssueCount = gitIssueCount;
                issueCountJson.repositoryName = repoDetails[0].REPO_NAME;
                issueCountJson.totalIssueCount = issueTotalIssueCount;
                json L1IssuesJson = getAllIssues(untaint repoDetails[0], L1Issues, authKey);
                issueCountJson.l1IssuesJson = L1IssuesJson.length();
                json L2IssuesJson = getAllIssues(untaint repoDetails[0], L2Issues, authKey);
                issueCountJson.l2IssuesJson = L2IssuesJson.length();
                json L3IssuesJson = getAllIssues(untaint repoDetails[0], L3Issues, authKey);
                issueCountJson.l3IssuesJson = L3IssuesJson.length();
                responseJson[responseJson.length()] = issueCountJson;
            }
        }
    }

    worker w2 {
        if (repoDetails.length() > 1) {
            json issueCountJson = {};
            int gitIssueCount = getIssueCountFromGit(untaint repoDetails[1], authKey);
            if (gitIssueCount != -1) {
                int issueTotalIssueCount = gitIssueCount;
                issueCountJson.repositoryName = repoDetails[1].REPO_NAME;
                issueCountJson.totalIssueCount = issueTotalIssueCount;
                json L1IssuesJson = getAllIssues(untaint repoDetails[1], L1Issues, authKey);
                issueCountJson.l1IssuesJson = L1IssuesJson.length();
                json L2IssuesJson = getAllIssues(untaint repoDetails[1], L2Issues, authKey);
                issueCountJson.l2IssuesJson = L2IssuesJson.length();
                json L3IssuesJson = getAllIssues(untaint repoDetails[1], L3Issues, authKey);
                issueCountJson.l3IssuesJson = L3IssuesJson.length();
                responseJson[responseJson.length()] = issueCountJson;
            }
        }
    }

    worker w3 {
        if (repoDetails.length() > 2) {
            int gitIssueCount = getIssueCountFromGit(untaint repoDetails[2], authKey);
            if (gitIssueCount != -1) {
                json issueCountJson = {};
                int issueTotalIssueCount = gitIssueCount;
                issueCountJson.repositoryName = repoDetails[2].REPO_NAME;
                issueCountJson.totalIssueCount = issueTotalIssueCount;
                json L1IssuesJson = getAllIssues(untaint repoDetails[2], L1Issues, authKey);
                issueCountJson.l1IssuesJson = L1IssuesJson.length();
                json L2IssuesJson = getAllIssues(untaint repoDetails[2], L2Issues, authKey);
                issueCountJson.l2IssuesJson = L2IssuesJson.length();
                json L3IssuesJson = getAllIssues(untaint repoDetails[2], L3Issues, authKey);
                issueCountJson.l3IssuesJson = L3IssuesJson.length();
                responseJson[responseJson.length()] = issueCountJson;
            }
        }
    }

    worker w4 {
        if (repoDetails.length() > 3) {
            int gitIssueCount = getIssueCountFromGit(untaint repoDetails[3], authKey);
            if (gitIssueCount != -1) {
                json issueCountJson = {};
                int issueTotalIssueCount = gitIssueCount;
                issueCountJson.repositoryName = repoDetails[3].REPO_NAME;
                issueCountJson.totalIssueCount = issueTotalIssueCount;
                json L1IssuesJson = getAllIssues(untaint repoDetails[3], L1Issues, authKey);
                issueCountJson.l1IssuesJson = L1IssuesJson.length();
                json L2IssuesJson = getAllIssues(untaint repoDetails[3], L2Issues, authKey);
                issueCountJson.l2IssuesJson = L2IssuesJson.length();
                json L3IssuesJson = getAllIssues(untaint repoDetails[3], L3Issues, authKey);
                issueCountJson.l3IssuesJson = L3IssuesJson.length();
                responseJson[responseJson.length()] = issueCountJson;
            }
        }
    }

    worker w5 {
        if (repoDetails.length() > 4) {
            int gitIssueCount = getIssueCountFromGit(untaint repoDetails[4], authKey);
            if (gitIssueCount != -1) {
                json issueCountJson = {};
                int issueTotalIssueCount = gitIssueCount;
                issueCountJson.repositoryName = repoDetails[4].REPO_NAME;
                issueCountJson.totalIssueCount = issueTotalIssueCount;
                json L1IssuesJson = getAllIssues(untaint repoDetails[4], L1Issues, authKey);
                issueCountJson.l1IssuesJson = L1IssuesJson.length();
                json L2IssuesJson = getAllIssues(untaint repoDetails[4], L2Issues, authKey);
                issueCountJson.l2IssuesJson = L2IssuesJson.length();
                json L3IssuesJson = getAllIssues(untaint repoDetails[4], L3Issues, authKey);
                issueCountJson.l3IssuesJson = L3IssuesJson.length();
                responseJson[responseJson.length()] = issueCountJson;
            }
        }
    }
    _ = wait { w1, w2, w3, w4, w5 };
    return responseJson;
}