// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

jdbc:Client engappDb = new({
        url: config:getAsString("DB_URL"),
        username: config:getAsString("DB_USERNAME"),
        password: config:getAsString("DB_PASSWORD"),
        dbOptions: { useSSL: false }
    });

int unknownOrgId = -1;


//Retrieves organization details from the database
function getAllOrganizationsFromDB() returns map<Organization> {
    map<Organization> existingOrgs = {};
    var organizations = engappDb->select(GET_ALL_ORGANIZATIONS, Organization);
    if (organizations is table<Organization>) {
        foreach Organization org in organizations {
            if (org.id != unknownOrgId){
                //Nothing to untaint at this stage
                existingOrgs[org.id.toString()] = <@untainted> org;
            }
        }
    } else {
        log:printError("Error occured while retrieving the organization details from database: ", err = organizations);
    }

    return existingOrgs;
}

//Get all existing repository details from the database
function getAllRepositoriesFromDB() returns map<Repository>|error {
    table<Repository>|error dbResult = engappDb->select(GET_ALL_REPOSITORIES, Repository);

    if (dbResult is error){
        log:printError("Error occured while retrieving the repositories from database: ", err = dbResult);
        return <@untainted> dbResult;
    } else {
        map<Repository> existingRepos = {};
        foreach Repository repository in dbResult {
            existingRepos[repository.githubId] = repository;
        }
        //Nothing to untaint
        return <@untainted> existingRepos;
    }    
}


//Store repositories into the database
function storeRepositoriesToDB(map<[int, Repository[]]> repositories) {
    map<Repository>|error retVal = getAllRepositoriesFromDB();
    map<Repository> existingRepos;
    map<Repository> processedRepos = {};
    if (retVal is error) {
        //We can't continue to store, since we might create duplicate here. 
        log:printError("Not storing repository details due to possible duplicate creation");
        return;
    } else {
        existingRepos = retVal;
    }

    //Loop thourgh the new repos and see which should be updated and which should be inserted
    foreach [int, Repository[]] [orgId, repositoriesOfOrg] in repositories {
        foreach Repository repository in repositoriesOfOrg {
            string githubIdOfRepo = repository.githubId;
            string repoName = repository.repositoryName;
            string url = repository.repoURL;
            Repository? existingRepo = existingRepos[githubIdOfRepo];
            if (existingRepo is Repository) {
                //we already have this in the database. 
                //Remember processed repos of existing repositories. This is to update organization id of non-processed 
                //existing repositories to -1
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
                var ret = engappDb->update(INSERT_REPOSITORY, githubIdOfRepo, repoName, orgId, url);
                if (ret is error){
                    log:printError("Error in inserting repository: RepositoryGithubId = [" + githubIdOfRepo + 
                        "], RepoURL = [" + url + "]", err = ret);
                    //Ignore this insert and continue
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

function getLastUpdateDateOfIssuesPerRepo() returns map<string> {
    table<LastIssueUpdatedDate>|error dbResult = engappDb->select(GET_LAST_ISSUE_UPDATED_DATE, LastIssueUpdatedDate);
    map<string> lastUpdateDateOfIssuesPerRepo = {};
    if (dbResult is error){
        log:printError("Error occured while retrieving the last updated issue date from database: ", err = dbResult);
        //It is ok to return empty map. Worst case, we will read all issues and update. 
        //Functionality will not fail by returning empty result
    } else {
        foreach LastIssueUpdatedDate item in dbResult {
            if (item.date != ""){
                lastUpdateDateOfIssuesPerRepo[item.repositoryId.toString()] = <@untainted>item.date;
            }
        }
    }

    return lastUpdateDateOfIssuesPerRepo;
}

function getAllIssueIdsFromDB() returns map<int>|error {
    table<record {}>|error dbResult = engappDb->select(GET_ALL_ISSUE_IDS, ());

    if (dbResult is error){
        log:printError("Error occured while retrieving the issue ids from database: ", err = dbResult);
        //we can't continue, since returning empty might result in duplicates
        return <@untainted>dbResult;
    } else {
        map<int> issueIds = {};
        json[] issueJsons = <json[]>jsonutils:fromTable(dbResult);
        foreach json issue in issueJsons {
            issueIds[issue.GITHUB_ID.toString()] = <int>issue.ISSUE_ID;
        }
        return <@untainted>issueIds;
    }
}

function storeIssuesToDB(map<[int, Issue[]]> issues) {
    //Get all the issue ids. It is needed to decide whether to update or insert
    map<int>|error retVal = getAllIssueIdsFromDB();
    map<int> existingIssueIds;
    if (retVal is error) {
        //We can't continue. We might endup creating duplicates
        log:printError("Not storing issue details due to possible duplicate creation");
        return;
    } else {
        existingIssueIds = retVal;
    }

    //Loop through the issues from github and store them to database
    foreach [int, Issue[]] [repositoryId, issuesOfRepo] in issues {
        foreach Issue issue in issuesOfRepo {
            jdbc:Parameter createdTime = { sqlType: jdbc:TYPE_DATETIME, value: issue.createdDate};
            jdbc:Parameter updatedTime = { sqlType: jdbc:TYPE_DATETIME, value: issue.updatedDate};
            jdbc:Parameter closedTime = { sqlType: jdbc:TYPE_DATETIME, value: issue.closedDate};
            string htmlUrl = issue.issueURL;
            string githubId = issue.githubId;
            string createdby = issue.createdBy;
            string labels = issue.labels;
            string assignees = issue.assignees;
            string issueType = issue.issueType;

            int? issueId = existingIssueIds[githubId];
            if (issueId is int) {
                // we already have this in the database. 
                // We are blindly updating without checking whether the values are changed, since we have read from last updated date. 
                var  ret = engappDb->update(UPDATE_ISSUES, repositoryId, createdTime, updatedTime, closedTime, createdby,
                    issueType, htmlUrl, labels, assignees, issueId);
   
                if (ret is error){
                    log:printError("Error in updating issues: issueId = [" + 
                        issueId.toString() + "], issueURL = [" + htmlUrl + "]", err = ret);
                    //Ignore this update and continue
                }
            } else {
                //This is a new issue. We need to insert
                var ret = engappDb->update(INSERT_ISSUES, githubId, repositoryId, createdTime, updatedTime, closedTime,
                    createdby, issueType, htmlUrl, labels, assignees);
                if (ret is error){
                    log:printError("Error in inserting issue: issueGithubId = [" + githubId + 
                        "], issueURL = [" + htmlUrl + "]", err = ret);
                    log:printError ("Assignees [" + assignees + "]");
                    //Ignore this insert and continue
                }
            }
        }
    }
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
    
//                         
//                         string lastUpdated = "";
//                         if (lastupdatedDate is table<LastUpdatedDate>) {
//                             if (lastupdatedDate.toString() != "") {
//                                 foreach ( LastUpdatedDate updatedDate in lastupdatedDate) {
//                                     io:println(updatedDate.toString());
//                                     lastUpdated = updatedDate.date;
//                                 }
//                             } else {
//                                 lastupdatedDate.close();
//                                 time:Time time = time:currentTime();
//                                 time = time:subtractDuration(time, 0, 0, 1, 0, 0, 0, 0);
//                                 lastUpdated = time:toString(time);
//                                 io:println("hello outside");
//                                 io:println(lastUpdated);
//                             }
//                         } 








// //Checks whether given issue is exists or not
// function isIssueExist (string issue_id) returns boolean {
//     var issue = engappDb->select(ISSUE_EXISTS, (), issue_id);
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