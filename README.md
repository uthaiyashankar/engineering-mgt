# engineering-mgt

This repo contains WSO2 Release Readiness Metrics Dashboards. 

### Code Coverage Dashboard

This dashboard shows the code coverage of WSO2 repos for WSO2 teams.
It shows instruction, branch, complexity, line, method and class
coverage for each team.
Dashboard will show code coverage summary for each day in a table and
links are provided for detailed coverage report for each team. And also
it shows how code coverage has changed in last 3 months in a line chart.

### Dependency Dashboard

### GIT Issue Monitoring Dashboard

This dashboard consists with 2 widgets.

*Issue Count By Product*

This widget shows the L1 issue count(issues with Severity/Blocker label) L2 issue count (issues with Severity/Critical label) and L3 issue count (issues with Severity/Major label) by product.

*Issue View Widget*

This widget is consists with a table where you can search git issues by product, repos and labels.  

### Merged PR Summary Dashboard

This contains both Merged PR dashboard and Merged PR Summary dashboard.

*Merged PR dashboard*

This is a dashboard where the documentation team can view and manage merged pull requests. The PRs can be filtered by product, version, merged date range and documentation task status (Not Started,Draft Received,No Draft,In-progress,Issues Pending,Completed,No Impact). Only the doc team members have the privileges to change these doc task status.

This dashboard is also responsible for notifying a summary of doc status of merged PRs on weekly basis.

*Merged PR Summary dashboard*

This is a summary of the Merged PR dashboard dashboard, which will display summary information about merged PRs in ech product & version.
