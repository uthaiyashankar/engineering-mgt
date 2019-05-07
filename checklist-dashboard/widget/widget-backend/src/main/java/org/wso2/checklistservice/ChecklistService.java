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

package org.wso2.checklistservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.msf4j.Microservice;
import org.wso2.msf4j.Request;

import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;

/**
 * This is an intermediate service that acts as the widget backend.
 */

public class ChecklistService implements Microservice {
    public static final String API_CONTEXT_PATH = "/apis/checklist";

    private static final Logger logger = LoggerFactory.getLogger(ChecklistService.class);
    private ChecklistServiceProvider checklistServiceProvider = new ChecklistServiceProvider();
    private static final Logger LOGGER = LoggerFactory.getLogger(ChecklistService.class);

    @GET
    @Path("/products")
    @Produces({"application/json"})
    public Response retrieveProducts(@Context Request request) {
        try {
            return okResponse(checklistServiceProvider.retrieveProducts());
        } catch (Throwable throwable) {
            logger.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/versions/{productName}")
    @Produces({"application/json"})
    public Response retrieveProductVersions(@Context Request request,
                                               @PathParam("productName") String productName) {

        try {
            return okResponse(checklistServiceProvider.retrieveVersions(productName));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/mprCount/{productName}")
    @Produces({"application/json"})
    public Response retrieveMprCount(@Context Request request,
                                     @PathParam("productName") String productName,
                                     @DefaultValue("") @QueryParam("version") String version) {

        try {
            return okResponse(checklistServiceProvider.retrieveMergedPRCount(productName, version));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/dependency/{productName}")
    @Produces({"application/json"})
    public Response retrieveDependencySummary(@Context Request request,
                                     @PathParam("productName") String productName) {

        try {
            return okResponse(checklistServiceProvider.retrieveDependencySummary(productName));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/codeCoverage/{productName}")
    @Produces({"application/json"})
    public Response retrieveCodeCoverage(@Context Request request,
                                     @PathParam("productName") String productName) {

        try {
            return okResponse(checklistServiceProvider.retrieveCodeCovSummary(productName));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/gitIssues/{productName}")
    @Produces({"application/json"})
    public Response retrieveGitIssueSummary(@Context Request request,
                                     @PathParam("productName") String productName,
                                     @DefaultValue("") @QueryParam("version") String version) {

        try {
            return okResponse(checklistServiceProvider.retrieveGitIssueSummaryCount(productName, version));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/jiraIssues/{productName}")
    @Produces({"application/json"})
    public Response retrieveJiraIssueSummary(@Context Request request,
                                     @PathParam("productName") String productName,
                                     @DefaultValue("") @QueryParam("version") String version,
                                     @DefaultValue("") @QueryParam("issueType") String issueType) {

        try {
            return okResponse(checklistServiceProvider.retrieveJiraIssueSummaryCount(productName, version, issueType));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }


    private static Response okResponse(Object content) {
        return Response.ok().entity(content).build();
    }

    private static Response serverErrorResponse(String message) {
        return Response.serverError().entity(message).build();
    }


}
