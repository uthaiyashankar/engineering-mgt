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

import ballerina/time;

type Organization record {
    int id;
    string githubId;
    string orgName;
};

type Repository record {
    int repositoryId;
    string githubId;
    string repoName;
    int orgId;
    string repoURL;
    string repoType;
};

type Issue record {
    int issueId;
    string githubId;
    int repositoryId;
    string  createdDate;
    string updatedDate;
    string closedDate;
    string createdBy;
    string issueType;
    string issueTitle;
    string issueURL;
    string labels;
    string assignees;
};

type LastIssueUpdatedDate record {
    int repositoryId;
    time:Time date;
};

type IssueIdsAndUpdateTime record {
    int issueId;
    string githubId;
    time:Time updatedTime;
};

type OpenPR record {
    int issueId;
    string prUrl;
};

type PRReview record {
    int issueId;
    string reviewers;
    string reviewStates;
    string lastReviewer;
    string lastState;
};

type User record {
    int userId;
    string githubId;
    string loginName;
    string name;
    string company;
    string email;
    string profileUrl;
    string websiteUrl;
};

type OrgUser record {
    int orgId;
    int userId;
};
