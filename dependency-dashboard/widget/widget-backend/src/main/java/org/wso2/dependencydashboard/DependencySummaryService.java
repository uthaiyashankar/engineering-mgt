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
