# mpr-widget-backend

This is to generate an intermediate service which will act as the backend of the MPR-Summary dashboard widget. 

The widget will call the endpoints mentioned in this service and the service is responsible for invoking appropriate endpoints from the Ballerina service.

Add the Ballerina service url to <SP_HOME>/conf/dashboard/deployment.yaml following the sample in engineering-mgt/database/datasource-samples/**backend-services.yaml**

```
# RRM dashboards backend URLs
rrm.configs:
  mprBackendUrl: 'http://localhost:9090'
```

To build the widget-backend intermediate service run below command from 
engineering-mgt/mpr-summary-dashboard/widget/**widget-backend**
```
mvn clean install
```
Place the resulted target/mpr-backend-service.jar in <SP_HOME>/libs
