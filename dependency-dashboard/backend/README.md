#Dependency Dashboard - Ballerina backend

This contains ballerina backend service to the Dependency Dashboard which communicate with the database
using rest endpoint. This will also contain a ballerina function which will be called by a linux cron
periodically to update the database with latest dependency summary data. 


Provide the required configurations to ballerina.conf
 
 * **To run the service**
 
 1. `ballerina build service`
 2. `ballerina run -c ballerina.conf target/service.balx`
 
 * **To configure the cron**
 
 1. `ballerina build update_database`
 2.  Navigate to /engineering-mgt/dependency-dashboard/scripts and configure the `insert-to-database.sh` script to run
periodically using a linux cron. Edit the script file with the location of`ballerina.conf` and
`update_database.balx` files.
 3. Run `./insert-to-database.sh`