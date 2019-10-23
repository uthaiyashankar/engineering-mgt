import ballerina/time;

string UPDATED_TIME = time:toString(time:currentTime());
string UPDATED_DATE = UPDATED_TIME.substring(0,10);

// Sql Queries
string RETRIEVE_TEAMS = "SELECT * FROM ENGAPP_GITHUB_TEAMS";
string RETRIEVE_REPOS = "SELECT * FROM ENGAPP_GITHUB_REPOSITORIES WHERE TEAM_ID=?";
string RETRIEVE_ISSUES = "SELECT CAST(UPDATED_DATE AS DATE) AS UPDATED_DATE, CREATED_BY, HTML_URL, DATEDIFF(CURDATE(),
        CAST(CREATED_DATE AS DATE)) AS OPEN_DAYS ,LABELS FROM ENGAPP_GITHUB_ISSUES WHERE REPOSITORY_ID=? AND
        ISSUE_TYPE=\"PR\" AND CLOSED_DATE IS NULL";

//Fire at 12:01am every wednesday
string CRON_EXPRESSION = "0 01 12 3 WED";
