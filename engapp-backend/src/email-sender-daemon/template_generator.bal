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

import ballerina/time;

string htmlHeader = string `
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Open PR Details</title>
      <style>
        #headings {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        width: 100%;
        background-color: #044767;
        color: #fff;
        padding: 10px;
        text-align: center;
        font-weight: 600px;
        font-size: 20px;
        margin-bottom: 10px;
        margin-top: 30px;
      }
        #subhead {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        font-weight: 400px;
        font-size: 18px;
        color: #777777;
        padding: 20px;
        text-align: center;
        margin: 10px;
      }
        #title {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        font-weight: 350px;
        font-size: 16px;
        color: #777777;
        padding-top: 20px;
        text-align: center;
        margin: 10px;
      }
      #openprs {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        border-collapse: collapse;
        margin: 20px;
        font-weight: 200px;
        font-size: 14px;
      }

      #openprs td, #openprs th {
        border: 0px solid #ddd;
        padding: 8px;
      }

      #openprs tr{
        background-color: #dedede;
      }
      #openprs tr:hover {background-color: #dedede;}
      #openprs th {
          padding-top: 12px;
          padding-bottom: 12px;
          text-align: center;
          background-color: #044767;
          color: #fff;
        }
      #openprs tr:nth-child(even) td{background-color: #efefef;}
      #openprs tr:nth-child(odd) td{background: #dedede;}

    </style>
  </head>
  <body>
 `;

string templateHeader = string `
   <div id = "headings" style="width:100%; color:#fff; background:#044767; font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 20px; padding: 15px 10px 5px 10px;" align="center">
       <h2>GitHub Open Pull Request Analyzer</h2>
   </div>
   <div id = "title" align="center" style="padding-top:20px;">
      <h3>Summary<h3>
   </div>
   <div align = "center">
   <table id="openprs" cellspacing="0" cellpadding="10">
   <tr>
    <th style="width:240px; color:#fff; background:#044767; font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 20px; padding: 15px 10px 5px 10px;">
      Team Name</th>
    <th style="width:120px; color:#fff; background:#044767; font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 20px; padding: 15px 10px 5px 10px;">
      No of Open PRs</th>
   </tr>
`;

function getTableHeading() returns string {
    string style = " style=\" color:#fff; background:#044767; font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 20px; padding: 15px 10px 5px 10px;\""; 

    string tableHeading = "" +
        "<table id=\"openprs\" width=\"95%\" align=\"center\"  cellspacing=\"0\" cellpadding=\"10\">" +
            "<tr>" +
            "<th width=30% " + style + ">Pull Request Title</th>" +
            "<th width=30% " + style + ">Pull Request URL</th>" +
            "<th width=12% " + style + ">Created By</th>" +
            "<th width=6% " + style + ">Open Days</th>" +
            "<th width=10% " + style + ">Updated On</th>" +
            "<th width=12% " + style + ">Last State</th>" +
         "</tr>";
    return tableHeading;
}

string templateFooter = string `
    <div align = center>
        <img src="https://upload.wikimedia.org/wikipedia/en/5/56/WSO2_Software_Logo.png" width="90" height="37"
            style="display: block; border: 0px;>
        <p align="center" >
            Copyright (c) 2019 | WSO2 Inc.<br/>All Right Reserved.
        </p>
    </div>
`;

string htmlFooter = string `
    </body>
    </html> `;

function generateDateContent(string updatedDate) returns string {
  string dateContent = string `
                         <div id = "subhead" align = "center" style="padding-top:20px;">
                             Updated Time <br/>`
      + updatedDate + "</div>";
  return dateContent;
}

function generateContent(OpenPROfTeam[] data) returns string {
    string tableData = "";
    boolean toggleFlag = true;
    string backgroundColor = BACKGROUND_COLOR_WHITE;   
    string style = " style=\"font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 20px;  \""; 

    foreach OpenPROfTeam datum in data {
        backgroundColor = getBackgroundColor(toggleFlag);
        toggleFlag = !toggleFlag;

        tableData = tableData + "<tr>";
        tableData = tableData + "<td width=\"" + "30%" + "\" align=\"center\"" + backgroundColor + style + ">" +
                           datum.issueTitle + "</td>";
        tableData = tableData + "<td width=\"" + "30%" + "\" align=\"center\"" + backgroundColor + style + ">" +
                           datum.htmlURL + "</td>";
        tableData = tableData + "<td width=\"" + "12%" + "\" align=\"center\"" + backgroundColor + style + ">" +
                           datum.createdBy + "</td>";
        tableData = tableData + "<td width=\"" + "6%" + "\" align=\"center\"" + backgroundColor + style + ">" +
                           datum.openDays.toString() + "</td>";
        tableData = tableData + "<td width=\"" + "10%" + "\" align=\"center\"" + backgroundColor + style + ">" +
                           time:toString(datum.updatedDate).substring(0, 10) + "</td>";
        tableData = tableData + "<td width=\"" + "12%" + "\" align=\"center\"" + backgroundColor + style + ">" +
                           datum.lastState.toString() + "</td>";
        tableData = tableData + "</tr>";
    }
    return tableData;
}

//Generates the summary table content for issue counts for each team for mail template
function generateTable() returns string {
    Team[] teams = retrieveAllTeams();
    string summaryTable = "";
    string tableForTeam = "";

    Team? unknownTeam = ();
    OpenPROfTeam[] unknownTeamPRs = [];
    int UNKNOWN_TEAM_ID = -1;
    int IGNORE_TEAM_ID = 0;

    //Formatting options
    boolean toggleFlag = true;
    string backgroundColor = "";
    
    foreach Team team in teams {
        OpenPROfTeam[] prs = retrieveAllOpenPRsByTeam (team.teamId);
        if (team.teamId == UNKNOWN_TEAM_ID) {
            unknownTeam = team;
            unknownTeamPRs = prs;
            //We'll add this at the bottom of the tables
            continue;
        } else if (team.teamId == IGNORE_TEAM_ID){
            //We'll ignore this teams
            continue;
        }

        backgroundColor = getBackgroundColor(toggleFlag);
        toggleFlag = !toggleFlag;

        summaryTable = summaryTable + "<tr><td align=\"center\" " + backgroundColor + " style=\"padding: 15px 10px 5px 10px;\">" + team.teamName + 
            "</td><td align=\"center\" " + backgroundColor + " style=\"padding: 15px 10px 5px 10px;\">" + 
            team.noOfOpenPRs.toString() + "</td></tr>";

        if (prs.length() != 0) {
            string tableTitlediv = "<div id = \"title\" align=\"center\" style=\"padding-top:20px;\"><h3>" + 
                team.teamName + "</h3></div>";
            tableForTeam = tableForTeam + tableTitlediv + getTableHeading() + generateContent(prs) + "</table>";
        }        
    }

    if (unknownTeam is Team) {
        //Print unknown team details:
        backgroundColor = getBackgroundColor(toggleFlag);
        toggleFlag = !toggleFlag;

        summaryTable = summaryTable + "<tr><td align=\"center\" " + backgroundColor + ">" + unknownTeam.teamName + 
            "</td><td align=\"center\" " + backgroundColor + ">" + 
            unknownTeam.noOfOpenPRs.toString() + "</td></tr>";

        if (unknownTeamPRs.length() != 0) {
            string tableTitlediv = "<div id = \"title\" align=\"center\" style=\"padding-top:20px;\"><h3>" + 
                unknownTeam.teamName + "</h3></div>";
            tableForTeam = tableForTeam + tableTitlediv + getTableHeading() + generateContent(unknownTeamPRs) + "</table>";
        }
    }

    return summaryTable + "</table></div>" + tableForTeam;
}

function getBackgroundColor (boolean toggleFlag) returns string {
  if (toggleFlag) {
      return " bgcolor=" + BACKGROUND_COLOR_WHITE;
  }
  else {
      return " bgcolor=" + BACKGROUND_COLOR_GRAY;
  }
}
