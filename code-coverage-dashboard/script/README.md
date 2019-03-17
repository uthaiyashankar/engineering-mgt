# code-coverage-dashboard script

"ccReportGenerator.sh" file will create aggregated jacoco code coverage report for WSO2 products and summary of the aggregated report will insert to the database.

Create a new folder "code-coverage-generator" inside "/apache-tomcat/webapps/ROOT" folder and place "ccReportGenerator.sh" and "pom.xml" files. 

before run "ccReportGenerator.sh" file, 

run below commands and create the files and directories needed.
```
mkdir code_coverage_reports

mkdir old_coverage_reports

touch full_log.txt

touch code_coverage_log.txt
```
Open "ccReportGenerator.sh" and add below properties
```
#=============== Properties ==============================================================
DB_USER=root                          # User of the code coverage summary DB
DB_PASS=root                          # Password of the DB user
HOST=xxx.xxx.xxx.xxx                  # DB host
PORT=3306                             # DB port number
DATABASE=SUM_DB                       # DB name
HOME=/path/to/code-coverage-report    # path to code-coverage-report folder in the server
```
Then you need to add a cron job to run this "ccReportGenerator.sh" file everyday.

First, execute below command to open crontab file.

```
crontab -e
```
Add below entry to the opened file.
(This will run the "ccReportGenerator.sh" everyday at 12.11 am)

```
# run code coverage generator script everyday at 12.11 am
11 0 * * * /full/path/to/tom-cat/webapps/ROOT/code-coverage-generator/ccReportGenerator.sh
```
Save and exist. Then you can see "installing crontab" as terminal output, It says cronjob has set.
