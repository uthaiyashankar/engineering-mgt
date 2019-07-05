Git Issue Monitoring Dashboard - Ballerina backend

This will work as the backend to the Git issue Monitoring Dashboard which communicate with the github rest endpoint inorder to retrieve the issues.

- Add ballerina.conf to engineering-mgt/git-issues-monitoring-dashboard/backend/backend 

  Sample ballerina.conf :
```
  DB_HOST = "localhost"
  DB_PORT = "3306"
  DB_NAME = "WSO2_PRODUCT_COMPONENT"
  UNAME = "root"
  PASS = "root"
  
  TRIGGER_AUTH_KEY = "xxxxxxxxxxxxxxxxx"
  GENERAL_AUTH_KEY = "xxxxxxxxxxxxxxxxx"
```

- Navigate to engineering-mgt/git-issues-monitoring-dashboard/backend/backend/src and run `ballerina build wso2` then `ballerina run -c ../ballerina.conf target/wso2.balx` inorder to start the ballerina service