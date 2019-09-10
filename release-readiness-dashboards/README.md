# Release-Readiness-Dashboard

Create a file called .env in the root of your directory, add the following

Sample .env :

```
REACT_APP_checkList=<Checklist dashboard url>
REACT_APP_codeCoverage=<Code coverage dashboard url>
REACT_APP_MPRDas=<MPR dashboard url>
REACT_APP_gitIssues=<Git Issues dashboard url>
REACT_APP_dependencyDas=<Dependency ashboard url>

```

Provide the correct PUBLIC_URL in pom.xml

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
