import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new(9091);

// Order management is done using an in-memory map.
// Add some sample orders to 'ordersMap' at startup.
map<json> ordersMap = {};

// RESTful service.
@http:ServiceConfig {
    basePath: "/dependency-data",
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false
    }
}
service orderMgt on httpListener {

    // Resource that handles the HTTP GET requests that are directed to a specific
    // order using path '/order/<orderId>'.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/all"
    }
    resource function findAllSummaryData(http:Caller caller, http:Request req) {
        // Find the requested order from the map and retrieve it in JSON format.
        json? payload = getSummeryData();
        http:Response response = new;
        if (payload == null) {
            payload = "Failed To get summery data data";
        }
        // Set the JSON payload in the outgoing response message.
        response.setJsonPayload(untaint payload);

        // Send response to the client.
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
        // Find the requested order from the map and retrieve it in JSON format.
        json? payload = getProductDetails();
        http:Response response = new;
        if (payload == null) {
            payload = "Failed To get product data data";
        }

        // Set the JSON payload in the outgoing response message.
        response.setJsonPayload(untaint payload);

        // Send response to the client.
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

}
