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

import ballerina.io;
import ballerina.config;
import ballerina.time;
import ballerina.log;
import ballerina.runtime;
import ballerina.data.sql;
import src.org.wso2.mprdash.github.email;
import ballerina.task;
import ballerina.math;

//Get email configurations from configuration file
public const string EMAIL_SENDER = config:getGlobalValue("gmail.sender");
public const string EMAIL_RECEIVER = config:getGlobalValue("gmail.receiver");
public const string EMAIL_CC = config:getGlobalValue("gmail.cc");
public string emailTitle = config:getGlobalValue("gmail.subject");

//Get db configurations from configuration file
public const string DB_HOST = config:getGlobalValue("db.host");
public const string DB_NAME = config:getGlobalValue("db.name");
public const string DB_USER_NAME = config:getGlobalValue("db.user");
public const string DB_PASSWORD = config:getGlobalValue("db.password");
public const int DB_PORT = getDatabasePort();
public const string DB_URL = string `jdbc:mysql://{{DB_HOST}}:{{DB_PORT}}/{{DB_NAME}}?verifyServerCertificate=false&useSSL=true&requireSSL=true`;

//Get Cron Expression of schedule from configuration file
public string schedule = config:getGlobalValue("timer.schedule");

//Sql query to get a list of PRs according to the doc status within last 15 days
public const string QUERY_PR_LIST = string `SELECT p.PRODUCT_NAME, pr.MILESTONE, repo.REPO_NAME,
                                            pr.PR_AUTHOR, pr.PR_TITLE, pr.PR_URL,
                                            DATEDIFF(CURDATE(), pr.MERGED_DATE) as DURATION
                                            FROM PRODUCT_PRS pr, PRODUCT_REPOS repo, PRODUCT p
                                            WHERE pr.DOC_STATUS=? and pr.REPO_ID=repo.REPO_ID and
                                            p.PRODUCT_ID=pr.PRODUCT_ID
                                            ORDER BY p.PRODUCT_NAME, pr.MILESTONE,
                                            DATEDIFF(CURDATE(), pr.MERGED_DATE), repo.REPO_NAME desc`;

public const string QUERY_DOC_STATUS_SUMMARY = string `select
                          (select COUNT(PR_URL) from PRODUCT_PRS where DOC_STATUS=? and DATEDIFF(CURDATE(),
                          MERGED_DATE)<15) as 'PR_IN_TWOWEEKS',
                          COUNT(PR_URL) as 'TOTAL_PR'
                          from PRODUCT_PRS
                          where DOC_STATUS=?`;

//Get Current Date Time
public time:Time time = time:currentTime();

@Description {value:"Main Method: Schedule a timer to send the email on every Week"}
public function main (string[] args) {

    //Validate provided DB, Email and Schedule configurations before start the timer.
    validateConfigurationParameters();

    //Get Current Time
    var hr, min, sec, milisec = time.getTime();
    string strHr = <string>hr;
    string strMin = <string>min;
    string strSec = <string>sec;
    string strMiliSec = <string>milisec;
    string scheduleStartedTime = string `{{strHr}}:{{strMin}}:{{strSec}}:{{strMiliSec}}`;

    log:printInfo("Scheduler Started at : " + scheduleStartedTime);

    function() returns (error) onTriggerFunction = appointmentEmailer;
    function(error e) onErrorFunction = logSchedulerError;

    var taskId, err = task:scheduleAppointment(onTriggerFunction, onErrorFunction, schedule);

    if (err != null) {
        log:printErrorCause("Error while schedule the emailer : ", err);
    } else {
        log:printDebug("Appointment Id : " + taskId);
    }
}

@Description {value: "Generate the email and send the email to recipient"}
function appointmentEmailer () returns (error) {

    log:printInfo("Generate PR Documentation Status Emailer");

    string tableContent;
    string summaryContent;
    string accessToken;
    email:GmailSendError emailError;
    error prEmailerError;

    //Get Today date
    var year, month, day = time.getDate();
    string strYear = <string>year;
    string strMonth = <string>month;
    string strDay = <string>day;
    string date = string `{{strDay}}-{{strMonth}}-{{strYear}}`;

    string emailSubject = string `{{emailTitle}} : {{date}}`;

    summaryContent, emailError = generateDocStatusSummaryTable();
    if (emailError != null) {
        log:printError("Error in generating email content with the summary of doc status : " + emailError.msg);
        return emailError.cause;
    }

    tableContent, emailError = generateDocStatusTable();
    if (emailError != null) {
        log:printError("Error in generating email content with the list of PRs : " + emailError.msg);
        return emailError.cause;
    }

    string emailContent = email:generateEmailContent(summaryContent, tableContent, date);
    var token, err = email:getGmailNewAccessToken();
    if (err != null) {
        log:printError("Error in getting a new access token : " + err.msg);
        prEmailerError = err.cause;
    } else {
        err = email:sendMail(token, EMAIL_RECEIVER, EMAIL_SENDER, EMAIL_CC, emailSubject, emailContent);

        if (err != null) {
            log:printError("Error in sending the email : " + err.msg);
            prEmailerError = err.cause;
        }
    }
    return prEmailerError;
}

@Description {value:"Generate doc status summary table"}
@Return {value:"string: Email doc status summary Content"}
@Return {value:"GmailSendError: Error"}
public function generateDocStatusSummaryTable () (string , email:GmailSendError) {
    endpoint<sql:ClientConnector> sqlClient {
        create sql:ClientConnector(
        sql:DB.MYSQL, DB_HOST, DB_PORT, DB_NAME, DB_USER_NAME, DB_PASSWORD,{maximumPoolSize:5, url:DB_URL});
    }

    string summaryTableContent = "";

    //List of Document Statuses
    string[][] docStatus = [["4","Issues Pending"], ["2","No Draft"], ["1","Draft Received"], ["3","In-progress"], ["0","Not Started"]];

    email:GmailSendError gmailError;

    foreach status in docStatus {
        table docStatusSummaryTable;
        email:DocStatusSummary[] docStatusSummaryArr = [];
        string docStatusId = status[0];
        string docStatusDescription = status[1];

        sql:Parameter param = {sqlType:sql:Type.INTEGER, value:docStatusId};
        sql:Parameter[] params = [param, param];

        try {
            docStatusSummaryTable = sqlClient.select(QUERY_DOC_STATUS_SUMMARY, params, typeof email:DocStatusSummary);
        } catch (error errDatabase) {
            gmailError = {msg:"Error at selecting PR doc status summary data from database table - sql client connector: " + errDatabase.message};
            sqlClient.close();
            return null, gmailError;
        }

        int i = 0;
        while(docStatusSummaryTable.hasNext()) {
            var prSummary, err = (email:DocStatusSummary)docStatusSummaryTable.getNext();

            if(err != null) {
                gmailError = {msg:"Error at PR Doc status summary row struct conversion from docStatusSummaryTable to DocStatusSummary: " + err.message};
                sqlClient.close();
                return null, gmailError;
            }
            docStatusSummaryArr[i] = prSummary;
            i = i + 1;
        }
        if ((lengthof docStatusSummaryArr) != 0) {
            summaryTableContent = summaryTableContent + email:generateHtmlSummaryContent(docStatusSummaryArr, docStatusDescription);
        }
    }
    sqlClient.close();
    return summaryTableContent, gmailError;
}

@Description {value:"Retrieve Data from DB and generate the table"}
@Return {value:"string: Email PR Table Content"}
@Return {value:"GmailSendError: Error"}
public function generateDocStatusTable () (string , email:GmailSendError) {
    endpoint<sql:ClientConnector> sqlClient {
        create sql:ClientConnector(
        sql:DB.MYSQL, DB_HOST, DB_PORT, DB_NAME, DB_USER_NAME, DB_PASSWORD,{maximumPoolSize:5, url:DB_URL});
    }

    string tableContent = "";

    //List of Document Statuses
    string[][] docStatus = [["4","Issues Pending"], ["2","No Draft"], ["1","Draft Received"], ["3","In-progress"]];

    email:GmailSendError gmailError;

    foreach status in docStatus {
        table docStatusDetailsTable;
        email:PrDocStatusDetails[] docStatusArr = [];
        string docStatusId = status[0];
        string docStatusDescription = status[1];

        sql:Parameter[] params = [{sqlType:sql:Type.INTEGER, value:docStatusId}];

        try {
            docStatusDetailsTable = sqlClient.select(QUERY_PR_LIST, params, typeof email:PrDocStatusDetails);
        } catch (error errDatabase) {
            gmailError = {msg:"Error at selecting PR doc status data from database table - sql client connector: " + errDatabase.message};
            sqlClient.close();
            return null, gmailError;
        }

        int i = 0;
        while(docStatusDetailsTable.hasNext()) {
            var prData, err = (email:PrDocStatusDetails)docStatusDetailsTable.getNext();

            if(err != null) {
                gmailError = {msg:"Error at PR Doc status row struct conversion from docStatusDetailsTable to PrDocStatusDetails: " + err.message};
                sqlClient.close();
                return null, gmailError;
            }
            docStatusArr[i] = prData;
            i = i + 1;
        }
        if ((lengthof docStatusArr) != 0) {
            tableContent = tableContent + email:generateHtmlTableContent(docStatusArr, docStatusDescription);
        }
    }
    sqlClient.close();
    return tableContent, gmailError;
}

@Description {value:"onErrorFunction Fuction: Handle the error in onTriggerFunction function."}
@Param {value:"Error returned by onTriggerFunction function"}
function logSchedulerError (error e) {
    log:printErrorCause("Email Scheduler failed ", e);
}

@Description {value:"Get database port from configuration file"}
function getDatabasePort () (int) {
    string dbPort = config:getGlobalValue("db.port");
    var intDbPort, err = <int>dbPort;

    if (err != null) {
        log:printError("Error in converting string DB port value into integer.");
        throw err;
    }
    return intDbPort;
}

@Description {value:"Validate DB/Email/Schedule Configuration Parameters"}
function validateConfigurationParameters () {
    if (EMAIL_SENDER != null && EMAIL_RECEIVER != null) {
        if (DB_HOST != null && DB_URL != null && DB_NAME != null && DB_PASSWORD != null && DB_USER_NAME != null) {
            if (schedule != null) {
               log:printInfo("DB, Email and Schedule Configurations are provided successfully.");
            }
        } else {
            error err = {message:"Mandatory DB Configuration details should not be Null."};
            throw err;
        }
    } else {
        error err = {message:"Mandatory Email Configuration details should not be Null."};
        throw err;
    }
}
