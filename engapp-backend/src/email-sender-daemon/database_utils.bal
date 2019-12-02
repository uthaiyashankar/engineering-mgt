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
// import ballerina/jsonutils;
import ballerina/log;
import ballerinax/java.jdbc;

jdbc:Client engappDb = new ({
    url: config:getAsString("DB_URL"),
    username: config:getAsString("DB_USERNAME"),
    password: config:getAsString("DB_PASSWORD"),
    dbOptions: {useSSL: false}
});

//Retrieves the team details from the database
function retrieveAllTeams() returns Team[] {
    var dbResult = engappDb->select(RETRIEVE_TEAMS_AND_OPENPR_COUNT, Team);
    Team[] teams = [];
    if (dbResult is table<Team>) {
        foreach Team team in dbResult {
            teams.push(team);
        }
    } else {
        log:printError("Error occured while retrieving the team details from Database", err = dbResult);
        //Yet, we'll ignore the error and return empty array
    }

    return teams;
}

function retrieveAllOpenPRsByTeam(int teamId) returns OpenPROfTeam[] {
    var dbResult = engappDb->select(RETRIEVE_OPENPR_BY_TEAM, OpenPROfTeam, teamId);
    OpenPROfTeam[] prs = [];
    if (dbResult is table<OpenPROfTeam>) {
        foreach OpenPROfTeam pr in dbResult {
            prs.push(pr);
        }
    } else {
        log:printError("Error occured while retrieving the open PR details from Database", err = dbResult);
        log:printError("Context: TeamID = [" + teamId.toString() + "]");
    }
    return prs;
}

// //Retrieves the count of open PRs for each team
// function openPrsForTeam(int teamId, string teamName) returns json[]? {
//     json[] prJson = [];
//     var prs = retrieveAllIssuesByTeam(teamId);
//     if (prs is json[]) {
//         foreach var pr in prs {
//             json prDetail = {
//                 teamName: teamName,
//                 repoName: pr.REPOSITORY_NAME.toString(),
//                 updatedDate: pr.UPDATED_DATE.toString(),
//                 createdBy: pr.CREATED_BY.toString(),
//                 url: pr.HTML_URL.toString(),
//                 openDays: pr.OPEN_DAYS.toString(),
//                 labels: pr.LABELS.toString()
//             };
//             prJson.push(prDetail);
//         }
//     } else {
//         log:printError("Returned value is not a json. Error occured while retrieving the issue details from Database", 
//             err = prs);
//     }
//     return <json[]>prJson;
// }
