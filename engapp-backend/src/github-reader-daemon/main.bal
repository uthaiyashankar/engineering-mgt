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

import ballerina/log;
import ballerina/task;
import ballerina/config;
import ballerina/time;

task:AppointmentConfiguration appointmentConfiguration = {
    appointmentDetails: config:getAsString("CRON_EXPRESSION_UPDATE")
};

listener task:Listener appointment = new (appointmentConfiguration);

service appointmentService on appointment {
    resource function onTrigger() {
        processData();
    }
}

public function main() {
    processData();
}

public function processData() {
    log:printInfo("==== Starting Github Reader Daemon =====");
    fetchAndStoreAllRepositories();
    fetchAndStoreAllIssues();
    fetchAndStoreOpenPRReviews();
    log:printInfo("==== Finished processing =====");
}

//Fetch repositories from github and store in database
function fetchAndStoreAllRepositories() {
    log:printInfo("==== Fetching repositories =====");

    map<Organization> organizations = getAllOrganizationsFromDB();
    map<[int, Repository[]]> repositories = {};
    foreach Organization organization in organizations {
        log:printInfo("==== Fetching repositories for organization [" + organization.orgName + "] =====");
        Repository[] orgRepos = fetchReposOfOrgFromGithub(organization);
        repositories[organization.id.toString()] = [organization.id, orgRepos];
    }

    log:printInfo("==== Storing repositories =====");
    storeRepositoriesToDB(repositories);
    log:printInfo("==== Finished storing repositories =====");
}

//Fetch all issues from github from last update time and store in database
function fetchAndStoreAllIssues() {
    log:printInfo("==== Fetching issues =====");

    //==========================================================
    // Issue processing is bit different from repo processing, due to volume
    // We'll collect the issues per repo and store then and there, 
    // rather than collecting all issues of all repositories and then storing together
    //===========================================================

    //Get all organizations from database
    map<Organization> organizations = getAllOrganizationsFromDB();

    //Get all repositories from database 
    map<Repository> repositories;
    var retVal = getAllRepositoriesFromDB();
    if (retVal is error) {
        //We can't continue without repositories 
        log:printError("Not fetching any issues. No repositories found to fetch issues", err = retVal);
        return;
    } else {
        repositories = retVal;
    }

    //Get last max updated time of issues per repository
    map<string> lastUpdateDateOfIssuesPerRepo = getLastUpdateDateOfIssuesPerRepo();

    //Get all the issue ids. It is needed to decide whether to update or insert
    map<[int, time:Time]>|error retResult = getAllIssueIdsFromDB();
    map<[int, time:Time]> existingIssueIds;
    if (retResult is error) {
        //We can't continue. We might endup creating duplicates
        log:printError("Not storing issue details due to possible duplicate creation", err = retResult);
        return;
    } else {
        existingIssueIds = retResult;
    }

    //Loop through the repo and get the issues
    foreach Repository repository in repositories {
        log:printInfo("==== Fetching issues for repository [" + repository.repoName + "] =====");

        //Get the organization of the repo
        Organization org;
        if (!organizations.hasKey(repository.orgId.toString())){
            //We don't know the organization. Hence, we can't construct the URL
            continue;
        } else {
            org = <Organization> organizations[repository.orgId.toString()];
        } 

        //Get the last updated date. If it is not there, () is fine. We can get all issues of repo
        string? lastUdatedDate = lastUpdateDateOfIssuesPerRepo[repository.repositoryId.toString()];
        Issue[] issuesOfRepo = fetchIssuesOfRepoFromGithub(repository, org, lastUdatedDate);
        storeIssuesToDB(repository.repositoryId, issuesOfRepo, existingIssueIds);
    }

    log:printInfo("==== Finished storing issues =====");
}

function fetchAndStoreOpenPRReviews() {
    log:printInfo("==== Fetching Open PR reviews =====");
    // Get all Open PRs
    OpenPR[] openPRs = getOpenPRsFromDB();
    PRReview[] reviews = [];

    // Loop through the Open PRs and get the reviews
    foreach OpenPR openPR in openPRs {
        PRReview? prReview = fetchPRReviewFromGithub(openPR);
        if (prReview is PRReview) {
            reviews.push(prReview);
        }
    }

    // Store the reviews
    log:printInfo("==== Storing open PR reviews =====");
    storePRReviewsToDB(reviews);
    log:printInfo("==== Finished storing open PR reviews =====");
}