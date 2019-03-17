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

import ballerina.config;
import ballerina.net.http;
import ballerina.log;
import ballerina.util;
import ballerina.time;
import ballerina.runtime;
import ballerina.io;

@Description {value:"Validate the http response"}
@Param {value:"http:InResponse: The http response object"}
@Param {value:"validateComponent: component that need validation"}
@Return {value:"json: The JSON payload in the response"}
@Return {value:"GmailSendError: Error"}
function validateResponse (http:InResponse response, string validateComponent) (json, GmailSendError) {

    json responsePayload;
    GmailSendError gmailError;

    try {
        responsePayload = response.getJsonPayload();
        string[] payLoadKeys = responsePayload.getKeys();
        //Check all the keys in the payload to see if an error object is returned.
        foreach key in payLoadKeys {
            if (GMAIL_ERRORS.equalsIgnoreCase(key)) {
                var errorResponse, _ = (json)responsePayload[GMAIL_ERRORS];
                var errors, _ = (string)errorResponse[GMAIL_MESSAGE];

                gmailError = {msg:errors, statusCode:response.statusCode, reasonPhrase:response.reasonPhrase, server:response.server};
                return null, gmailError;
            }
        }
        //If no error object is returned, then check if the response contains the requested data.
        if (null == responsePayload[validateComponent]) {
            string errorMessage = GMAIL_ERROR_WHILE_RETRIEVING_DATA;
            responsePayload = null;
            gmailError = {msg:errorMessage, statusCode:response.statusCode, reasonPhrase:response.reasonPhrase, server:response.server};
        }
    } catch (error e) {
        string errorMessage = GMAIL_ERROR_WHILE_RETRIEVING_PAYLOAD;
        responsePayload = null;
        gmailError = {msg:errorMessage, statusCode:response.statusCode, reasonPhrase:response.reasonPhrase, server:response.server};
    }

    return responsePayload, gmailError;
}

@Description {value:"Construct the request headers"}
@Param {value:"request: The http request object"}
@Param {value:"stringRequestBody: Gmail API requst body"}
function constructAccessTokenRequest (http:OutRequest request, string stringRequestBody) {

    request.removeAllHeaders();
    request.setHeader("Content-Type", "application/x-www-form-urlencoded");
    request.setStringPayload(stringRequestBody);

}

@Description {value:"Construct the request headers"}
@Param {value:"request: The http request object"}
@Param {value:"accessToken: Gmail API access token"}
@Param {value:"jsonRequestBody: Gmail API request body"}
function constructSendMailRequest (http:OutRequest request, string accessToken, json jsonRequestBody) {

    request.removeAllHeaders();
    request.setHeader("Authorization", "Bearer " + accessToken);
    request.setHeader("Content-Type", "application/json");
    request.setJsonPayload(jsonRequestBody);

}

@Description {value:"Generate access token for gmail API"}
@Return {value:"string: Access token"}
@Return {value:"GmailSendError: Error"}
public function getGmailNewAccessToken () (string, GmailSendError) {

    endpoint<http:HttpClient> gmailClient {
        create http:HttpClient(GMAIL_API_ACCESS_TOKEN_URL, {});
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;
    GmailSendError gmailError;

    if (GMAIL_REFRESH_TOKEN == null || GMAIL_CLIENT_ID == null || GMAIL_CLIENT_SECRET == null) {
        gmailError = {msg:"Error at identifing tokens: Refresh token or Client Id or Client secret can not be null."};
        return null, gmailError;
    }

    string stringRequestBody = string `grant_type=refresh_token&client_id={{GMAIL_CLIENT_ID}}&client_secret={{GMAIL_CLIENT_SECRET}}&refresh_token={{GMAIL_REFRESH_TOKEN}}`;
    //construct headers for http request
    constructAccessTokenRequest(request, stringRequestBody);

    response, httpError = gmailClient.post("/token", request);

    if (httpError != null) {
        gmailError = {msg:"Http error at generating new access token: " + httpError.message, statusCode:httpError.statusCode};
        return null, gmailError;
    }

    json validatedResponse;
    validatedResponse, gmailError = validateResponse(response, GMAIL_API_ACCESS_TOKEN);
    if (gmailError != null) {
        return null, gmailError;
    }

    var newAccessToken, err = (string)validatedResponse[GMAIL_API_ACCESS_TOKEN];
    if (err != null) {
        gmailError = {msg:"Error at string conversion - Access Token json to Access Token string: " + err.message};
        return null, gmailError;
    }

    log:printInfo("New Gmail access token genereted.");
    //logFile:logInfo("New Gmail access token genereted.",runtime:getCallStack()[1].packageName);
    return newAccessToken, gmailError;
}

@Description {value:"Send email through gmail API."}
@Param {value:"accessToken: gmail API access token"}
@Param {value:"emailTo: email receiver address"}
@Param {value:"emailFrom: email sender address"}
@Param {value:"emailCc: email cc address"}
@Param {value:"emailSubject: email subject"}
@Param {value:"emailContent: email html content"}
@Return {value:"GmailSendError: Error"}
public function sendMail (string accessToken, string emailTo, string emailFrom, string emailCc, string emailSubject, string emailContent) (GmailSendError) {

    endpoint<http:HttpClient> gmailClient {
        create http:HttpClient(GMAIL_API_EMAIL_SEND_URL, {});
    }

    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError httpError;
    GmailSendError gmailError;

    if (accessToken == null) {
        gmailError = {msg:"Error at identifing access token: Access token is not found."};
        return gmailError;
    }

    if (emailTo == null || emailFrom == null) {
        gmailError = {msg:"Error at identifing email sender and receiver: sender email or receiver email can not be null."};
        return gmailError;
    }

    if (emailCc == null) {
        emailCc = "";
    }

    string stringRequestBody = string `to:{{emailTo}}\nsubject:{{emailSubject}}\nfrom:{{emailFrom}}\ncc:{{emailCc}}\ncontent-type:text/html;charset=iso-8859-1\n` + string `\n{{emailContent}}\n`;

    //encode email content using base64 encode method
    string encodedRequestBody = util:base64Encode(stringRequestBody);
    encodedRequestBody = encodedRequestBody.replace("+", "-");
    encodedRequestBody = encodedRequestBody.replace("/", "_");
    json jsonRequestBody = {"raw":encodedRequestBody};

    //construct headers for http request
    constructSendMailRequest(request, accessToken, jsonRequestBody);
    response, httpError = gmailClient.post("/v1/users/me/messages/send", request);

    if (httpError != null) {
        gmailError = {msg:httpError.message, statusCode:httpError.statusCode};
        return gmailError;
    }

    json validatedResponse;
    validatedResponse, gmailError = validateResponse(response, GMAIL_LABEL_IDS);
    if (gmailError != null) {
        return gmailError;
    }

    var emailStatus, err = (string)validatedResponse[GMAIL_LABEL_IDS][GMAIL_INDEX_ZERO];
    if (err != null) {
        gmailError = {msg:"Error at string conversion - Email status json to email status string: " + err.message};
        return gmailError;
    }

    if (GMAIL_SENT.equalsIgnoreCase(emailStatus)) {
        log:printInfo("Email sent successfully.");
        //logFile:logInfo("Email sent successfully.",runtime:getCallStack()[1].packageName);
        return gmailError;
    } else {
        log:printInfo("Email sent. Sent response from Gmail not found.");
        //logFile:logInfo("Email sent. Sent response from Gmail not found.",runtime:getCallStack()[1].packageName);
        return gmailError;
    }
}

@Description {value:"Send emails to notify PR issues"}
@Param {value:"emailDetails: Array of [emailAdress,prUrl]"}
public function notifyPrIssues(string[][] emailDetails) {
    var token, err = getGmailNewAccessToken();
    if (err != null) {
        log:printInfo(err.msg);
        return;
    }
    foreach emailDetail in emailDetails {
        err = sendMail(token, emailDetail[0],
                   EMAIL_SENDER, "",
                   EMAIL_PRIVATE_TITLE,
                   getBody(emailDetail[1]));
        if (err != null) {
            log:printInfo(err.msg);
        }
    }
}