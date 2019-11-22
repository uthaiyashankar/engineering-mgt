// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/http;
import ballerina/log;
import ballerina/config;


http:Client gitClientEP = new ("https://api.github.com",
config = {
    followRedirects: {
        enabled: true,
        maxCount: 5
    }
});

string AUTH_KEY = config:getAsString("GITHUB_AUTH_KEY");

function fetchReposOfOrgFromGithub(Organization organization) returns json[]{
    //Create the request to send to github. Mainly the authentication key
    http:Request req = new;
    req.addHeader("Authorization", "token " + AUTH_KEY);

    int pageIterator = 0;
    json[] orgRepos = [];

    //Repeat until we get last page, which is empty response
    while (true) {
        pageIterator = pageIterator + 1;
        string reqURL = "/users/" + organization.orgName + "/repos?&page=" + pageIterator.toString() + "&per_page=100";
        http:Response|error retVal = gitClientEP->get(reqURL, message = req);
        http:Response response;
        
        //Check whether the response is valid
        if (retVal is error) {
            log:printError("Error when calling the github API : " + retVal.detail().toString(), err = retVal);
            log:printError("[Context] URL = [" + reqURL + "]");
            //Even though it is an error, we are continuing with calling remaining pages
            continue;
        } else {
            response = retVal;
        }

        //Check whether the status code is valid
        int statusCode = response.statusCode;
        if (statusCode != http:STATUS_OK && statusCode != http:STATUS_MOVED_PERMANENTLY){
            log:printError("Error when calling the github API. StatusCode for the request is " +
                statusCode.toString() + ". " + response.getJsonPayload().toString());
            log:printError("[Context] URL = [" + reqURL + "], StatusCode = [" + statusCode.toString() + "]");
            //Even though it is an error, we are continuing with calling remaining pages
            continue;
        }
        
        //Check whether the response contains json payload
        json|error respJson = response.getJsonPayload();
        if (respJson is error) {
            log:printError("Error when calling the github API. Response is not JSON", err = respJson);
            log:printError("[Context] URL = [" + reqURL + "]");
            //Even though it is an error, we are continuing with calling remaining pages
            continue;
        }
        
        //All checkes are validated. Process the repositories and store them
        json[] repoJson = <json[]>respJson;
        if (repoJson.length() == 0) {
            //No more repositories to fetch
            break;
        } else {
            // orgRepos.push(repoJson);
            mergeArrays(orgRepos, repoJson);
        }
    }
    
    return orgRepos;
}