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


import ballerina/config;
import ballerinax/java.jdbc;
import ballerina/jsonutils;
import ballerina/log;

jdbc:Client githubDb = new({
        url: config:getAsString("DB_URL"),
        username: config:getAsString("DB_USERNAME"),
        password: config:getAsString("DB_PASSWORD"),
        dbOptions: { useSSL: false }
    });

type IssueCount record {
    int count;
};
//Retrieves organization details from the database
function retrieveAllOrganizations() returns json[]? {
    var organizations = githubDb->select(RETRIEVE_ORGANIZATIONS, ());
    if (organizations is table<record {}>) {
        json organizationJson = jsonutils:fromTable(organizations);
            return <json[]>organizationJson;
    } else {
        log:printError("Error occured while retrieving the organization details: ",
        err = organizations);
    }
}

//Retrieves repository details from the database
function retrieveAllReposDetails() returns json[]? {
    var repositories = githubDb->select(RETRIEVE_REPOSITORIES, ());
    if (repositories is table<record {}>) {
        json repositoriesJson = jsonutils:fromTable(repositories);
        return <json[]>repositoriesJson;
    } else {
        log:printError("Error occured while retrieving the repository details: ", err = repositories);
    }
}

//Retrieves repository details from the database for a given Organization Id
function retrieveAllRepos(int orgId) returns json[]? {
    var repositories = githubDb->select(RETRIEVE_REPOSITORIES_BY_ORG_ID, () , orgId);
    if (repositories is table<record {}>) {
        json repositoriesJson = jsonutils:fromTable(repositories);
            return <json[]>repositoriesJson;
    } else {
        log:printError("Error occured while retrieving the repository details for a given org Id: ",
        err = repositories);
    }
}

//Get issue labels for an issue
function getIssueLabels(json[] issueLabels) returns string {
    int numOfLabels = issueLabels.length();
    string labels = "";
    int i=1;
    foreach var label in issueLabels {

        if(numOfLabels == i){
        labels = labels + label.name.toString() ;
        }
        else{
        labels = labels + label.name.toString() + ",";
        i = i+1;
        }
    }
    return labels;
}

//Get issue assignees for an issue
function getIssueAssignees(json[] issueAssignees) returns string {
    int numOfAssignees = issueAssignees.length();
    string assignees = "";
    int i=1;
    foreach var assignee in issueAssignees {
        if(numOfAssignees == i)
        {
        assignees = assignees + assignee.login.toString();
        }
        else{
        assignees = assignees + assignee.login.toString() + ",";
        i = i+1;
        }
    }
    return assignees;
}

//Updates the repository table
function storeIntoReposTable(json[] response, int orgId) {
     map<json> existingRepos = {};
         var repoJson = retrieveAllRepos(orgId);
         if (repoJson is json[]) {
             foreach json uuid in repoJson {
                 existingRepos[uuid.GITHUB_ID.toString()] = uuid;
             }
         } else {
     	    log:printError("Returned is not a json. Error occured while retrieving  the repository details: ",
     	    err = repoJson);
         }
         foreach var repository in response {
             string gitUuid = repository.id.toString();
             string repoName = repository.name.toString();
             string url = repository.html_url.toString();
             int teamId = 100;
             if (existingRepos.hasKey(repository.id.toString())) {
                  if (repoName != existingRepos[gitUuid].REPOSITORY_NAME || url != existingRepos[gitUuid].URL) {
                     var ret = githubDb->update(UPDATE_REPOSITORIES, repoName, url, gitUuid);
                     handleUpdate(ret, "Updated the repository details with variable parameters");
                 }
             } else {
                 var ret = githubDb->update(INSERT_REPOSITORIES,
                 gitUuid, repoName, orgId, url, teamId);
                 handleUpdate(ret, "Inserted repository details with variable parameters");
             }
     	}
     }


//Update to the repo table
function storeIntoIssueTable(json[] response, int repositoryId) {
    int repoIterator = 0;
    string types;
    foreach var repository in response {
        jdbc:Parameter createdTime = { sqlType: jdbc:TYPE_DATETIME, value: repository.created_at.toString()};
        jdbc:Parameter updatedTime = { sqlType: jdbc:TYPE_DATETIME, value: repository.updated_at.toString()};
        jdbc:Parameter closedTime = { sqlType: jdbc:TYPE_DATETIME, value: repository.closed_at.toString()};
        string htmlUrl = repository.html_url.toString();
        string githubId = repository.id.toString();
        var issueLabels = repository.labels;
        string labels = "";
        if (issueLabels is json)
        {
            labels = getIssueLabels(<json[]>issueLabels);
        }
        var issueAssignee = response[repoIterator].assignees;
        string assignees = "";
        if (issueAssignee is json)
        {
            assignees = getIssueAssignees(<json[]>issueAssignee);
        }
        int? index = htmlUrl.indexOf("pull");
        types = (index is int) ? "PR" : "ISSUE";
        string createdby = repository.user.login.toString();
        if(isIssueExist(githubId)) {
           var  ret = githubDb->update(UPDATE_ISSUES, repositoryId, createdTime, updatedTime, closedTime, createdby,
            types,htmlUrl, labels, assignees, githubId);
           handleUpdate(ret, "Updated the issue details with variable parameters");
        } else {
            var ret = githubDb->update(INSERT_ISSUES, githubId, repositoryId, createdTime, updatedTime, closedTime,
            createdby, types, htmlUrl, labels, assignees);
            handleUpdate(ret, "Inserted the issue details with variable parameters");
        }
    }
}

//Update the Org Id as -1 if that repository is no more in that organization
function updateOrgId (json[] repoJson, int orgId) {
    int id =-1;
    var repoJsons =retrieveAllRepos(orgId);
    if(repoJsons is json[]) {
        foreach var uuid in repoJsons {
            boolean exists = false;
            foreach json repositoryset in repoJson {
                json[] reposet = <json[]> repositoryset;
                foreach var repository in reposet {
                    if(uuid.GITHUB_ID.toString() == repository.id.toString()) {
                        exists = true;
                        break;
                    }
                }
            }
            if(!exists) {
                var ret = githubDb->update(UPDATE_ORGID, id, uuid.GITHUB_ID.toString());
                handleUpdate(ret, "Updated the org id for the repository with variable parameters");
            }
        }
    } else {
        log:printError("Error occured while updating the organization id to the repository", err = repoJsons);
    }
}

//Checks whether given issue is exists or not
function isIssueExist (string issue_id) returns boolean {
    var issue = githubDb->select(ISSUE_EXISTS,(),issue_id);
    if (issue is table<record {}>) {
        json issueJson = jsonutils:fromTable(issue);
        if(issueJson.toString() != ""){
            return true;
        }
    } else {
        log:printError("Error occured while checking the existence of an issue", err = issue);
    }
    return false;
}

function handleUpdate(jdbc:UpdateResult|jdbc:Error status, string message) {
    if (status is jdbc:UpdateResult) {
           log:printInfo(message);
    }
    else {
        log:printError("Failed to update the tables: " , status);
    }
}

function InsertIssueCountDetails() {
    var openIssueCount = githubDb->select(RETRIEVE_OPEN_ISSUE_COUNT, IssueCount);
    var closedIssueCount = githubDb->select(RETRIEVE_CLOSED_ISSUE_COUNT, IssueCount);
    int openIssue = 0;
    int closedIssue = 0;
    if (openIssueCount is table<IssueCount>) {
        foreach ( IssueCount issueCount in openIssueCount) {
            openIssue = <int>issueCount.count;
        }
    } else {
        log:printError("Error occured while insering the open issues count details for each day to the Database",
        err = openIssueCount);
    }
    if (closedIssueCount is table<IssueCount>) {
        foreach ( IssueCount issueCount in closedIssueCount) {
            closedIssue = <int>issueCount.count;
        }
    } else {
        log:printError("Error occured while insering the closed issues count details for each day to the Database",
        err = closedIssueCount);
    }
    var ret = githubDb->update(INSERT_ISSUE_COUNT, openIssue, closedIssue);
    handleUpdate(ret, "Inserted Issue count details with variable parameters");
}