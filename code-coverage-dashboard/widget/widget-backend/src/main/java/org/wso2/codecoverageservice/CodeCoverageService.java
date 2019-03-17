/*
 * Copyright (c) 2019, WSO2 Inc. (http://wso2.com) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.wso2.codecoverageservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.msf4j.Microservice;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

/**
 * This service will work as a interconnected.
 */
public class CodeCoverageService implements Microservice {
    static final String API_CONTEXT_PATH = "/apis/coverage";
    private static final Logger LOGGER = LoggerFactory.getLogger(CodeCoverageService.class);
    private CoverageServiceProvider coverageServiceProvider = new CoverageServiceProvider();

    @GET
    @Path("/summary")
    public Response getCoverageSummary() {
        try {
            return Response.ok(coverageServiceProvider.getCoverageSummary(), MediaType.TEXT_PLAIN)
                    .header("Access-Control-Allow-Credentials", true)
                    .build();
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retrieving coverage summary from server");
        }
    }

    @GET
    @Path("/table-summary/{date}")
    public Response getTableSummaryForDate(@PathParam("date") String date) {
        try {
            return Response.ok(coverageServiceProvider.getTableSummaryByDate(date), MediaType.TEXT_PLAIN)
                    .header("Access-Control-Allow-Credentials", true)
                    .build();
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse
                    ("Error occurred while retrieving the table summary for given date from server");
        }
    }

    @GET
    @Path("/last-report-date")
    public Response getLastReportDate() {
        try {
            return Response.ok(coverageServiceProvider.getLastReportDate(), MediaType.TEXT_PLAIN)
                    .header("Access-Control-Allow-Credentials", true)
                    .build();
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retrieving the last report date from server");
        }
    }

    private static Response serverErrorResponse(String message) {
        return Response.serverError().entity(message).build();
    }
}
