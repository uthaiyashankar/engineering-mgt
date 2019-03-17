# code-coverage-chart-widget 

To install the dependencies required to to build this widget, navigate to the engineering-mgt/code-coverage-dashboard/widget/widget-frontend/**chart-widget** directory and issue the following command.
```
npm install
```

Then issue the following command to build the widget.
```
npm run build
```

Once the build is successful the final widget directory is created in the engineering-mgt/code-coverage-dashboard/widget/widget-frontend/**chart-widget/dist** directory. 

Copy the engineering-mgt/code-coverage-dashboard/widget/widget-frontend/**chart-widget/dist/CodeCoverage** directory into the <SP_HOME>/wso2/dashboards/deployment/web-ui-apps/portal/extensions/widgets directory.

Restart WSO2 Stream Processor.