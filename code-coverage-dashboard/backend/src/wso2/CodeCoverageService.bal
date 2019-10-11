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

import ballerina/io;
import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/mysql;
import ballerina/sql;

listener http:Listener httpListener = new(8888);

@http:ServiceConfig {
    basePath: "/code_coverage",
    cors: {
        allowOrigins: ["*"]
    }
}

service CodeCoverageData on httpListener {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/summary"
    }
    resource function getCoverageSummary(http:Caller httpCaller, http:Request request) {
        // Initialize an empty http response message
        http:Response response = new;
        // Invoke retrieveData function to retrieve data from mysql database
        json codeCoverageData = retrieveCoverageSummary();
        // Send the response back to the client with the code coverage data
        response.setPayload(untaint codeCoverageData);
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client", err = respondRet);
        }
     }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/summary/{date}"
    }
    resource function getCoverageSummaryByDate(http:Caller httpCaller, http:Request request, string date ) {
        // Initialize an empty http response message
        http:Response response = new;
        // Invoke retrieveData function to retrieve data from mysql database
        json codeCoverageDataByDate = retrieveCoverageSummaryByDate(untaint date);
        // Send the response back to the client with the code coverage data
        response.setPayload(untaint codeCoverageDataByDate);
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client", err = respondRet);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/last-report-date"
    }
    resource function getLastReportDate(http:Caller httpCaller, http:Request request ) {
        // Initialize an empty http response message
        http:Response response = new;
        // Invoke retrieveData function to retrieve data from mysql database
        json last_coverage_report = retrieveLastReportDate();
        // Send the response back to the client with the code coverage data
        response.setPayload(untaint last_coverage_report);
        var respondRet = httpCaller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            log:printError("Error responding to the client", err = respondRet);
        }
    }
}
