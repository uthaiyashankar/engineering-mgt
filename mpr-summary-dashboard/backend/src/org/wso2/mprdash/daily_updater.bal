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

//package src.org.wso2.github;

import ballerina.config;
import ballerina.io;
import ballerina.log;
import ballerina.time;
import src.org.wso2.mprdash.github;
import src.org.wso2.mprdash.appdata;
import ballerina.net.http;
import ballerina.collections;
import ballerina.runtime;

const int MAX_TIMEOUT = 5;


function loadConfig() {
    try {
        string apiURL = config:getGlobalValue("api.url");
        string apiToken = config:getGlobalValue("api.token");

        string dbName = config:getGlobalValue("db.name");
        string dbUser = config:getGlobalValue("db.user");
        string dbPassword = config:getGlobalValue("db.password");
        string dbHost = config:getGlobalValue("db.host");
        string dbPort = config:getGlobalValue("db.port");

        github:setAccessInfo(apiURL, apiToken);
        github:loadDbConfig(dbName, dbUser, dbPassword, dbHost, dbPort);
    } catch(error err) {
        log:printError(err.message);
    }
}

function insertRecords(collections:Vector records) {
    int i = 0;
    while(records!=null && i<records.size()) {
        var record,_ = (github:PullRequest)records.get(i);
        log:printDebug("Retrieved " + record.id + "doc status=" + record.milestone);
        i = i + 1;
    }
    github:insertPullRequests(records);
}


function runUpdate(string[] orgs,
                   string[] excludeProducts,
                   time:Time lastUpdateDate) {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient(github:apiURL, {});
    }

    http:OutRequest req = {};
    http:InResponse resp = {};

    foreach org in orgs {
        string[] repos = github:getReposInOrg(org);
        foreach repo in repos {
            try {
                var product = github:getProduct(repo);
                var excludeRepo = false;
                foreach exProduct in excludeProducts {
                    if(product==exProduct) {
                        excludeRepo = true;
                        break;
                    }
                }
                if(excludeRepo) {
                    next;
                }
                log:printInfo(repo+" ======>");


                string query = github:getPrQuery(org, repo, "");
                json jsonPayLoad = {query:query};

                int tries = 0;
                json result = null;

                while(tries < MAX_TIMEOUT) {
                    try {
                        req = {};
                        resp = {};
                        req.addHeader("Authorization", "Bearer " + github:apiTOKEN);
                        req.setJsonPayload(jsonPayLoad);
                        resp, _ = httpEndpoint.post("", req);
                        result = resp.getJsonPayload();
                        tries = tries + 1;
                    } catch (error e) {
                        log:printError("Try " + tries + ": " + e.message);
                    } catch(runtime:NullReferenceException e) {
                        log:printError("Try " + tries + ": " + e.message);
                    }
                }

                if (result==null || result["data"]["organization"]["repository"] == null) {
                    next;
                }


                while (result != null) {
                    var records,endReached = github:getRecordsInResponse(result, lastUpdateDate);
                    insertRecords(records);
                    if(endReached) {
                        break;
                    }

                    var hasNextPR, err = (boolean)result["data"]["organization"]["repository"]["pullRequests"]["pageInfo"]["hasNextPage"];
                    if (hasNextPR && err == null) {
                        var cursor_pr, _ = (string)result["data"]["organization"]["repository"]["pullRequests"]["pageInfo"]["endCursor"];
                        query = github:getPrQuery(org, repo, cursor_pr);
                        jsonPayLoad = {query:query};
                        result = null;
                        tries = 0;
                        while(tries < MAX_TIMEOUT) {
                            try {
                                req = {};
                                resp = {};
                                req.addHeader("Authorization", "Bearer " + github:apiTOKEN);
                                req.setJsonPayload(jsonPayLoad);
                                resp, _ = httpEndpoint.post("", req);
                                result = resp.getJsonPayload();
                                tries = tries + 1;
                            } catch (error e) {
                                log:printError("Try " + tries + ": " + e.message);
                            } catch(runtime:NullReferenceException e) {
                                log:printError("Try " + tries + ": " + e.message);
                            }
                        }
                    } else {
                        result = null;
                    }
                }


            } catch (error err) {
                log:printError(err.message);
            }
        }
    }
}

function main(string[] args) {
    loadConfig();
    string[] orgs = github:getOrgs();
    string[] excludeProducts = ["Unknown","Other"];
    time:Time lastUpdateDate = appdata:readUpdateDate();
    log:printInfo("################   Updating db   ################");
    log:printInfo("last update: " + lastUpdateDate.toString());

    runUpdate(orgs,excludeProducts,lastUpdateDate);

    lastUpdateDate = time:currentTime();
    appdata:writeUpdateDate(lastUpdateDate);

    log:printInfo("Updated up to " + lastUpdateDate.toString());
}