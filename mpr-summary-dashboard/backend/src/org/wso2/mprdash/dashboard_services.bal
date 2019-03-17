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
import ballerina.net.http;
import ballerina.auth.authz;
import ballerina.auth.basic;
import ballerina.io;
import ballerina.time;
import ballerina.collections;
import ballerina.config;
import src.org.wso2.mprdash.github;
import src.org.wso2.mprdash.appdata;
import ballerina.log;

boolean configLoaded = false;
const string keyStoreLocation = config:getGlobalValue("keystore.location");
const string keyStorePassword = config:getGlobalValue("keystore.password");
const string constAll = "all";

function loadConfig() {
    try {
        string dbName = config:getGlobalValue("db.name");
        string dbUser = config:getGlobalValue("db.user");
        string dbPassword = config:getGlobalValue("db.password");
        string dbHost = config:getGlobalValue("db.host");
        string dbPort = config:getGlobalValue("db.port");

        github:loadDbConfig(dbName, dbUser, dbPassword, dbHost, dbPort);
        configLoaded = true;
    } catch(error err) {
        log:printError(err.message);
    }
}

function authenticateReq(http:InRequest req)(boolean ) {
    string authHeader = req.getHeader("Authorization");
    if(authHeader==null) {
        return false;
    }
    string[] parts = authHeader.split(" ");
    if((lengthof parts)>1) {
        if(parts[0]=="Bearer" && appdata:validateToken(parts[1])) {
            return true;
        }
    }
    return false;
}

@http:configuration {
    basePath:"/",
    // port:9099
    httpsPort:9091,
    keyStoreFile:keyStoreLocation,
    keyStorePassword:keyStorePassword,
    certPassword:keyStorePassword
}

service<http> dashbaordService {

    @http:resourceConfig {
        methods:["GET"],
        path:"/products"
    }
    resource getProducts (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        json jsonPayload = {data:[], error:null};
        try {
            string[] products = github:getProducts();

            int i = 0;
            foreach product in products {
                jsonPayload["data"][i] = product;
                i = i + 1;
            }
        } catch (error err) {
            jsonPayload.error = err.message;
            log:printError(err.message);
        }
        res.setJsonPayload(jsonPayload);


        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type","application/json");
        _ = conn.respond(res);
    }


    @http:resourceConfig {
        methods:["GET"],
        path:"/versions"
    }
    resource getVersions (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        var qParams = req.getQueryParams();
        json jsonPayload = {data:[], error:null};
        try {
            var product,_ = (string)qParams["product"];
            string[] versions = github:getVersions(product);
            int i = 0;
            foreach ver in versions {
               jsonPayload["data"][i] = ver;
               i = i + 1;
            }
        } catch (error err) {
            jsonPayload["error"] = err.message;
            log:printError(err.message);
        }
        res.setJsonPayload(jsonPayload);
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type","application/json");
        _ = conn.respond(res);
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/prsbystatus"
    }
    resource getByDocStatus (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        var qParams = req.getQueryParams();
        json jsonPayload = {data:[], error:null};
        try {
            var product,_ = (string)qParams["product"];
            var ver,_ = (string)qParams["version"];
            var strStart,_ = (string)qParams["start"];
            time:Time start = time:parse(strStart,"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            var strEnd,_ = (string)qParams["end"];
            time:Time end = time:parse(strEnd,"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            var docStatus,_ = (string)qParams["status"];
            //github:RepoBranchRecord[] branches;
            github:ProductPrRecord[] prs;

            if (ver.toLowerCase() == constAll) {
                prs = github:getPullReqsForAllVersionsByStatus(product, start, end, docStatus);
            } else {
                prs = github:getPullReqsForVersionByStatus(product, ver, start, end, docStatus);
            }

            int i = 0;
            foreach pr in prs {
                var jsonPr,_ = <json>pr;
                jsonPayload["data"][i] = jsonPr;
                i = i + 1;
            }
        } catch (error err) {
            jsonPayload["error"] = err.message;
            log:printError(err.message);
        }
        res.setJsonPayload(jsonPayload);
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type","application/json");
        _ = conn.respond(res);

    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/prs"
    }
    resource getPullRequests (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        var qParams = req.getQueryParams();
        json jsonPayload = {data:[], error:null};
        try {
            var product,_ = (string)qParams["product"];
            var ver,_ = (string)qParams["version"];
            var strStart,_ = (string)qParams["start"];
            time:Time start = time:parse(strStart,"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            var strEnd,_ = (string)qParams["end"];
            time:Time end = time:parse(strEnd,"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            github:ProductPrRecord[] prs;

            if (ver.toLowerCase() == constAll) {
                prs = github:getPullReqsForAllVersions(product, start, end);
            } else {
                prs = github:getPullReqsForVersion(product, ver, start, end);
            }

            int i = 0;
            foreach pr in prs {
                var jsonPr,_ = <json>pr;
                jsonPayload["data"][i] = jsonPr;
                i = i + 1;
            }
        } catch (error err) {
            jsonPayload["error"] = err.message;
            log:printError(err.message);
        }
        res.setJsonPayload(jsonPayload);
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type","application/json");
        _ = conn.respond(res);
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/setdoc"
    }
    resource setDocState (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        try {
            json jsonPayload = req.getJsonPayload();
            github:updateState(jsonPayload["records"]);
            json response = {result : "DB updated!"};

            res.setJsonPayload(response);
        } catch(error err) {
            res.setStringPayload(err.message);
            log:printError(err.message);
        }
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type","application/json");
        res.addHeader("Accept","application/json");

        _=conn.respond(res);
    }


    @http:resourceConfig {
        methods:["GET"],
        path:"/setmilestone"
    }
    resource setMilestone (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        var qParams = req.getQueryParams();
        try {
            var name,_ = (string)qParams["name"];
            var product,_ = (string)qParams["product"];
            var ver,_ = (string)qParams["version"];
            var strStart,_ = (string)qParams["start"];
            time:Time start = time:parse(strStart,"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            var strEnd,_ = (string)qParams["end"];
            time:Time end = time:parse(strEnd,"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            if(github:insertMilestone(name, product, ver, start, end)) {
                 res.setStringPayload("success");
            } else {
                res.setStringPayload("Milestone already exists!.");
            }
        } catch (error err) {
            res.setStringPayload(err.message);
        }
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type","application/json");
        _ = conn.respond(res);
    }



    @http:resourceConfig {
        methods:["GET"],
        path:"/milestones"
    }
    resource getMilestones (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        var qParams = req.getQueryParams();
        json jsonPayload = {data:[], error:null};
        try {
            var product,_ = (string)qParams["product"];
            github:ProductMilestone[] milestones = github:getMilestones();
            int i = 0;
            foreach milestone in milestones {
                var jsonMilestone,_ = <json>milestone;
                jsonPayload["data"][i] = jsonMilestone;
                i = i + 1;
            }
        } catch (error err) {
            jsonPayload["error"] = err.message;
        }
        res.setJsonPayload(jsonPayload);
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE, PUT");
        res.addHeader("Content-Type","application/json");
        _ = conn.respond(res);
    }


    @http:resourceConfig {
        methods:["POST"],
        path:"/deletemilestone"
    }
    resource deleteMilestone (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if(!configLoaded) {
            loadConfig();
        }
        http:OutResponse res = {};
        try {
            json jsonPayload = req.getJsonPayload();
            io:println(jsonPayload["records"]);
            github:deleteMilestones(jsonPayload["records"]);
            res.setStringPayload("DB updated!");
        } catch(error err) {
            res.setStringPayload(err.message);
            log:printError(err.message);
        }
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE, PUT");
        res.addHeader("Content-Type","application/json");
        res.addHeader("Accept","application/json");
        _=conn.respond(res);
    }


    @http:resourceConfig {
        methods:["GET"],
        path:"/resetdate"
    }
    resource resetDate (http:Connection conn, http:InRequest req) {
        if(!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }

        http:OutResponse res = {};

        appdata:resetDate();

        res.setStringPayload("Date was reset to " + appdata:START_DATE.toString());
        res.addHeader("Access-Control-Allow-Origin","*");
        res.addHeader("Access-Control-Allow-Credentials","true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE, PUT");
        res.addHeader("Content-Type","application/json");
        _ = conn.respond(res);
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/prcount"
    }
    resource getPRCount (http:Connection conn, http:InRequest req) {
        if (!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if (!configLoaded) {
            loadConfig();
        }

        http:OutResponse res = {};
        var qParams = req.getQueryParams();
        json jsonPayload = {data:[], error:null};
        try {
            var product, _ = (string)qParams["product"];
            var ver, _ = (string)qParams["version"];
            github:PRCountRecord[] prCount = github:getPRCount(product, ver);

            int i = 0;
            foreach count in prCount {
                var jsonCount, _ = <json>count;
                jsonPayload["data"][i] = jsonCount;
                i = i + 1;
            }
        } catch (error err) {
            jsonPayload["error"] = err.message;
            log:printError(err.message);
        }
        res.setJsonPayload(jsonPayload);
        res.addHeader("Access-Control-Allow-Origin", "*");
        res.addHeader("Access-Control-Allow-Credentials", "true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type", "application/json");
        _ = conn.respond(res);
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/totalprcount"
    }
    resource getTotalPRCount (http:Connection conn, http:InRequest req) {
        if (!authenticateReq(req)) {
            http:OutResponse res = {statusCode:401, reasonPhrase:"Unauthenticated"};
            _ = conn.respond(res);
            return;
        }
        if (!configLoaded) {
            loadConfig();
        }

        http:OutResponse res = {};
        var qParams = req.getQueryParams();
        json jsonPayload = {data:[], error:null};
        try {
            var product, _ = (string)qParams["product"];
            var ver, _ = (string)qParams["version"];
            github:TotPRCountRecord prCount = github:getTotalPRCount(product, ver);
            jsonPayload["data"],_ = <json>prCount;
        } catch (error err) {
            jsonPayload["error"] = err.message;
            log:printError(err.message);
        }
        res.setJsonPayload(jsonPayload);
        res.addHeader("Access-Control-Allow-Origin", "*");
        res.addHeader("Access-Control-Allow-Credentials", "true");
        res.addHeader("Access-Control-Allow-Methods", "POST, GET");
        res.addHeader("Content-Type", "application/json");
        _ = conn.respond(res);
    }
}
