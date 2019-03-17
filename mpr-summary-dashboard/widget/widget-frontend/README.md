# mpr-summary-widget 

To install the dependencies required to to build this widget, navigate to the engineering-mgt/mpr-summary-dashboard/widget/**widget-frontend** directory and issue the following command.
```
npm install
```

Go to the engineering-mgt/mpr-summary-dashboard/widget/**widget-frontend** directory and issue the following command to build the widget.
```
npm run build
```

Once the build is successful the final widget directory is created in the engineering-mgt/mpr-summary-dashboard/widget/**widget-frontend/dist** directory. Copy the engineering-mgt/mpr-summary-dashboard/widget/**widget-frontend/dist/MPRSummary** directory into the <SP_HOME>/wso2/dashboards/deployment/web-ui-apps/portal/extensions/widgets directory.

Restart WSO2 Stream Processor.
