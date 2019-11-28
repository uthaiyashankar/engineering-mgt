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

// Sql Queries
string RETRIEVE_TEAMS_AND_OPENPR_COUNT = "SELECT ENGAPP_TEAMS.TEAM_ID, TEAM_NAME, COUNT(ISSUE_ID) AS NO_OF_ISSUES " + 
		"FROM ENGAPP_GITHUB_ISSUES, ENGAPP_GITHUB_REPOSITORIES, ENGAPP_TEAMS " +
		"WHERE ENGAPP_GITHUB_ISSUES.REPOSITORY_ID = ENGAPP_GITHUB_REPOSITORIES.REPOSITORY_ID AND " +
		"ENGAPP_GITHUB_REPOSITORIES.TEAM_ID = ENGAPP_TEAMS.TEAM_ID AND " +
		"ISSUE_TYPE = 'PR' and CLOSED_DATE is NULL " +
		"GROUP BY ENGAPP_TEAMS.TEAM_ID, TEAM_NAME ORDER BY COUNT(ISSUE_ID) DESC;";
string RETRIEVE_OPENPR_BY_TEAM = "SELECT ISSUE_TITLE, HTML_URL, CREATED_BY,  DATEDIFF(CURDATE(), CREATED_DATE) AS OPEN_DAYS, " +
		"UPDATED_DATE, IFNULL (LAST_STATE, 'NEW') AS LAST_STATE " +
		"FROM ENGAPP_GITHUB_ISSUES LEFT JOIN ENGAPP_GITHUB_PR_REVIEWS " +
		"ON ENGAPP_GITHUB_ISSUES.ISSUE_ID = ENGAPP_GITHUB_PR_REVIEWS.ISSUE_ID " +
		"WHERE ISSUE_TYPE = 'PR' and CLOSED_DATE is NULL AND " +
		"REPOSITORY_ID in (SELECT REPOSITORY_ID FROM ENGAPP_GITHUB_REPOSITORIES WHERE TEAM_ID = ?) " +
		"ORDER BY OPEN_DAYS DESC;";

public const string BACKGROUND_COLOR_GRAY = "#dedede";
public const string BACKGROUND_COLOR_WHITE = "#efefef";

