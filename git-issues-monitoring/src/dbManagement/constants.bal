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
//sql queries
string RETRIEVE_ORGANIZATIONS = "SELECT * FROM ENGAPP_GITHUB_ORGANIZATIONS";
string RETRIEVE_REPOSITORIES = "SELECT * FROM ENGAPP_GITHUB_REPOSITORIES";
string RETRIEVE_REPOSITORIES_BY_ORG_ID = "SELECT * FROM ENGAPP_GITHUB_REPOSITORIES WHERE ORG_ID=?";
string GET_UPDATED_DATE = "SELECT DATE_FORMAT(UPDATED_DATE, '%Y-%m-%dT%TZ') as date FROM ENGAPP_GITHUB_ISSUES";
string INSERT_REPOSITORIES = "INSERT INTO ENGAPP_GITHUB_REPOSITORIES(GITHUB_ID, REPOSITORY_NAME, ORG_ID, URL, TEAM_ID)
        Values (?,?,?,?,?)";
string UPDATE_REPOSITORIES = "UPDATE ENGAPP_GITHUB_REPOSITORIES SET REPOSITORY_NAME=?,URL=? WHERE GITHUB_ID=?";
string INSERT_ISSUES = "INSERT INTO ENGAPP_GITHUB_ISSUES(GITHUB_ID,REPOSITORY_ID,CREATED_DATE,UPDATED_DATE,
		CLOSED_DATE,CREATED_BY,ISSUE_TYPE,HTML_URL,LABELS,ASSIGNEES) Values (?,?,?,?,?,?,?,?,?,?)";
string UPDATE_ISSUES = "UPDATE ENGAPP_GITHUB_ISSUES SET REPOSITORY_ID=?,CREATED_DATE=?,UPDATED_DATE=?,CLOSED_DATE=?,
        CREATED_BY=?,ISSUE_TYPE=?, HTML_URL=? ,LABELS=? ,ASSIGNEES = ? WHERE GITHUB_ID=?";
string UPDATE_ORGID = "UPDATE ENGAPP_GITHUB_REPOSITORIES SET ORG_ID=? WHERE GITHUB_ID=?";
string GET_ORG_NAME = "SELECT ORG_NAME FROM ENGAPP_GITHUB_ORGANIZATIONS WHERE ORG_ID=?";
string ISSUE_EXISTS = "SELECT * FROM ENGAPP_GITHUB_ISSUES WHERE GITHUB_ID=?";

string AUTH_KEY = config:getAsString("GITHUB_AUTH_KEY");
string GITHUB_API = config:getAsString("GITHUB_API");

//Cron expression to update database periodically
string CRON_EXPRESSION = config:getAsString("CRON_EXPRESSION");
