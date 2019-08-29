

This will work as the frontend to the Git Issue Monitoring Dashboard which showcases the details of the issues in Git.



## Git Issue Monitoring Dashboard - React  Frontend


 First create a `.env` file in the root directory and assign the variable host name in REACT_APP_HOST and host port number in REACT_APP_PORT.<Br>
 eg:

    ```
    REACT_APP_HOST=<host>
    REACT_APP_PORT=<port-no>
    ```


After that to install the dependencies required  to build this widget and to create  a war file by navigating to the root directory  and issue the following command.<Br>

Provide the correct PUBLIC_URL in pom.xml

    mvn package

Then put the `.war` file into into the Application server in the web Applications which is takken from `target/`  directory .

Application server can be start by <Br>

 * First Downloading the WSO2 Application server from https://wso2.com/products/application-server/

 * Then go to `./bin` directory and type the following command inorder to start the server.
    
        ./wso2server.sh 

 * Log in to the management console and click Web Application under `add` in the navigator.

 * Browse and select the war file you created and click upload.

 * The war  file will be listed in the Running Applications page.

 * You can view the dashboard by clicking 'Go To URL' under Actions.