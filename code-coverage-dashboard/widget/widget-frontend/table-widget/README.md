# code-coverage-table-widget 

First, open engineering-mgt/code-coverage-dashboard/widget/widget-frontend/**table-widget/src/resources/widgetConf.json** file and add server path where code coverage reports are hosted as given below.

```
{
  "name": "CodeCoverageTable",
  "id": "CodeCoverageTable",
  "thumbnailURL": "",
  "configs": {
    "providerConfig": {
      "configs": {
        "reports_server_path": "<SET_SERVER_PATH_HERE>"
      }
    }
  }
}
```

To install the dependencies required to to build this widget, navigate to the engineering-mgt/code-coverage-dashboard/widget/widget-frontend/**table-widget** directory and issue the following command.
```
npm install
```

Then issue the following command to build the widget.
```
npm run build
```

Once the build is successful the final widget directory is created in the engineering-mgt/code-coverage-dashboard/widget/widget-frontend/**table-widget/dist** directory. 

Copy the engineering-mgt/code-coverage-dashboard/widget/widget-frontend/**table-widget/dist/CodeCoverageTable** directory into the <SP_HOME>/wso2/dashboards/deployment/web-ui-apps/portal/extensions/widgets directory.

Restart WSO2 Stream Processor.