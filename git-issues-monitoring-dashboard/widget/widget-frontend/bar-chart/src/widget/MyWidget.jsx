/*
 *  Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 *
 */

/* eslint-disable react/prop-types, react/jsx-handler-names */

import React from "react";

 import FormControlLabel from "@material-ui/core/FormControlLabel";
 import Checkbox from "@material-ui/core/Checkbox";
 import VizG from "react-vizgrammar";
 import { Card, CardContent, MuiThemeProvider, TextField } from "@material-ui/core";

 // Stylings
 import "../css/PreLoader.css";
 import "../css/Message.css";
 //Widget Configuration file including the Siddhi App, Query, Chart Configs
 import widgetConf from "../../resources/widgetConf.json";
 // Themes for widget
 import { dark, light } from "../theme/Theme";
 // This import will be replaced at the building stage to @wso2-dashboard-widget
 import Widget from '@wso2-dashboards/widget';
import moment from "moment" ;

 /**
  * This class holds all the data relevant to the widget you can manipulate the code
  * and see the view real time using the preview area. If you need full screen view you
  * can use https://wso2-multibarchart.stackblitz.io
  * All the things included in here will also be there in the widget after the build process
  */

 export class MyWidget extends Widget {
   constructor(props) {
     super(props);
     this.state = {
       loading: true,
       x_axis: widgetConf.chartConfigs.x_axis,
       chart_type: "bar",
       metadata: {},
       DataSet: [],
       hasError: false,
       checkBoxStatus: [],
       charts: [],
       errorMsg: "",
       theme: dark,
       width: props.glContainer.width,
       height: props.glContainer.height,
       timeStamp:""
     };
   }

   /**
    * Change the theme in the widget according to the dashboard theme
    * @param {JSON} nextProps
    */
   componentWillReceiveProps(nextProps) {
     if (nextProps.muiTheme.name === "dark") {
       this.state.theme = dark;
     } else {
       this.state.theme = light;
     }
   }

   /**
    * Obtain data using the Channel Manager via the Widget and passing the data to the relevant Widget in the golden layout.
    */
   componentDidMount() {
     try {
       if (this.state.loading) {
         const dataProviderConf = widgetConf.configs.providerConfig;
         super
           .getWidgetChannelManager()
           .subscribeWidget(
             this.props.id || "dummyID",
             this.formatDataToVizGrammar,
             dataProviderConf
           );
       }
     } catch (error) {
       console.error("Error in calling wso2-dashaboardwidget", error.message);
       this.setState({
         hasError: true,
         errorMsg: "Error in calling @wso2-DashboardWidget: subscribeWidget"
       });
     }
   }

   /**
    * Formatting data to Vizgrammar chart
    * @param {JSON} stats : Data set passed through the Siddhi Data Provider
    */
   formatDataToVizGrammar = stats => {

     if (stats.metadata != undefined) {
       const metaName_arr = [];
       const metaType_arr = [];
       let checkBoxStatus = {};
       stats.metadata.names.map((el, i) => {
         metaName_arr.push(el);
         if (stats.metadata.types[i] === "linear" ) {
           let checkedStatus = widgetConf.chartConfigs.y_axis.includes(el);
           checkBoxStatus = Object.assign(
             { [el]: checkedStatus },
             checkBoxStatus
           );
         }
       });
       stats.metadata.types.map(el => {
         metaType_arr.push(el.toLowerCase());
       });
       const metaVals = { ...this.state.metadata };
       metaVals.names = metaName_arr;
       metaVals.types = metaType_arr;
       this.setState({
         timeStamp: moment.unix(stats.data[0][0]/1000).format('YYYY-MM-DD hh:mm:ss'),
         loading: false,
         metadata: metaVals,
         DataSet: stats.data,
         checkBoxStatus:
           this.state.checkBoxStatus.length === 0
             ? checkBoxStatus
             : this.state.checkBoxStatus
       });
     }
   };

   handleCheckboxChangeEvent = name => event => {
     const checkBoxStatus = this.state.checkBoxStatus;
     checkBoxStatus[name] = event.target.checked;

     this.setState({
       checkBoxStatus: checkBoxStatus,
       timeStamp: stats.data[0]['TimeStamp']
     });
   };

   generateCharts = () => {
     const { x_axis } = this.state;

     const config = {
       x: x_axis,
       charts: [],
       legend: true,
       legendOrientation: "bottom",
       animate: true,
       style: {
         legendTextBreakLength: 50,
         legendTextSize: 12,
         tickLabelColor: this.state.theme === dark ? "#ffffff" : "#212121",
         legendTextColor: this.state.theme === dark ? "#ffffff" : "#212121"
       }
     };
     widgetConf.chartConfigs.y_axis.forEach(y_column=>{
       config.charts.push({type:'bar',y:y_column})
     })

     return config;
   };
   /**
    * Rendering checkbox pannel which provides the capability to manipulate the chart
    * @return {JSX}
    */
   renderCheckBoxPanel = () => {
     if (!this.state.loading) {
       const checkBoxes = [];
       this.state.metadata.names.forEach((el, i) => {
         if (this.state.metadata.types[i] === "linear") {
           checkBoxes.push(
             <FormControlLabel
               control={
                 <Checkbox
                   checked={this.state.checkBoxStatus[el]}
                   onChange={this.handleCheckboxChangeEvent(el)}
                   value={el}
                 />
               }
               label={el.toUpperCase()}
             />
           );
         }
       });
       return checkBoxes;
     }
   };

   /**
    * Rendering the pre Loader view
    *
    * @returns {JSX}
    */
   renderPreLoader = () => {
     return (
       <div className={"outer-div"}>
         <div className={"center-div"}>
           <div className={"inner-div"}>
             <div>
               <h2>Loading Data....</h2>
               <div className={"psoload"}>
                 <div className={"straight"} />
                 <div className={"curve"} />
                 <div className={"center"} />
                 <div className={"inner"} />
               </div>
             </div>
           </div>
         </div>
       </div>
     );
   };

   /**
    * Rendering the error message
    * @returns {JSX}
    */
   renderErrorMessage = () => {
     if (this.state.hasError === true)
       return (
         <div className="error message">
           <h2>Error</h2>
           <p>Error in calling subscribeWidget</p>
         </div>
       );
   };

   /**
    * Rendering the bar multi bar chart according to the configuration file
    * to view more about Viz-Grammar configurations please visit https://wso2.github.io/react-vizgrammar
    * @returns {JSX}
    */
   renderBarChart = () => {
     const config = this.generateCharts();
     const {height,width} =this.props.glContainer
     if (this.state.x_axis != "" && config.charts.length != 0) {
       return (
         <VizG
           config={config}
           metadata={this.state.metadata}
           data={this.state.DataSet}
           theme={this.state.theme === dark ? "dark" : "light"}
           height={
            height
           }
           width={
            width
           }
         />
       );
     }
   };

   render() {
     return (
       <MuiThemeProvider theme={this.state.theme}>
         {this.state.timeStamp &&
           <div style={{ color: "white", display: 'flex', paddingTop: "10px", paddingLeft: "10px", flexFlow: "row-reverse" }}>
             <span> {this.state.timeStamp}</span>
             <span>Last Updated TimeStamp :</span>
           </div>
         }
         <div>
           {this.renderErrorMessage()}
           <Card>
             {this.state.loading
               ? this.renderPreLoader()
               : this.renderBarChart()}
            
           </Card>
         </div>
         
       </MuiThemeProvider>
     );
   }
 }
 
 export default MyWidget;

 /**
  * Verifying that the dashboard availability to register the widget in the portal
  * if the widget is included in the portal the widget will be registered
  */

 if (global.dashboard != undefined) {
   global.dashboard.registerWidget(widgetConf.id, MyWidget);
 }
