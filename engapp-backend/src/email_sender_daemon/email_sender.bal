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
import ballerina/log;
import wso2/gmail;
import ballerina/time;
import ballerina/io;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: config:getAsString("GMAIL_ACCESS_TOKEN"),
        refreshConfig: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: config:getAsString("GMAIL_REFRESH_TOKEN"),
            clientId: config:getAsString("GMAIL_CLIENT_ID"),
            clientSecret: config:getAsString("GMAIL_CLIENT_SECRET")
        }
    }
};

gmail:Client gmailClient = new (gmailConfig);

public function sendPREmail() {
    string updatedDate = time:toString(time:currentTime()).substring(0, 10);
    string mailSubject = "[Open PR] Open Pull Requests: " + updatedDate;
    
    string htmlHeader = getHtmlHeaderAndStyles("Open PR Details", "GitHub Open Pull Request Analyzer");
    string summaryTableheader = getSummaryTableHeader("Summary", "Team Name", "No of Open PRs");
    string tableContent = generateOpenPRTable();
    string dateContent = generateDateContent(updatedDate);
    string mailContent = htmlHeader + summaryTableheader + tableContent + dateContent + templateFooter + htmlFooter;

    sendEmail(mailSubject, mailContent);
}

public function sendIssueEmail() {
    string updatedDate = time:toString(time:currentTime()).substring(0, 10);
    string mailSubject = "[Open Issues] Open Issue Details: " + updatedDate;
    
    string htmlHeader = getHtmlHeaderAndStyles("Open Issue Details", "GitHub Open Issue Analyzer");
    string summaryTableheader = getSummaryTableHeader("Summary", "Team Name", "No of Open Issues");
    string tableContent = generateOpenIssueTable();
    string dateContent = generateDateContent(updatedDate);
    string mailContent = htmlHeader + summaryTableheader + tableContent + dateContent + templateFooter + htmlFooter;

    sendEmail(mailSubject, mailContent);
}

public function sendEmail (string mailSubject, string mailContent) {
    string userId = "me"; //Special string for the currently authenticated user

    //=========================
    //Only for debug purposes
    //=========================
    io:println("");
    log:printInfo("");
    // io:println(mailContent);
    // return;

    gmail:MessageRequest messageRequest = {
        recipient: config:getAsString("GMAIL_RECIPIENT"),
        sender: config:getAsString("GMAIL_SENDER"),
        cc: config:getAsString("GMAIL_CC"),
        subject: mailSubject,
        messageBody: mailContent,
        contentType: gmail:TEXT_HTML
    };

    var sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);
    if (sendMessageResponse is [string, string]) {
        // If successful, print the message ID and thread ID.
        [string, string][messageId, threadId] = sendMessageResponse;
        log:printInfo("Sent Message ID: " + messageId);
        log:printInfo("Sent Thread ID: " + threadId);
    } else {
        // If unsuccessful, print the error returned.
        log:printError("Error in sending email ", err = sendMessageResponse);
    }
}
