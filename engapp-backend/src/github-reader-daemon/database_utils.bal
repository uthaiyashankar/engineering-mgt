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
import ballerina/log;
import ballerina/time;

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
        log:printError("Not storing repository details due to possible duplicate creation", err = retVal);
        return;
    } else {
        existingRepos = retVal;
    }

    //Loop thourgh the new repos and see which should be updated and which should be inserted
    foreach [int, Repository[]] [orgId, repositoriesOfOrg] in repositories {
        foreach Repository repository in repositoriesOfOrg {
            string githubIdOfRepo = repository.githubId;
            string repoName = repository.repoName;
            string url = repository.repoURL;
            string repoType = repository.repoType;
            Repository? existingRepo = existingRepos[githubIdOfRepo];
            if (existingRepo is Repository) {
                //we already have this in the database. 
                //Remember processed repos of existing repositories. This is to update organization id of non-processed 
                //existing repositories to -1
                processedRepos[githubIdOfRepo] = existingRepo;

                if (repoName != existingRepo.repoName || url != existingRepo.repoURL || 
                    orgId != existingRepo.orgId || repoType != existingRepo.repoType) {
                    //There are some modifications to existing values
                    var ret = engappDb->update(UPDATE_REPOSITORY, repoName, url, orgId, repoType, existingRepo.repositoryId);
                    if (ret is error){
                        log:printError("Error in updating repository: RepositoryId = [" + 
                            existingRepo.repositoryId.toString() + "], RepoURL = [" + url + "]", err = ret);
                        //Ignore this update and continue
                    }
                }
            } else {
                //This is a new repository. We need to insert
                var ret = engappDb->update(INSERT_REPOSITORY, githubIdOfRepo, repoName, orgId, url, repoType);
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
            var ret = engappDb->update(UPDATE_REPOSITORY, existingRepo.repoName, existingRepo.repoURL, 
                unknownOrgId, existingRepo.repoType, existingRepo.repositoryId);
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
            lastUpdateDateOfIssuesPerRepo[item.repositoryId.toString()] = <@untainted>time:toString(item.date);
        }
    }

    return lastUpdateDateOfIssuesPerRepo;
}

function getAllIssueIdsFromDB() returns map<[int, time:Time]>|error {
    table<IssueIdsAndUpdateTime>|error dbResult = engappDb->select(GET_ALL_ISSUE_IDS, IssueIdsAndUpdateTime);

    if (dbResult is error){
        log:printError("Error occured while retrieving the issue ids from database: ", err = dbResult);
        //we can't continue, since returning empty might result in duplicates
        return <@untainted>dbResult;
    } else {
        map<[int, time:Time]> issueIds = {};
        foreach IssueIdsAndUpdateTime issue in dbResult {
            issueIds[issue.githubId] = [<int>issue.issueId, issue.updatedTime];
        }
        return <@untainted>issueIds;
    }
}

function storeIssuesToDB(int repositoryId, Issue[] issuesOfRepo, map<[int, time:Time]> existingIssueIds) {    
    //Loop through the issues from github and store them to database
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
        string issueTitle = issue.issueTitle;

        [int, time:Time]? existingIssue = existingIssueIds[githubId];
        if (existingIssue is [int, time:Time]) {
            // we already have this in the database. 
            [int, time:Time] [issueId, lastUpdatedTime] = existingIssue;

            //Check whether the last update time is same as current issue time
            if (time:toString(lastUpdatedTime) == issue.updatedDate){
                //Last updated time of the issue is same as what we have in the database
                //Hence, no need to udpate it again.  
                continue;
            }

            // We are blindly updating without checking whether the values are changed, since we have read from last updated date. 
            var  ret = engappDb->update(UPDATE_ISSUES, repositoryId, createdTime, updatedTime, closedTime, createdby,
                issueType, issueTitle, htmlUrl, labels, assignees, issueId);

            if (ret is error){
                log:printError("Error in updating issues: issueId = [" + 
                    issueId.toString() + "], issueURL = [" + htmlUrl + "]", err = ret);
                //Ignore this update and continue
            }
        } else {
            //This is a new issue. We need to insert
            var ret = engappDb->update(INSERT_ISSUES, githubId, repositoryId, createdTime, updatedTime, closedTime,
                createdby, issueType, issueTitle, htmlUrl, labels, assignees);
            if (ret is error){
                log:printError("Error in inserting issue: issueGithubId = [" + githubId + 
                    "], issueURL = [" + htmlUrl + "]", err = ret);
                //Ignore this insert and continue
            }
        }
    }
}

function getOpenPRsFromDB() returns OpenPR[] {
    table<OpenPR>|error dbResult = engappDb->select(GET_ALL_OPEN_PRS, OpenPR);
    OpenPR[] openPRs = [];
    if (dbResult is error){
        log:printError("Error occured while retrieving the open pull requests from database: ", err = dbResult);
    } else {
        foreach OpenPR pr in dbResult {
            openPRs.push(pr);
        }
    }
    return <@untainted>openPRs;
}

function getAllPRReviewsFromDB() returns map<PRReview> {
    table <PRReview>|error dbResult = engappDb->select(GET_ALL_PR_REVIEWS, PRReview);
    map<PRReview> existingPRReviews = {};
    if (dbResult is error){
        log:printError("Error occured while retrieving the pull request reviews from database: ", err = dbResult);
    } else {
        foreach PRReview prReview in dbResult {
            existingPRReviews[prReview.issueId.toString()] = prReview;
        }
    }

    return <@untainted>existingPRReviews;
}

function storePRReviewsToDB(PRReview[] reviews) {
    //Get all existing PR reviews
    map<PRReview> existingPRReviews = getAllPRReviewsFromDB();

    foreach PRReview newReview in reviews {
        PRReview? existingReview = existingPRReviews[newReview.issueId.toString()];
        if (existingReview is PRReview) {
            //We already have this record
            if (existingReview.reviewers != newReview.reviewers || 
                existingReview.reviewStates != newReview.reviewStates || 
                existingReview.lastReviewer != newReview.lastReviewer || 
                existingReview.lastState != newReview.lastState) {
                //Something got changed
                var  ret = engappDb->update(UPDATE_PR_REVIEW, newReview.reviewers, newReview.reviewStates,
                    newReview.lastReviewer, newReview.lastState, newReview.issueId);

                if (ret is error){
                    log:printError("Error in updating pr review: issueId = [" + 
                        newReview.issueId.toString() + "]", err = ret);
                    //Ignore this update and continue
                }
            }
        } else {
            //This is a new record
            var ret = engappDb->update(INSERT_PR_REVIEW, newReview.issueId, newReview.reviewers, newReview.reviewStates,
                    newReview.lastReviewer, newReview.lastState);
            if (ret is error){
                log:printError("Error in inserting pr review: issueId = [" +  
                    newReview.issueId.toString() + "]", err = ret);
                //Ignore this insert and continue
            }
        }
    }

}

function storeUsersToDB(map<[int, User[]]> users){
    //Get all existing users
    map<User>|error retVal = getAllUsersFromDB();
    map<User> existingUsers;
    if (retVal is error) {
        //We can't continue to store, since we might create duplicate here. 
        log:printError("Not storing user details due to possible duplicate creation", err = retVal);
        return;
    } else {
        existingUsers = retVal;
    }

    //Get all existing organization+users
    map<int[]>|error orgUsersRetVal = getAllOrgUsersFromDB();
    map<int[]> existingOrgUsers;
    if (orgUsersRetVal is error) {
        //We can't continue to store, since we might create duplicate here. 
        log:printError("Not storing user details due to possible duplicate creation", err = orgUsersRetVal);
        return;
    } else {
        existingOrgUsers = orgUsersRetVal;
    }

    foreach [int, User[]] [orgId, orgUsers] in users {
        int[] currentOrgUsers = [];
        var val = existingOrgUsers[orgId.toString()];
        if (val is int[]){
            currentOrgUsers = val;
        }

        foreach User user in orgUsers {
            string githubId = user.githubId;
            if (existingUsers.hasKey(githubId)){
                //user already exists.. Check whether there are anything changed. 
                User existingUser = <User>existingUsers[githubId];
                if (existingUser.loginName != user.loginName) ||
                (existingUser.name != user.name) ||
                (existingUser.company != user.company) ||
                (existingUser.email != user.email) ||
                (existingUser.profileUrl != user.profileUrl) ||
                (existingUser.websiteUrl != user.websiteUrl) {
                    //Something is different. Update the record
                    var ret = engappDb->update(UPDATE_USER, user.loginName, user.name, user.company, user.email, 
                            user.profileUrl, user.websiteUrl, existingUser.userId);
                    if (ret is error){
                        log:printError("Error in updating Users: userId = [" + 
                            existingUser.userId.toString() + "], login = [" + existingUser.loginName + "]", err = ret);
                        //Ignore this update and continue
                    }

                    //Also, remember the new values
                    user.userId = existingUser.userId;
                    existingUsers[githubId] = user;
                }

                //Check whether this user is an existing member of the organization
                int? index = currentOrgUsers.indexOf(existingUser.userId);
                if (index is int){
                    //We alreay have this member. So, don't need to do anything. 

                    //Remove from the array, so that, we can delete if any removed members
                    _ = currentOrgUsers.remove(index);
                } else {
                    //This is a new member. Need to insert
                    var ret = engappDb->update(INSERT_ORG_USER, orgId, existingUser.userId);
                    if (ret is error){
                        log:printError("Error in inserting organization user : userId = [" + 
                            existingUser.userId.toString() + "], orgId = [" + orgId.toString() + "]", err = ret);
                        //Ignore this update and continue
                    }
                }   
            } else {
                //New user. Have to insert new record
                var ret = engappDb->update(INSERT_USER, user.githubId, user.loginName, user.name, user.company, user.email, 
                            user.profileUrl, user.websiteUrl);
                if (ret is error){
                    log:printError("Error in inserting Users: user github Id = [" + 
                        user.githubId.toString() + "], login = [" + user.loginName + "]", err = ret);
                    //Ignore this update and continue
                } else {
                    //Get the last inserted Id
                    int userId = <int>ret.generatedKeys["GENERATED_KEY"];
                    //Insert the organization user
                    var retOrgUser = engappDb->update(INSERT_ORG_USER, orgId, userId);
                    if (retOrgUser is error){
                        log:printError("Error in inserting organization user : userId = [" + 
                            userId.toString() + "], orgId = [" + orgId.toString() + "]", err = retOrgUser);
                        //Ignore this update and continue
                    }

                    //Also, remember the new values so that further inserts for org will get this value
                    user.userId = userId;
                    existingUsers[githubId] = user;
                }
            }
        }

        //All users have been updated. Remaining users should be deleted
        foreach int userId in currentOrgUsers {
            var ret = engappDb->update(DELETE_ORG_USER, orgId, userId);
            if (ret is error){
                log:printError("Error in deleting organization user : userId = [" + 
                    userId.toString() + "], orgId = [" + orgId.toString() + "]", err = ret);
                //Ignore this update and continue
            }
        }
    }
}

//Get all existing User details from the database
function getAllUsersFromDB() returns map<User>|error {
    table<User>|error dbResult = engappDb->select(GET_ALL_USERS, User);

    if (dbResult is error){
        log:printError("Error occured while retrieving the users from database: ", err = dbResult);
        return <@untainted> dbResult;
    } else {
        map<User> existingUsers = {};
        foreach User user in dbResult {
            existingUsers[user.githubId] = user;
        }
        //Nothing to untaint
        return <@untainted> existingUsers;
    }    
}

//Get all existing Organization User details from the database
function getAllOrgUsersFromDB() returns map<int[]>|error {
    table<OrgUser>|error dbResult = engappDb->select(GET_ALL_ORG_USERS, OrgUser);

    if (dbResult is error){
        log:printError("Error occured while retrieving the organization users from database: ", err = dbResult);
        return <@untainted> dbResult;
    } else {
        map<int[]> existingOrgUsers = {};
        foreach OrgUser user in dbResult {
            if (!existingOrgUsers.hasKey(user.orgId.toString())){
                existingOrgUsers[user.orgId.toString()] = [];
            } 
            int[] orgUsers = <int[]> existingOrgUsers[user.orgId.toString()];
            orgUsers.push(user.userId);
        }
        //Nothing to untaint
        return <@untainted> existingOrgUsers;
    }    
}