# Merged PR Dashboard Backend

#### Initialization

- Create a database schema with the name "WSO2_PRODUCT_COMPONENT"
- Import dump structure and mandatory entries using the scripts in engineering-mgt/database/database-scripts.

#### Setting up backend

- Create proper keystore files (in .p12 format) 
 
- Follow the below sample and create **ballerina.conf** file and add it to engineering-mgt/mpr-summary-dashboard/backend

```
api.url=https://api.github.com/graphql
api.token=xxxxxxxxxxxxxxxxxxxxxxxxxxx

keystore.location=xxxxxxxxx
keystore.password=xxxxxxxxx

db.host=sample
db.port=3306
db.user=sample-user
db.password=xxxxxxxxxxxxxxx
db.name=WSO2_PRODUCT_COMPONENT

gmail.clientID=sample-id
gmail.clientSecret=xxxxxxxxxxxxxxxxxxxxxxxx
gmail.accessToken=xxxxxxxxxxxxxxxxxxxxxxxxxx
gmail.refreshToken=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

gmail.sender=test@test.com
gmail.receiver=test@test.com
gmail.orgs=test
gmail.cc=test@test.com
gmail.subject=Doc Status of PRs as at

auth.file=./auth.token
service.port=0000

update.file=./update.date

//Cron Expression of the schedule: Run every Tuesday at 10 am
timer.schedule=0 0 10 ? * TUE *
```

- Setup [ballerina 0.964](https://drive.google.com/drive/folders/1mafkQ1zc4ZuxsgWwAll7Svdxhy7q5UkP) runtime on a local folder
- Execute below from engineering-mgt/mpr-summary-dashboard/backend and save the generated token for future use.
```
  <Ballerina runtime>/bin/ballerina run src/org/wso2/setup/setup.bal
``` 


- From engineering-mgt/mpr-summary-dashboard/backend execute the following commands
```
  <Ballerina runtime>/bin/ballerina build src/org/wso2/mprdash/daily_updater.bal
  <Ballerina runtime>/bin/ballerina build src/org/wso2/mprdash/dashboard_services.bal
  <Ballerina runtime>/bin/ballerina build src/org/wso2/mprdash/pr_status_emailer.bal
```
This will create the balx files in engineering-mgt/mpr-summary-dashboard/backend

- Schedule daily_updater.balx to be executed once a day and pr_status_emailer.balx to be executed weekly.
- Start the dashboard_services.balx in the background by issuing below in engineering-mgt/mpr-summary-dashboard/backend
``` 
  <Ballerina runtime>/bin/ballerina run daily_updater.balx
```
- Now the Merged PR dashboard backend is ready to be used. 
