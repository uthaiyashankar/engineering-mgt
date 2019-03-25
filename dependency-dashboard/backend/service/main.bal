import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/config;
listener http:Listener httpListener = new(config:getAsInt("HTTP_PORT"));

// RESTful service.
@http:ServiceConfig {
    basePath: "/dependency-data",
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false
    }
}
service orderMgt on httpListener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/all"
    }
    resource function findAllSummaryData(http:Caller caller, http:Request req) {
        json? payload = getSummeryData();
        http:Response response = new;
        if (payload == null) {
            payload = "Failed To get summery data data";
        }
        response.setJsonPayload(untaint payload);

        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/product-data/all"
    }
    resource function findAllProductData(http:Caller caller, http:Request req, string orderId) {
        json? payload = getProductDetails();
        http:Response response = new;
        if (payload == null) {
            payload = "Failed To get product data data";
        }

        response.setJsonPayload(untaint payload);

        // Send response to the client.
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }
}