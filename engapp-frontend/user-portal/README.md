# Git Issue Monitoring Dashboard - React Frontend
This dashboard contains the details of  WSO2 Git Issues. This dashboard includes four charts such as Issue count for team, Issue count by severity, Open VS closed chart and Issue aging graph.

### Issue count for team
This chart shows the number of open issues of WSO2 repos for WSO2 teams.

### Issue count by severity
This chart displays the number of issues for each team based on the severity labels such as Major, Critical, Blocker.

### Open VS closed chart
This graph shows the number of open issues vs closed issues for each day.

### Issue aging graph
This chart displays the number of open issues which are not closed until a specific period.

### Start the react App
First create a .env file in the root directory and add the following.

Sample .env file

```
REACT_APP_HOST=<host>
REACT_APP_PORT=<port-no>
```

To install the dependencies, issue the following command.
```
npm intsall
```

Now to start the react app, issue the following command.
```
npm start
```

###Deploying the dashboard using WSO2 Application Server

- To install the dependencies required to to build this widget and create war file navigate to the cloned directory directory and issue the following command.

```
mvn package
```


- navigate to <APPLICATION_SERVER_HOME>/bin and issue the following command

```
./wso2server.sh
```

- Log in to the management console and click Web Application under add in the navigator.
- Browse and select the war file you created and click upload.
- The .war file will be listed in the Running Applications page.
- You can view the dashboard by clicking 'Go To URL' under Actions.