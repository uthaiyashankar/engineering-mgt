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

package org.wso2.git.issue.service;

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
 * This service will work as a interconnected
 */

public class GitIssueService implements Microservice {
    public static final String API_CONTEXT_PATH = "/apis/gitIssues";

    private static final Logger LOGGER = LoggerFactory.getLogger(GitIssueService.class);
    private GitServiceProvider gitServiceProvider = new GitServiceProvider();

    @GET
    @Path("/")
    @Produces({"application/json"})
    public Response retrieveAllIssuesByRepoNames(@Context Request request,
                                                 @DefaultValue("") @QueryParam("labels") String labels,
                                                 @DefaultValue("") @QueryParam("repos") String repos) {

        try {
            return okResponse(gitServiceProvider.retrieveIssuesFromRepoByLabel(labels, repos));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/product/{productName}")
    @Produces({"application/json"})
    public Response retrieveAllIssuesByProduct(@Context Request request,
                                               @PathParam("productName") String productName,
                                               @DefaultValue("") @QueryParam("labels") String labels) {

        try {
            return okResponse(gitServiceProvider.retrieveIssuesFromProduct(productName, labels));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/repos/{productName}")
    @Produces({"application/json"})
    public Response retrieveReposByProduct(@Context Request request,
                                           @PathParam("productName") String productName) {

        try {
            return okResponse(gitServiceProvider.retrieveRepoNamesByProduct(productName));
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/products/")
    @Produces({"application/json"})
    public Response retrieveReposByProduct(@Context Request request) {

        try {
            return okResponse(gitServiceProvider.retrieveProductNames());
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
