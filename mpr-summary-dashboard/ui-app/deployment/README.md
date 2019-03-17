# mpr-dashboard-deployment

This is to build a war file using the react build artifacts.

After a succeful build copy the engineering-mgt/mpr-summary-dashboard/ui-app/app/build directory content to engineering-mgt/mpr-summary-dashboard/ui-app/deployment/src/main/webapp directory. Use the existing WEB-INF directory.

Go to engineering-mgt/mpr-summary-dashboard/ui-app/deployment and issue the below command.

```
mvn clean install
```

The war file be created in engineering-mgt/mpr-summary-dashboard/ui-app/deployment/target directory. Copy the resulted mergedprs.war and place it in WSO2 Application Server. (Deployed and tested on [WSO2 AS 530](https://wso2.com/products/application-server/))
