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

function getHtmlHeaderAndStyles(string title, string heading) returns string {
    string htmlHeader = string `
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>${title}</title>
      </head>
      <body>
        <div id="body-content" style="font-family: Open Sans, Arial, Helvetica, sans-serif;text-align: center;font-weight: 400px;line-height: 20px;">
          <div id="headings" style="background-color: #044767;color: #fff;padding: 10px;">
            <h2>${heading}</h2>
          </div>`;
    
    return htmlHeader;
}

function getSummaryTableHeader (string heading, string groupColumn, string resultColumn) returns string {
    string templateHeader = string `
      <div class="title" style="color: #777777;padding-top: 20px;">
        <h3>${heading}<h3>
      </div>
      <table style="border-collapse: collapse;display: inline-block;text-align: center;line-height: 20px;font-size: 14px;">
        <tr>
          <th ${getTableHeaderCellStyle("240px")}>${groupColumn}</th>
          <th ${getTableHeaderCellStyle("120px")}>${resultColumn}</th>
        </tr>`;
    return templateHeader;
}

function getOpenPRDetailsTableHeading(string teamName) returns string {
    string detailTableHeader = string `
    <div class="title" style="color: #777777;padding-top: 20px;">
      <h3>${teamName}</h3>
    </div>
    <table style="border-collapse: collapse;display: inline-block;text-align: center;line-height: 20px;font-size: 14px;width:95%;">
      <tr>
        <th ${getTableHeaderCellStyle("30%")}>Pull Request Title</th>
        <th ${getTableHeaderCellStyle("30%")}>Pull Request URL</th>
        <th ${getTableHeaderCellStyle("12%")}>Created By</th>
        <th ${getTableHeaderCellStyle("6%")}>Open Days</th>
        <th ${getTableHeaderCellStyle("10%")}>Updated On</th>
        <th ${getTableHeaderCellStyle("12%")}>Last State</th>
      </tr>`;
    return detailTableHeader;
}

string templateFooter = string `
    <div>
        <img id="logo" src="https://upload.wikimedia.org/wikipedia/en/5/56/WSO2_Software_Logo.png" style="width:90px;height:37px;display: inline-block;" />
        <p>
            Copyright (c) 2019 | WSO2 Inc.<br/>All Right Reserved.
        </p>
    </div>
`;

string htmlFooter = string `
    </div>
    </body>
    </html> `;

function generateDateContent(string updatedDate) returns string {
  string dateContent = string `
                         <div id = "subhead" style="color: #777777;padding: 20px;">
                             Updated Time <br/>`
      + updatedDate + "</div>";
  return dateContent;
}

function generateOpenPRDetailsTableContent(OpenPROfTeam[] data) returns string {
    string tableData = "";
    boolean toggleFlag = true;
    string cellStyle = "";

    foreach OpenPROfTeam datum in data {
        cellStyle = getCellStyle(toggleFlag);
        toggleFlag = !toggleFlag;
        tableData = tableData + string `
          <tr>
            <td ${cellStyle}>${datum.issueTitle}</td>
            <td ${cellStyle}>${datum.htmlURL}</td>
            <td ${cellStyle}>${datum.createdBy}</td>
            <td ${cellStyle}>${datum.openDays.toString()}</td>
            <td ${cellStyle}>${time:toString(datum.updatedDate).substring(0, 10)}</td>
            <td ${cellStyle}>${datum.lastState}</td>
          </tr>`;
    }
    return tableData;
}

//Generates the summary table content for issue counts for each team for mail template
function generateOpenPRTable() returns string {
    Team[] teams = retrieveAllTeams();
    string summaryTable = "";
    string tableForTeam = "";
    int IGNORE_TEAM_ID = 0;
    int totalOpenPRs = 0;

    //Formatting options
    boolean toggleFlag = true;
    string cellStyle = "";
    
    foreach Team team in teams {
        if (team.teamId == IGNORE_TEAM_ID){
            //We'll ignore this teams
            continue;
        }

        OpenPROfTeam[] prs = retrieveAllOpenPRsByTeam (team.teamId);
        totalOpenPRs = totalOpenPRs + team.noOfOpenPRs;
        
        cellStyle = getCellStyle(toggleFlag);
        toggleFlag = !toggleFlag;
        summaryTable = summaryTable + string`
            <tr>
              <td ${cellStyle}>${team.teamName}</td>
              <td ${cellStyle}>${team.noOfOpenPRs.toString()}</td>
            </tr>`;

        if (prs.length() != 0) {
            tableForTeam = tableForTeam + getOpenPRDetailsTableHeading(team.teamName) + 
                generateOpenPRDetailsTableContent(prs) + "</table>";
        }        
    }

    //Print total
    summaryTable = summaryTable + string`
      <tr>
        <td ${getTotalCellStyle()}>Total</td>
        <td ${getTotalCellStyle()}>${totalOpenPRs}</td>
      </tr>`;

    return summaryTable + "</table>" + tableForTeam;
}

function getCellStyle (boolean toggleFlag) returns string {
  if (toggleFlag) {
      return "style=\"background-color:" + BACKGROUND_COLOR_WHITE + ";padding: 10px;\"";
  }
  else {
      return "style=\"background-color:" + BACKGROUND_COLOR_GRAY + ";padding: 10px;\"";
  }
}

function getTableHeaderCellStyle (string width) returns string{
  return string `style="width:${width};background-color: #044767;color: #fff;padding: 10px;"`;
}

function getTotalCellStyle() returns string{
  return string `style="background-color:#c0c0c0;padding: 10px;"`;
}