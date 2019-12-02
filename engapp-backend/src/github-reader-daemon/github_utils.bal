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

import ballerina/http;
import ballerina/log;
import ballerina/config;

http:Client gitClientEP = new ("https://api.github.com",
    config = {
        followRedirects: {
            enabled: true,
            maxCount: 5
        }
    }
);

const ITEM_PER_PAGE = 100;

function fetchReposOfOrgFromGithub (Organization organization) returns Repository[]{
    string reqURL = "/orgs/" + organization.orgName + "/repos?&per_page=" + ITEM_PER_PAGE.toString();
    boolean continueOnError = false; //We can still load repositories later
    json[] repositoriesJson = getResponseFromGithub(reqURL, "getting repositories", continueOnError);
    Repository[] repositories = [];
    foreach json repoJson in repositoriesJson {
        map<json> valueMap = <map<json>>repoJson;
        boolean isPrivate = <boolean>valueMap["private"];
        Repository repo = {
            githubId: repoJson.id.toString(), 
            repoName: repoJson.name.toString(), 
            orgId: organization.id,
            repoURL: repoJson.html_url.toString(), 
            repositoryId: -1, 
            repoType: isPrivate ? REPO_TYPE_PRIVATE : REPO_TYPE_PUBLIC
        };
        repositories.push(repo);
    }

    return repositories;
}

function fetchIssuesOfRepoFromGithub (Repository repository, Organization organization, string? lastUdatedDate) returns Issue[] {
    string reqURL = "/repos/" + organization.orgName + "/" + repository.repoName.toString() +
            "/issues?state=all&per_page=" + ITEM_PER_PAGE.toString();
    if (lastUdatedDate is string) {
        //There is a valid last update time. Hence, we can read only the issues updated after that time
        reqURL = reqURL + "&since=" + lastUdatedDate;
    }
    boolean continueOnError = false; //If error happens, we shouldn't load other pages. It will catchup later
    json[] issuesJson = getResponseFromGithub(reqURL, "getting issues", continueOnError);
    Issue[] issues = [];

    foreach json issueJson in issuesJson {        
        var issueLabels = issueJson.labels;
        string labels = "";
        if (issueLabels is json)
        {
            labels = getIssueLabels(<json[]>issueLabels);
        }
        
        var issueAssignees = issueJson.assignees;
        string assignees = "";
        if (issueAssignees is json)
        {
            assignees = getIssueAssignees(<json[]>issueAssignees);
        }
        
        //Check whether the type is issue or PR, based on the URL
        int? index = issueJson.html_url.toString().indexOf("/pull/");
        string issueType = (index is int) ? ISSUE_TYPE_PR : ISSUE_TYPE_ISSUE;
        Issue issue = {
            issueId: -1,
            githubId: issueJson.id.toString(),
            repositoryId: repository.repositoryId,
            createdDate: issueJson.created_at.toString(),
            updatedDate: issueJson.updated_at.toString(),
            closedDate: issueJson.closed_at.toString(),
            createdBy: issueJson.user.login.toString(),
            issueType: issueType,
            issueTitle: issueJson.title.toString(),
            issueURL: issueJson.html_url.toString(),
            labels: labels,
            assignees: assignees
        };
        issues.push(issue);
    }

    return issues;
}

function fetchPRReviewFromGithub(OpenPR openPR) returns PRReview? {
    string reqURL = "/repos/" + getReviewReqURL(openPR.prUrl) + "/reviews?&per_page=" + ITEM_PER_PAGE.toString();
    boolean continueOnError = false; 
    json[] reviewsJson = getResponseFromGithub(reqURL, "getting PR reviews", continueOnError);

    string reviewers = "";
    string reviewStates = "";
    string lastReviewer = "";
    string lastState = "";
    int lastReviewId = 0;

    map<string> reviewerMap = {};
    map<string> stateMap = {};

    foreach json reviewJson in reviewsJson {
        int reviewId = <int> reviewJson.id;
        string reviewer = reviewJson.user.login.toString();
        string state = reviewJson.state.toString();
        if (lastReviewId < reviewId){
            lastReviewId = reviewId;
            lastReviewer = reviewer;
            lastState = state;
        }

        if (!reviewerMap.hasKey(reviewer)){
            reviewerMap[reviewer] = reviewer; //Remember that we have already added this reviewer
            reviewers = reviewers + reviewer + ", ";
        }
        if (!stateMap.hasKey(state)){
            stateMap[state] = state;
            reviewStates = reviewStates + state + ", ";
        }
    }

    //Send only if there are something to be sent;
    if (lastReviewId != 0) {
        //If there are some reviews, there should be at least of reviewer and state. 
        //Hence, we need to remove trailing comma. 
        reviewers =  reviewers.substring(0, reviewers.length() - 2);
        reviewStates =  reviewStates.substring(0, reviewStates.length() - 2);

        PRReview review = {
                issueId: openPR.issueId,
                reviewers: reviewers,
                reviewStates: reviewStates,
                lastReviewer: lastReviewer,
                lastState: lastState
        };
        return review;
    } else {
        //Nothing to return
        return;
    }
}

function getReviewReqURL (string prURL) returns string {
    //Exclude github URL part from prURL
    string githubURL = "https://github.com/";
    int startLocation = githubURL.length();
    string subStr = prURL.substring(startLocation, prURL.length());

    //Change "pull" to "pulls"
    int? pullPartLocation = subStr.indexOf("/pull/");
    if (pullPartLocation is int) {
        string finalURLpart = subStr.substring(0, pullPartLocation) + "/pulls/" +
            subStr.substring(pullPartLocation + 6, subStr.length());
        return finalURLpart;
    }

    return "";
}

function getResponseFromGithub (string url, string actionContext, boolean continueOnError) returns json[] {
   //Create the request to send to github. Mainly the authentication key
    http:Request req = new;
    req.addHeader("Authorization", "token " + config:getAsString("GITHUB_AUTH_KEY"));

    int pageIterator = 0;
    json[] combinedResponseArr = [];

    //Repeat until we get last page, which is empty response
    while (true) {
        pageIterator = pageIterator + 1;
        string reqURL = url + "&page=" + pageIterator.toString();

        http:Response|error retVal = gitClientEP->get(reqURL, message = req);
        http:Response response = new; //initialized to avoid compiler warning due to nested loops
        
        //Check whether the response is valid
        if (retVal is error) {
            log:printError("Error when calling the github API : " + retVal.detail().toString(), err = retVal);
            log:printError("[Context] Action = [" + actionContext + "], URL = [" + reqURL + "]");
            if (continueOnError) {
                //Even though it is an error, we are continuing with calling remaining pages
                continue;
            } else {
                log:printError("Stoping the action [" + actionContext + "]");
                return [];
            }
        } else {
            response = retVal;
        }

        //Check whether the status code is valid
        int statusCode = response.statusCode;
        if (statusCode != http:STATUS_OK && statusCode != http:STATUS_MOVED_PERMANENTLY){
            log:printError("Error when calling the github API. StatusCode for the request is " +
                statusCode.toString() + ". " + response.getJsonPayload().toString());
            log:printError("[Context] Action = [" + actionContext + "], URL = [" + reqURL + 
                "], StatusCode = [" + statusCode.toString() + "]");
            if (continueOnError) {
                //Even though it is an error, we are continuing with calling remaining pages
                continue;
            } else {
                log:printError("Stoping the action [" + actionContext + "]");
                return [];
            }
        }

        //Check whether the response contains json payload
        json|error respJson = response.getJsonPayload();
        if (respJson is error) {
            log:printError("Error when calling the github API. Response is not JSON", err = respJson);
            log:printError("[Context] Action = [" + actionContext + "], URL = [" + reqURL + "]");
            if (continueOnError) {
                //Even though it is an error, we are continuing with calling remaining pages
                continue;
            } else {
                log:printError("Stoping the action [" + actionContext + "]");
                return [];
            }
        }

        //All checkes are validated. Process the response and store them
        json[] pageResponseArr = <json[]>respJson;
        mergeArrays(combinedResponseArr, pageResponseArr);
        if (pageResponseArr.length() < ITEM_PER_PAGE) {
            //No more issues to fetch
            break;
        }
    }
    return combinedResponseArr;
}

//Get issue labels for an issue
function getIssueLabels(json[] issueLabels) returns string {
    string commaSeperatedVal = "";
    foreach var label in issueLabels {
        commaSeperatedVal = commaSeperatedVal + label.name.toString() + ", ";
    }

    //Have to remove the last trailing comma. However, it could be empty array
    if (issueLabels.length() != 0) {
        commaSeperatedVal =  commaSeperatedVal.substring(0, commaSeperatedVal.length() - 2);
    }
    return commaSeperatedVal;
}

//Get issue assignees for an issue
function getIssueAssignees(json[] issueAssignees) returns string {
    string commaSeperatedVal = "";
    foreach var assignee in issueAssignees {
        commaSeperatedVal = commaSeperatedVal + assignee.login.toString() + ", ";
    }

    //Have to remove the last trailing comma. However, it could be empty array
    if (issueAssignees.length() != 0) {
        commaSeperatedVal =  commaSeperatedVal.substring(0, commaSeperatedVal.length() - 2);
    }
    return commaSeperatedVal;
}

