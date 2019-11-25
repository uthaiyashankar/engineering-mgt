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

//sql queries
const string GET_ALL_ORGANIZATIONS = "SELECT * FROM ENGAPP_GITHUB_ORGANIZATIONS";
const string GET_ALL_REPOSITORIES = "SELECT REPOSITORY_ID, GITHUB_ID, REPOSITORY_NAME, ORG_ID, URL from ENGAPP_GITHUB_REPOSITORIES";
const string GET_LAST_ISSUE_UPDATED_DATE = "SELECT REPOSITORY_ID, MAX(UPDATED_DATE)as date " + 
        "FROM ENGAPP_GITHUB_ISSUES GROUP BY REPOSITORY_ID;";
const string INSERT_REPOSITORY = "INSERT INTO ENGAPP_GITHUB_REPOSITORIES(GITHUB_ID, REPOSITORY_NAME, ORG_ID, URL) " +
         "Values (?,?,?,?)";
const string UPDATE_REPOSITORY = "UPDATE ENGAPP_GITHUB_REPOSITORIES SET REPOSITORY_NAME=?, URL=?, ORG_ID=? " + 
		"WHERE REPOSITORY_ID=?";
const string INSERT_ISSUES = "INSERT INTO ENGAPP_GITHUB_ISSUES(GITHUB_ID, REPOSITORY_ID, CREATED_DATE, UPDATED_DATE, " +
 		"CLOSED_DATE, CREATED_BY, ISSUE_TYPE, HTML_URL, LABELS, ASSIGNEES) Values (?,?,?,?,?,?,?,?,?,?)";
const string UPDATE_ISSUES = "UPDATE ENGAPP_GITHUB_ISSUES SET REPOSITORY_ID=?, CREATED_DATE=?, UPDATED_DATE=?, CLOSED_DATE=?, " +
         "CREATED_BY=?, ISSUE_TYPE=?, HTML_URL=?, LABELS=?, ASSIGNEES = ? WHERE ISSUE_ID=?";
const string GET_ALL_ISSUE_IDS = "SELECT ISSUE_ID, GITHUB_ID, UPDATED_DATE FROM ENGAPP_GITHUB_ISSUES";
