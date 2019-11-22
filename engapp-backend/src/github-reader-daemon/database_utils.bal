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
// import ballerina/jsonutils;
import ballerina/log;

jdbc:Client engappDb = new({
        url: config:getAsString("DB_URL"),
        username: config:getAsString("DB_USERNAME"),
        password: config:getAsString("DB_PASSWORD"),
        dbOptions: { useSSL: false }
    });

int unknownOrgId = -1;


//Retrieves organization details from the database
function getAllOrganizationsFromDB() returns Organization[] {
    Organization[] existingOrgs = [];
    var organizations = engappDb->select(RETRIEVE_ORGANIZATIONS, Organization);
    if (organizations is table<Organization>) {
        foreach Organization org in organizations {
            if (org.id != unknownOrgId){
                existingOrgs.push(org);
            }
        }
    } else {
        log:printError("Error occured while retrieving the organization details from database: ", err = organizations);
    }

    return existingOrgs;
}

// //Retrieves repository details from the database
// function retrieveAllReposDetails() returns json[]? {
//     var repositories = engappDb->select(RETRIEVE_REPOSITORIES, ());
//     if (repositories is table<record {}>) {
//         json repositoriesJson = jsonutils:fromTable(repositories);
//         return <json[]>repositoriesJson;
//     } else {
//         log:printError("Error occured while retrieving the repository details: ", err = repositories);
//     }
// }

//Get all existing repository details from the database
function getAllRepositoriesFromDB() returns map<Repository>? {
    table<Repository> repositories;
    table<Repository>|error dbResult = engappDb->select(RETRIEVE_ALL_REPOSITORIES, Repository);

    if (dbResult is error){
        log:printError("Error occured while retrieving the repositories from database: ", err = dbResult);
        return;
    } else {
        repositories = dbResult;
    }

    map<Repository> existingRepos = {};
    foreach Repository repository in repositories {
        existingRepos[repository.githubId] = repository;
    }

    //Nothing to untaint
    return <@untainted> existingRepos;
}


//Store repositories into the database
function storeRepositories(map<[int, json[]]> repositories) {
    map<Repository>? retVal = getAllRepositoriesFromDB();
    map<Repository> existingRepos;
    map<Repository> processedRepos = {};
    if (retVal is ()) {
        //We can't continue to store, since we might create duplicate here. 
        log:printError("Not storing repository details due to possible duplicate creation");
        return;
    } else {
        existingRepos = retVal;
    }

    //Loop thourgh the new repos and see which should be updated and which should be inserted
    int defaultTeamId = -1;
    foreach [int, json[]] [orgId, repoSet] in repositories {
        foreach json repoArrays in repoSet {
            foreach json repository in <json[]>repoArrays {
                string githubIdOfRepo = repository.id.toString();
                string repoName = repository.name.toString();
                string url = repository.html_url.toString();
                Repository? existingRepo = existingRepos[githubIdOfRepo];
                if (existingRepo is Repository) {
                    // we already have this in the database. 
                    //Remember processed repos of existing repositories. This is to update organization id of non-processed 
                    // existing repositories to -1
                    processedRepos[githubIdOfRepo] = existingRepo;

                    if (repoName != existingRepo.repositoryName || url != existingRepo.repoURL || orgId != existingRepo.orgId) {
                        //There are some modifications to existing values
                        var ret = engappDb->update(UPDATE_REPOSITORY, repoName, url, orgId, existingRepo.repositoryId);
                        if (ret is error){
                            log:printError("Error in updating repository: RepositoryId = [" + 
                                existingRepo.repositoryId.toString() + "], RepoURL = [" + url + "]", err = ret);
                            //Ignore this update and continue
                        }
                    }
                } else {
                    //This is a new repository. We need to insert
                    var ret = engappDb->update(INSERT_REPOSITORY, githubIdOfRepo, repoName, orgId, url, defaultTeamId);
                    if (ret is error){
                        log:printError("Error in inserting repository: RepositoryGithubId = [" + githubIdOfRepo + 
                            "], RepoURL = [" + url + "]", err = ret);
                        //Ignore this insert and continue
                    }
                }
            }
        }
    }

    //Now go through existing repositories and updte the organizationId to -1 if it is not processed
    foreach Repository existingRepo in existingRepos {
        if (!processedRepos.hasKey(existingRepo.githubId)){
            //This repo is not processed. Hence should be deleted or moved to some other organization. 
            //Hence, update the orgId to -1
            var ret = engappDb->update(UPDATE_REPOSITORY, existingRepo.repositoryName, existingRepo.repoURL, 
                unknownOrgId, existingRepo.repositoryId);
            if (ret is error){
                log:printError("Error in updating repository: RepositoryId = [" + 
                    existingRepo.repositoryId.toString() + "], RepoURL = [" + existingRepo.repoURL + "]", err = ret);
                //Ignore this update and continue
            }            
        }
    }
}


// //Get issue labels for an issue
// function getIssueLabels(json[] issueLabels) returns string {
//     int numOfLabels = issueLabels.length();
//     string labels = "";
//     int i=1;
//     foreach var label in issueLabels {

//         if(numOfLabels == i){
//         labels = labels + label.name.toString() ;
//         }
//         else{
//         labels = labels + label.name.toString() + ",";
//         i = i+1;
//         }
//     }
//     return labels;
// }

// //Get issue assignees for an issue
// function getIssueAssignees(json[] issueAssignees) returns string {
//     int numOfAssignees = issueAssignees.length();
//     string assignees = "";
//     int i=1;
//     foreach var assignee in issueAssignees {
//         if(numOfAssignees == i)
//         {
//         assignees = assignees + assignee.login.toString();
//         }
//         else{
//         assignees = assignees + assignee.login.toString() + ",";
//         i = i+1;
//         }
//     }
//     return assignees;
// }




// //Update to the repo table
// function storeIntoIssueTable(json[] response, int repositoryId) {
//     int repoIterator = 0;
//     string types;
//     foreach var repository in response {
//         jdbc:Parameter createdTime = { sqlType: jdbc:TYPE_DATETIME, value: repository.created_at.toString()};
//         jdbc:Parameter updatedTime = { sqlType: jdbc:TYPE_DATETIME, value: repository.updated_at.toString()};
//         jdbc:Parameter closedTime = { sqlType: jdbc:TYPE_DATETIME, value: repository.closed_at.toString()};
//         string htmlUrl = repository.html_url.toString();
//         string githubId = repository.id.toString();
//         var issueLabels = repository.labels;
//         string labels = "";
//         if (issueLabels is json)
//         {
//             labels = getIssueLabels(<json[]>issueLabels);
//         }
//         var issueAssignee = response[repoIterator].assignees;
//         string assignees = "";
//         if (issueAssignee is json)
//         {
//             assignees = getIssueAssignees(<json[]>issueAssignee);
//         }
//         int? index = htmlUrl.indexOf("pull");
//         types = (index is int) ? "PR" : "ISSUE";
//         string createdby = repository.user.login.toString();
//         if(isIssueExist(githubId)) {
//            var  ret = engappDb->update(UPDATE_ISSUES, repositoryId, createdTime, updatedTime, closedTime, createdby,
//             types,htmlUrl, labels, assignees, githubId);
//            handleUpdate(ret, "Updated the issue details with variable parameters");
//         } else {
//             var ret = engappDb->update(INSERT_ISSUES, githubId, repositoryId, createdTime, updatedTime, closedTime,
//             createdby, types, htmlUrl, labels, assignees);
//             handleUpdate(ret, "Inserted the issue details with variable parameters");
//         }
//     }
// }



// //Checks whether given issue is exists or not
// function isIssueExist (string issue_id) returns boolean {
//     var issue = engappDb->select(ISSUE_EXISTS,(),issue_id);
//     if (issue is table<record {}>) {
//         json issueJson = jsonutils:fromTable(issue);
//         if(issueJson.toString() != ""){
//             return true;
//         }
//     } else {
//         log:printError("Error occured while checking the existence of an issue", err = issue);
//     }
//     return false;
// }

// function handleUpdate(jdbc:UpdateResult|jdbc:Error status, string message) {
//     if (status is jdbc:UpdateResult) {
//            log:printInfo(message);
//     }
//     else {
//         log:printError("Failed to update the tables: " , status);
//     }
// }

// function InsertIssueCountDetails() {
//     var openIssueCount = engappDb->select(RETRIEVE_OPEN_ISSUE_COUNT, IssueCount);
//     var closedIssueCount = engappDb->select(RETRIEVE_CLOSED_ISSUE_COUNT, IssueCount);
//     int openIssue = 0;
//     int closedIssue = 0;
//     if (openIssueCount is table<IssueCount>) {
//         foreach ( IssueCount issueCount in openIssueCount) {
//             openIssue = <int>issueCount.count;
//         }
//     } else {
//         log:printError("Error occured while insering the open issues count details for each day to the Database",
//         err = openIssueCount);
//     }
//     if (closedIssueCount is table<IssueCount>) {
//         foreach ( IssueCount issueCount in closedIssueCount) {
//             closedIssue = <int>issueCount.count;
//         }
//     } else {
//         log:printError("Error occured while insering the closed issues count details for each day to the Database",
//         err = closedIssueCount);
//     }
//     var ret = engappDb->update(INSERT_ISSUE_COUNT, openIssue, closedIssue);
//     handleUpdate(ret, "Inserted Issue count details with variable parameters");
// }