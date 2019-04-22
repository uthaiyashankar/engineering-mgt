/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.dependencydashboard;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.msf4j.Microservice;
import org.wso2.msf4j.Request;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;

/**
 * This service will work as a interconnected.
 */

public class DependencySummaryService implements Microservice {

    public static final String API_CONTEXT_PATH = "/apis/dependency-data";

    private static final Logger LOGGER = LoggerFactory.getLogger(DependencySummaryService.class);
    private DependencySummaryProvider dependencySummaryProvider = new DependencySummaryProvider();

    @GET
    @Path("/all")
    @Produces({"application/json"})
    public Response retrieveSummary(@Context Request request) {

        LOGGER.info("products endpoint hits");
        try {
            return okResponse(dependencySummaryProvider.findAllSummaryData());
        } catch (Throwable throwable) {
            LOGGER.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/product-data/all")
    @Produces({"application/json"})
    public Response retrieveProducts(@Context Request request) {

        LOGGER.info("products endpoint hits");
        try {
            return okResponse(dependencySummaryProvider.findAllProductData());
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
