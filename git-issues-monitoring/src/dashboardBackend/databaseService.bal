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
import ballerina/jsonutils;
import ballerina/log;
import ballerinax/java.jdbc;

jdbc:Client githubDb = new ({
    url: config:getAsString("DB_URL"),
    username: config:getAsString("DB_USERNAME"),
    password: config:getAsString("DB_PASSWORD"),
    poolOptions: {maximumPoolSize: 10},
    dbOptions: {useSSL: false}
});

type IssueCount record {
    int count;
};

type TotalOpenIssueCount record {
    string name;
    int totalIssueCount;
};

type TotalIssueOpenDays record {
    string name;
    int opendays;
};


type TotalOpenIssueCountByLabel record {
    string name;
    string labels;
    int count;

};

function retrieveAllTeamsName() returns json[]? {
    var teams = githubDb->select(RETRIEVE_TEAMS_NAME, ());
    if (teams is table<record {}>) {
        json teamJson = jsonutils:fromTable(teams);
        return <json[]>teamJson;
    } else {
        log:printError("Error occured while retrieving the team details from Database", err = teams);
    }
}

//Get details of issue counts in terms of issue labels for each team
function getDetailsOfIssue() returns json[] {
    int teamIterator = 0;
    string name = "";
    string labels = "";
    int count = 0;
    json[] teamIssues = [];
    var teamJson = retrieveAllTeamsName();
    if (teamJson is json[]) {
        foreach var team in teamJson {
            string team_name = team.TEAM_ABBR.toString();
            var totalIssueCount = githubDb->select(RETRIEVE_TOTAL_OPPEN_ISSUE_COUNT_BY_LABELS, TotalOpenIssueCountByLabel);
            int l1issuecount = 0;
            int l2issuecount = 0;
            int l3issuecount = 0;
            if (totalIssueCount is table<TotalOpenIssueCountByLabel>) {
                foreach ( TotalOpenIssueCountByLabel issueCount in totalIssueCount) {
                    name = issueCount.name.toString();
                    labels = issueCount.labels.toString();
                    count = <int>issueCount.count;
                    string l1Issues = "Severity/Blocker";
                    string l2Issues = "Severity/Critical";
                    string l3Issues = "Severity/Major";
                    int? l1IssueIndex = labels.indexOf(l1Issues);
                    int? Isteamename = name.indexOf(team_name);
                    if (l1IssueIndex is int && Isteamename is int) {
                        l1issuecount = l1issuecount + 1;
                    }
                    int? l2IssueIndex = labels.indexOf(l2Issues);
                    if (l2IssueIndex is int && Isteamename is int) {
                        l2issuecount = l2issuecount + 1;
                    }
                    int? l3IssueIndex = labels.indexOf(l3Issues);
                    if (l3IssueIndex is int && Isteamename is int) {
                        l3issuecount = l3issuecount + 1;
                    }
                }
                teamIssues[teamIterator] = {
                    name: team_name,
                    L1IssueCount: <int>l1issuecount,
                    L2IssueCount: <int>l2issuecount,
                    L3IssueCount: <int>l3issuecount
                };


            }
            else {
                log:printError("Error occured while insering the open issues count details for each day to the Database",
                err = totalIssueCount);
            }

            teamIterator = teamIterator + 1;
        }
    }
    else {
        log:printError("Returned value is not a json. Error occured while retrieving the team details
                                                from Database", err = teamJson);
    }
    return teamIssues;
}


//Inserts the number of open and closed issue count every day
function InsertIssueCountDetails() {
    var openIssueCount = githubDb->select(RETRIEVE_OPEN_ISSUE_COUNT, IssueCount);
    var closedIssueCount = githubDb->select(RETRIEVE_CLOSED_ISSUE_COUNT, IssueCount);
    int openIssue = 0;
    int closedIssue = 0;
    if (openIssueCount is table<IssueCount>) {
        foreach ( IssueCount issueCount in openIssueCount) {
            openIssue = <int>issueCount.count;
        }
    } else {
        log:printError("Error occured while insering the open issues count details for each day to the Database",
        err = openIssueCount);
    }
    if (closedIssueCount is table<IssueCount>) {
        foreach ( IssueCount issueCount in closedIssueCount) {
            closedIssue = <int>issueCount.count;
        }
    } else {
        log:printError("Error occured while insering the closed issues count details for each day to the Database",
        err = closedIssueCount);
    }
    var ret = githubDb->update(INSERT_ISSUE_COUNT, openIssue, closedIssue);
    handleUpdate(ret, "Inserted Issue count details with variable parameters");
}

// Get the total issue count for each team
function getCountOfIssue() returns json[] {
    int teamIterator = 0;
    string name = "";
    int count = 0;
    json[] teamIssues = [];
    var totalIssueCount = githubDb->select(RETRIEVE_TOTAL_ISSUE_COUNT, TotalOpenIssueCount);
    if (totalIssueCount is table<TotalOpenIssueCount>) {
        foreach ( TotalOpenIssueCount issueCount in totalIssueCount) {
            name = issueCount.name.toString();
            count = <int>issueCount.totalIssueCount;
            teamIssues[teamIterator] = {
                name: name,
                totalIssueCount: count
            };
            teamIterator = teamIterator + 1;
        }
    } else {
        log:printError("Error occured while insering the open issues count details for each day to the Database",
        err = totalIssueCount);
    }
    return <@untainted>teamIssues;
}


//Retrieves the number of open and closed Issue counts details everyday
function retrieveIssueCountDetails() returns json[] {
    var issueCounts = githubDb->select(RETRIEVE_ISSUE_COUNT, ());
    json[] issueCountDetail = [];
    if (issueCounts is table<record {}>) {
        int iterator = 0;
        json[] openIssueData = [];
        json[] closedIssueData = [];
        json[] issueCountsJson = <json[]>jsonutils:fromTable(issueCounts);
        while (iterator < issueCountsJson.length()) {
            json openIssue = {
                date: issueCountsJson[iterator].DATE.toString(),
                count: issueCountsJson[iterator].OPEN_ISSUES.toString()
            };
            json closedIssue = {
                date: issueCountsJson[iterator].DATE.toString(),
                count: issueCountsJson[iterator].CLOSED_ISSUES.toString()
            };
            openIssueData[iterator] = openIssue;
            closedIssueData[iterator] = closedIssue;
            iterator = iterator + 1;
        }
        issueCountDetail = [
        {
            name: "Open Issues",
            data: openIssueData
        },
        {
            name: "Closed Issues",
            data: closedIssueData
        }
        ];
    } else {
        log:printError("Returned value is not a json. Error occured while retrieving the issues count from Database");
    }
    return issueCountDetail;
}



//Retrieves the how many number of issues are open for specific periods like day, week, month etc for each team
function openIssuesAgingForTeam() returns json[] {
    json[] data = [];
    string name = "";
    var teams = retrieveAllTeamsName();
    if (teams is json[]) {
        json[] issuesForTeams = [];
        foreach var team in teams {
            int day = 0;
            int week = 0;
            int month = 0;
            int month3 = 0;
            int morethan = 0;
            string team_name = team.TEAM_ABBR.toString();
            var totalIssueCount = githubDb->select(RETRIEVE_TOTAL_OPPEN_ISSUE_COUNT_BY_TEAM, TotalIssueOpenDays);

            if (totalIssueCount is table<TotalIssueOpenDays>) {
                foreach ( TotalIssueOpenDays issueCount in totalIssueCount) {
                    name = issueCount.name.toString();
                    //statement.indexOf("on");
                    int openDays = <int>issueCount.opendays;
                    int? Isteamename = name.indexOf(team_name);
                    if (openDays <= 1 && Isteamename is int) {
                        day = day + 1;
                    } else if (openDays <= 7 && Isteamename is int) {
                        week = week + 1;
                    } else if (openDays <= 30 && Isteamename is int) {
                        month = month + 1;
                    } else if (openDays <= 90 && Isteamename is int) {
                        month3 = month3 + 1;
                    } else if (Isteamename is int) {
                        morethan = morethan + 1;
                    }
                }
            } else {
                log:printError("Returned value is not a json. Error occured while retrieving the issue details
                            from Database", err = totalIssueCount);
            }
            json teamData = {
                name: team_name,
                data: [["1 Day", day], ["1 Week", week], ["1 Month", month], ["3 Months", month3],
                ["Morethan 3 months", morethan]]
            };
            data.push(teamData);
        }
    } else {
        log:printError("Returned value is not a json. Error occured while retrieving the teams aging details
                            to the Database", err = teams);
    }


    return data;
}

function handleUpdate(jdbc:UpdateResult | jdbc:Error status, string message) {
    if (status is jdbc:UpdateResult) {
        log:printInfo(message);
    }
    else {
        log:printError("Failed to update the tables: ", status);
    }
}
