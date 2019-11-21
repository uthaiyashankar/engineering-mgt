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
import ballerina/time;

string UPDATED_TIME = time:toString(time:currentTime());
string UPDATED_DATE = UPDATED_TIME.substring(0, 10);

// Sql Queries
string RETRIEVE_TEAMS = "SELECT * FROM ENGAPP_GITHUB_TEAMS";
string RETRIEVE_ISSUES_BY_TEAM = "SELECT CAST(UPDATED_DATE AS DATE) AS UPDATED_DATE, CREATED_BY, REPOSITORY_NAME, " + 
	"HTML_URL, DATEDIFF(CURDATE(), CAST(CREATED_DATE AS DATE)) AS OPEN_DAYS ,LABELS, TEAM_ID FROM " + 
	"ENGAPP_GITHUB_REPOSITORIES INNER JOIN ENGAPP_GITHUB_ISSUES USING (REPOSITORY_ID) WHERE ISSUE_TYPE='PR' " + 
	"AND TEAM_ID=? AND CLOSED_DATE IS NULL";

//Cron expression to mail open prs update
string CRON_EXPRESSION = config:getAsString("CRON_EXPRESSION_MAIL");
