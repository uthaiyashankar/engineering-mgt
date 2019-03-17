# Code Coverage Dashboard

This has 3 parts.

### Code coverage report generator script

This script run everyday periodically and creates aggregated jacoco code coverage report for WSO2 products and 
summary of the aggregated report will insert to the database. 

### Widget backend

This acts as the backend of the Code coverage dashboard widget.

The widget will call the endpoints mentioned in this service and the service is responsible for database operations.

### Widget frontend

These are React JS widgets. Dashboard has 2 frontend widgets.

- Chart widget: This shows how code coverage has changed in last 3 months for each team.
- Table Widget: This shows code coverage summary for a selected date and has links to last generated detailed report.