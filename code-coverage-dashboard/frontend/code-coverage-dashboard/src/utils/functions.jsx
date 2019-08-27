/*
 * Copyright (c) 2019, WSO2 Inc. (http://wso2.com) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import React from 'react';
import PropTypes from 'prop-types';
import Typography from '@material-ui/core/Typography';

const label = {
  padding: '2px 5px 2px 5px'
};

const warning = {
  textAlign: 'center',
  color: 'red',
  fontSize: '14px',
  fontFamily: 'sans-serif'
};

const lastReportLink = {
  color: '#2196F3'
};

export let calcPercentage = (total, miss) => {
  return (((total - miss) / total) * 100).toFixed(2);
};

export let getChartData = chartSummary => {
  let chartData = [];
  let instructionData = [];
  let branchData = [];
  let complexityData = [];
  let lineData = [];
  let methodData = [];
  let classData = [];

  for (let i = 0; i < chartSummary.length; i++) {
    let insObj = {};
    insObj.name = chartSummary[i].name;
    insObj.data = {};

    let branchObj = {};
    branchObj.name = chartSummary[i].name;
    branchObj.data = {};

    let cxtyObj = {};
    cxtyObj.name = chartSummary[i].name;
    cxtyObj.data = {};

    let totalObj = {};
    totalObj.name = chartSummary[i].name;
    totalObj.data = {};

    let methodObj = {};
    methodObj.name = chartSummary[i].name;
    methodObj.data = {};

    let classObj = {};
    classObj.name = chartSummary[i].name;
    classObj.data = {};

    let summaryData = chartSummary[i].productSummaryData;

    for (let key in summaryData) {
      if (summaryData.hasOwnProperty(key)) {
        let sumDate = summaryData[key].date;
        insObj.data[sumDate] = calcPercentage(
          summaryData[key].totalInstructions,
          summaryData[key].missedInstructions
        );
        branchObj.data[sumDate] = calcPercentage(
          summaryData[key].totalBranches,
          summaryData[key].missedBranches
        );
        cxtyObj.data[sumDate] = calcPercentage(
          summaryData[key].totalComplexity,
          summaryData[key].missedComplexity
        );
        totalObj.data[sumDate] = calcPercentage(
          summaryData[key].totalLines,
          summaryData[key].missedLines
        );
        methodObj.data[sumDate] = calcPercentage(
          summaryData[key].totalMethods,
          summaryData[key].missedMethods
        );
        classObj.data[sumDate] = calcPercentage(
          summaryData[key].totalClasses,
          summaryData[key].missedClasses
        );
      }
    }

    instructionData.push(insObj);
    branchData.push(branchObj);
    complexityData.push(cxtyObj);
    lineData.push(totalObj);
    methodData.push(methodObj);
    classData.push(classObj);
  }
  chartData.push(instructionData);
  chartData.push(branchData);
  chartData.push(complexityData);
  chartData.push(lineData);
  chartData.push(methodData);
  chartData.push(classData);

  return chartData;
};

// material ui tabs functions
export let TabContainer = props => {
  return (
    <Typography component="div" style={{ padding: 8 * 3 }}>
      {props.children}
    </Typography>
  );
};

TabContainer.propTypes = {
  children: PropTypes.node.isRequired
};

export let getPercentageData = (total, miss) => {
  if (typeof total === 'undefined' && typeof miss === 'undefined') {
    return <span style={warning}>N/A</span>;
  } else {
    return (((total - miss) / total) * 100).toFixed(2);
  }
};

// get date as a string (yyyy-mm-dd)
export let getDateStr = dateObj => {
  let dd = dateObj.getDate();
  let mm = dateObj.getMonth() + 1; //January is 0
  const yyyy = dateObj.getFullYear();

  if (dd < 10) {
    dd = '0' + dd;
  }

  if (mm < 10) {
    mm = '0' + mm;
  }
  return yyyy + '-' + mm + '-' + dd;
};

// format build number string
export let formatBuildString = buildStr => {
  buildStr = buildStr.slice(0, -1);
  if (buildStr) {
    let builds = buildStr.split('/');
    return builds.map((item, index) => (
      <span style={label} key={index}>
        {item}
        <br />
      </span>
    ));
  } else {
    return <span style={warning}>N/A</span>;
  }
};

export let buildLabel = (key, value, SERVER_PATH) => {
  console.log(key + ':' + value);
  return (
    <span>
      <a
        href={
          SERVER_PATH + '/code-coverage-generator/code_coverage_reports/' + key
        }
        target="_blank"
        rel="noopener noreferrer"
        style={lastReportLink}
      >
        {value}
      </a>
    </span>
  );
};
// create Dates array from Date string array
export let createAllowedDatesArray = datesStrArr => {
  let DatesArr = [];
  for (let i = 0; i < datesStrArr.length; i++) {
    DatesArr.push(new Date(datesStrArr[i].date));
  }
  return DatesArr;
};

//Creates a products array
export let createProductArray = result => {
  let products = [];
  for (let i = 0; i < result.length; i++) {
    products[result[i].abbr] = result[i].name;
  }
  return products;
};
