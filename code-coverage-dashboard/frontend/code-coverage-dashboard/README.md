# Code-Coverage-Dashboard

Create a file called .env in the root of your project, add the following

Sample .env file :

```
  REACT_APP_HOST=<host>
  REACT_APP_PORT=<port-no>
```

To install the dependencies required to to build this widget and create war file navigate to the cloned directory directory and issue the following command.

```
mvn package
```

To deploy the dashboard using WSO2 Application Server,

- navigate to <APPLICATION_SERVER_HOME>/bin and issue the following command

```
./wso2server.sh
```

- Log in to the management console and click Web Application under add in the navigator.
- Browse and select the war file you created and click upload.
- The .war file will be listed in the Running Applications page.
- You can view the dashboard by clicking 'Go To URL' under Actions.
