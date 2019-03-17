//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

package src.org.wso2.mprdash.github.email;

import ballerina.data.sql;
import ballerina.log;
import ballerina.config;
import ballerina.net.http;
import ballerina.runtime;

//Background colours of the email content
public const string BACKGROUND_COLOR_WHITE = "#efefef";
public const string BACKGROUND_COLOR_GRAY = "#dedede";

@Description {value:"Html content of column headers in doc status summary table"}
public const string TABLE_HEADER_DOC_SUMMARY = string `<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:100%;">
                                                        <tr>
                                                            <td align="center" style="font-family: Helvetica, Arial, sans-serif; font-size: 18px; font-weight: 400; line-height: 10px; padding-top: 0px;">
		                                                        <table align="center" cellspacing="0" cellpadding="0" border="0" width="60%">
			                                                        <tr>
				                                                        <td width="20%" align="center" color="#044767" bgcolor="#cecece" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 15px; font-weight: 600; line-height: 20px; padding: 10px;">Doc Status</td>
                 		                                                <td width="20%" align="center" color="#044767" bgcolor="#cecece" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 15px; font-weight: 600; line-height: 20px; padding: 10px;">No of PRs Within 15 Days</td>
                 		                                                <td width="20%" align="center" color="#044767" bgcolor="#cecece" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 15px; font-weight: 600; line-height: 20px; padding: 10px;">Total No of PRs</td>
                 	                                                </tr>
                 	                                            </table>`;

@Description {value:"Generate html content for doc status summary in email."}
@Param {value:"DocStatusSummaryWithinTwoWeeks[]: Array of doc status summary within two weeks"}
@Param {value:"TotalDocStatusSummary[]: Array of total doc status summary"}
@Return {value:"String: html content for doc status summary"}
public function generateHtmlSummaryContent (DocStatusSummary[] docStatusSummary, string docStatus) (string) {
    string htmlSummaryContent = "";
    boolean toggleFlag = true;
    string backgroundColor;

    foreach row in docStatusSummary {
        if (toggleFlag) {
            backgroundColor = BACKGROUND_COLOR_WHITE;
            toggleFlag = false;
        } else {
            backgroundColor = BACKGROUND_COLOR_GRAY;
            toggleFlag = true;
        }

        string summaryTableColumnDataStyle = string `bgcolor={{backgroundColor}} style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 15px; font-weight: 400; line-height: 20px; padding: 10px;`;

        htmlSummaryContent = string `{{htmlSummaryContent}} <tr>
                                        <td width=20% align="left" {{summaryTableColumnDataStyle}}">{{docStatus}}</td>
                                        <td width=20% align="center" {{summaryTableColumnDataStyle}}">{{<string>row["prCountWithinTwoWeeks"]}}</td>
                                        <td width=20% align="center" {{summaryTableColumnDataStyle}}">{{<string>row["totalPrCount"]}}</td>
                                     </tr>`;
    }
    htmlSummaryContent = string `<table align="center" cellspacing="0" cellpadding="0" border="0" width="60%">{{htmlSummaryContent}}</table></td></tr></table>`;

    log:printInfo("Html doc status summary table generated successfully. Status : " + docStatus);
    return htmlSummaryContent;
}

@Description {value:"Generate html content for pull request status detailed table in email"}
@Param {value:"pullRequestsStatusDetails[]: Array of pull Request order by statuses"}
@Param {value:"status: Documentation Status"}
@Return {value:"String: html content for pull request status detailed table"}
public function generateHtmlTableContent (PrDocStatusDetails[] prStatusTable, string status) (string) {

    string tableColumnHeaderStyle = string `align="center" color="#044767" bgcolor="#bebebe" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 800; line-height: 20px; padding: 10px;`;

    string htmlTableContent = string `
                                        <h2 style="font-family: Helvetica, Open Sans, Arial, sans-serif; font-size: 20px; font-weight: 600; line-height:20px; color: #121212; margin: 0; align="center">
                                                Doc Status: {{status}}
                                            </h2>
                                            <table align="center" cellspacing="0" cellpadding="0" border="0" width="100%">
                                                <tr>
                                                    <td width="10%" {{tableColumnHeaderStyle}}">Product Name</td>
                                                    <td width="10%" {{tableColumnHeaderStyle}}">Product Version</td>
                                                    <td width="15%" {{tableColumnHeaderStyle}}">Repository Name</td>
                                                    <td width="10%" {{tableColumnHeaderStyle}}">Author</td>
                                                    <td width="20%" {{tableColumnHeaderStyle}}">Title</td>
                                                    <td width="20%" {{tableColumnHeaderStyle}}">Url</td>
                                                    <td width="15%" {{tableColumnHeaderStyle}}">Days Since Merged Date</td>
                                                </tr>`;

    boolean toggleColorFlag = true;
    string backgroundColor;

    foreach row in prStatusTable {
        if (toggleColorFlag) {
            backgroundColor = BACKGROUND_COLOR_WHITE;
            toggleColorFlag = false;
        } else {
            backgroundColor = BACKGROUND_COLOR_GRAY;
            toggleColorFlag = true;
        }

        string tableColumnDataStyle = string `bgcolor={{backgroundColor}} style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 20px; padding: 15px 10px 5px 10px;`;

        htmlTableContent = string `{{htmlTableContent}}<tr>
                                                            <td width="5%" align="center" {{tableColumnDataStyle}}">{{row["productName"]}}</td>
                                                            <td width="5%" align="center" {{tableColumnDataStyle}}">{{row["productVersion"]}}</td>
                                                            <td width="10%" align="center" {{tableColumnDataStyle}}">{{row["repoName"]}}</td>
                                                            <td width="10%" align="center" {{tableColumnDataStyle}}">{{row["prAuthor"]}}</td>
                                                            <td width="25%" align="left" {{tableColumnDataStyle}}">{{row["prTitle"]}}</td>
                                                            <td width="25%" align="left" {{tableColumnDataStyle}}">{{row["prUrl"]}}</td>
                                                            <td width="20%" align="center" {{tableColumnDataStyle}}">{{<string>row["daysSinceMergerdDate"]}}</td>`;
    }

    htmlTableContent = string `{{htmlTableContent}}</tr></table><br/><br/>`;

    log:printInfo("Html pr doc status table generated successfully. Status : " + status);
    return htmlTableContent;
}

@Description {value:"Html content of email header"}
public function generateEmailHeader(string currentDate) (string) {

    string emailHtmlHeader = string `<!DOCTYPE html>
                                              <html>
                                                <head>
                                                    <title>PR Documentation Status Emailer</title>
                                                    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                                                    <meta name="viewport" content="width=device-width, initial-scale=1">
                                                    <style type="text/css">
                                                        /* CLIENT-SPECIFIC STYLES */
                                                        body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
                                                        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
                                                        img { -ms-interpolation-mode: bicubic; }
                                                        /* RESET STYLES */
                                                        img { border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; }
                                                        table { border-collapse: collapse !important; }
                                                        body { height: 100% !important; margin: 0 !important; padding: 0 !important; width: 100% !important; }
                                                        /* iOS BLUE LINKS */
                                                        a[x-apple-data-detectors] {
                                                        color: inherit !important;
                                                        text-decoration: none !important;
                                                        font-size: inherit !important;
                                                        font-family: inherit !important;
                                                        font-weight: inherit !important;
                                                        line-height: inherit !important;
                                                        }
                                                        /* MEDIA QUERIES */
                                                        @media screen and (max-width: 480px) {
                                                        .mobile-hide {
                                                        display: none !important;}
                                                        .mobile-center {
                                                        text-align: center !important;}
                                                        }
                                                        /* ANDROID CENTER FIX */
                                                        div[style*="margin: 16px 0;"] { margin: 0 !important; }
                                                    </style>
                                                    <body style="margin: 0 !important; padding: 0 !important; background-color: #ffffff;" bgcolor="#ffffff">
                                                    <!-- HIDDEN PREHEADER TEXT -->
                                                        <div style="display: none; font-size: 1px; color: #efefef; line-height: 1px; font-family: Open Sans, Helvetica, Arial, sans-serif; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden;">
                                                            Detailed List of Doc Status
                                                        </div>
                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                            <tr>
                                                                <td align="center" style="background-color: #ffffff;" bgcolor="#ffffff">
                                                                    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:100%;">
                                                                        <tr>
                                                                            <td align="center" valign="top" style="font-size:0; padding: 12px;" bgcolor="#044767">
                                                                                <div style="display:inline-block; max-width:50%; min-width:100px; vertical-align:top; width:100%;">
                                                                                    <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:500px;">
                                                                                        <tr>
                                                                                            <td align="left" valign="top" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 36px; font-weight: 800; line-height: 40px;" class="mobile-center">
                                                                                            <h1 style="font-size: 22px; font-weight: 600; margin: 0; color: #ffffff;">
                                                                                                Doc Status of PRs as at : {{currentDate}}</h1>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                                <div style="display:inline-block; max-width:50%; min-width:100px; vertical-align:top; width:100%;" class="mobile-hide">
                                                                                    <table align="right" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:300px;">
                                                                                        <tr>
                                                                                            <td align="right" valign="top" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 45px; font-weight: 400; line-height: 45px;">
                                                                                                <table cellspacing="0" cellpadding="0" border="0" align="right">
                                                                                                    <tr>
                                                                                                        <td style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 18px; font-weight: 400; line-height: 15px;">
                                                                                                            <a href="http://github.com" target="_blank" style="color: #ffffff; text-decoration: none;"><img src="http://www.pvhc.net/img207/jmvvtirrrkqqavzhvkpa.png" width="60" height="53" style="display: block; border: 0px;"/></a>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:100%;>
                                                            <tr>
                                                                <td align="center" style="padding: 15px 15px 10px 15px; background-color: #ffffff;" bgcolor="#ffffff">
                                                                    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:100%;">
                                                                        <tr>
                                                                            <td align="center" style="font-family: Helvetica, Arial, sans-serif; font-size: 18px; font-weight: 400; line-height: 10px; padding-top: 0px;">
                                                                                <br/><h2 style="font-size: 24px; font-weight: 600; line-height: 24px; color: #000000;">
                                                                                    Weekly Doc Status Summary of PRs
                                                                                </h2>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>`;

    return emailHtmlHeader;
}

@Description {value:"Html content of email detailed list header"}
public const string EMAIL_DETAILED_LIST_HEADER = string `<table>
                                                            <tr>
                                                                <td align="center" style="padding: 15px 15px 10px 15px; background-color: #ffffff;" bgcolor="#ffffff">
                                                                    <br/><h2 style="font-size: 24px; font-weight: 600; line-height: 24px; color: #000000;">
                                                                        Detailed List of Doc Status
                                                                    </h2>`;

@Description {value:"Html content of email footer"}
public const string EMAIL_HTML_FOOTER = string `</tr>
                                                      <tr>
                                                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:100%;">
                                                                <tr>
                                                                    <td align="center" valign="top" style="font-size:0;">
                                                                        <table align="center" border="0" cellspacing="0" cellpadding="0" width="600">
                                                                            <tr>
                                                                                <td align="center" valign="top" width="300">
                                                                                    <div style="display:inline-block; max-width:50%; min-width:240px; vertical-align:top; width:100%;">
                                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:100%;">
                                                                                            <tr>
                                                                                                <td align="center" valign="top" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 400; line-height: 24px;">
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:100%;">
                                                                <tr>
                                                                    <td align="center" style=" padding: 10px; background-color: #044767;" bgcolor="#1b9ba3">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="padding: 35px; background-color: #ffffff;" bgcolor="#ffffff">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:600px;">
                                                                            <tr>
                                                                                <td align="center">
                                                                                    <img src="https://upload.wikimedia.org/wikipedia/en/5/56/WSO2_Software_Logo.png" width="90" height="37" style="display: block; border: 0px;"/>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="center" style="font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 24px;">
                                                                                    <p style="font-size: 14px; font-weight: 400; line-height: 20px; color: #777777;">
                                                                                        Copyright (c) 2018 | WSO2 Inc.<br/>All Right Reserved.
                                                                                    </p>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                      </tr>
                                                    </table>
                                                </td>
                                                </tr>
                                            </table>
                                            </body>
                                        </html>`;

@Description {value:"Generate overall content of the PR documentation status email"}
@Param {value:"htmlTableContent: html content for pull request status detailed table "}
@Return {value:"String: Overall html content of the email"}
public function generateEmailContent (string htmlSummaryContent, string htmlTableContent, string currentDate) (string) {
    string emailHeader = generateEmailHeader(currentDate);
    return emailHeader + TABLE_HEADER_DOC_SUMMARY + htmlSummaryContent + EMAIL_DETAILED_LIST_HEADER + htmlTableContent +  EMAIL_HTML_FOOTER;
}
