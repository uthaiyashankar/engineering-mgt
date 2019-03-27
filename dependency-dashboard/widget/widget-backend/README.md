# Dependency-dashboard-widget-backend

This is to generate an intermediate service which will act as the backend of the dependency-dashboard widget. 

The widget will call the endpoints mentioned in this service and the service is responsible for invoking appropriate endpoints from the Ballerina service.

Add the Ballerina service url to <SP_HOME>/conf/dashboard/deployment.yaml
```
# RRM dashboards backend URLs
rrm.configs:
  dependencyDashboardBackendUrl: 'http://localhost:9091'
```

To build the widget-backend intermediate service run below command from 
engineering-mgt/dependency-dashboard/widget/**widget-backend**
```
mvn clean install
```
Place the target/dependency-dashboard-backend-service-1.0.0.jar in <SP_HOME>/libs
