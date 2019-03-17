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

package org.wso2.mprservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.msf4j.Microservice;
import org.wso2.msf4j.Request;

import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;

/**
 * This is an intermediate service that acts as the widget backend.
 */

public class MPRService implements Microservice {
    public static final String API_CONTEXT_PATH = "/apis/mprSummary";

    private static final Logger logger = LoggerFactory.getLogger(MPRService.class);
    private MPRServiceProvider mprServiceProvider = new MPRServiceProvider();

    @GET
    @Path("/products")
    @Produces({"application/json"})
    public Response retrieveProducts(@Context Request request) {
        try {
            return okResponse(mprServiceProvider.retrieveProducts());
        } catch (Throwable throwable) {
            logger.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/versions")
    @Produces({"application/json"})
    public Response retrieveAllIssuesByProduct(@Context Request request,
                                               @DefaultValue("") @QueryParam("product") String product) {

        try {
            return okResponse(mprServiceProvider.retrieveVersions(product));
        } catch (Throwable throwable) {
            logger.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }

    @GET
    @Path("/prcount")
    @Produces({"application/json"})
    public Response retrievePRCountbyStatus(@Context Request request,
                                            @DefaultValue("") @QueryParam("product") String product,
                                            @DefaultValue("") @QueryParam("version") String version) {

        try {
            return okResponse(mprServiceProvider.retrievePRCountbyStatus(product, version));
        } catch (Throwable throwable) {
            logger.error("Error occurred while " + throwable.getMessage(), throwable);
            return serverErrorResponse("Error occurred while retreving the response from server");
        }
    }


    @GET
    @Path("/totalprcount")
    @Produces({"application/json"})
    public Response retrieveTotalPRCount(@Context Request request,
                                         @DefaultValue("") @QueryParam("product") String product,
                                         @DefaultValue("") @QueryParam("version") String version) {

        try {
            return okResponse(mprServiceProvider.retrieveTotalPRCount(product, version));
        } catch (Throwable throwable) {
            logger.error("Error occurred while " + throwable.getMessage(), throwable);
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
