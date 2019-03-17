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

import React, {Component} from 'react';
import chart from 'chart.js';
import PropTypes from 'prop-types';
import {LineChart} from 'react-chartkick';
import AppBar from '@material-ui/core/AppBar';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import Typography from '@material-ui/core/Typography';
import Paper from "@material-ui/core/es/Paper/Paper";
import {createMuiTheme, MuiThemeProvider, withStyles} from '@material-ui/core/styles';

// material ui tabs functions
function TabContainer(props) {
    return (
        <Typography component="div" style={{padding: 8 * 3}}>
            {props.children}
        </Typography>
    );
}

TabContainer.propTypes = {
    children: PropTypes.node.isRequired,
};

// styles
const darkTheme = createMuiTheme({
    palette: {
        type: 'dark'
    },
    typography: {
        fontFamily: [
            "Roboto",
            "-apple-system",
            "BlinkMacSystemFont",
            "Segoe UI",
            "Arial",
            "sans-serif"
        ].join(","),
        useNextVariants: true
    }
});

const lightTheme = createMuiTheme({
    palette: {
        type: 'light'
    },
    typography: {
        fontFamily: [
            "Roboto",
            "-apple-system",
            "BlinkMacSystemFont",
            "Segoe UI",
            "Arial",
            "sans-serif"
        ].join(","),
        useNextVariants: true
    }
});

const PageWrapper = withStyles({
    root: {
        padding: '30px',
        background: 'transparent',
        boxShadow: 'none'
    }
})(Paper);

export function getPercentage(total, miss) {
    return (((total - miss) / total) * 100).toFixed(2)
}

export function getChartData(chartSummary) {
    let chartData = [];
    let insData = [];
    let branchData = [];
    let cxtyData = [];
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

        let summaryData = chartSummary[i].data;

        for (let key in summaryData) {
            if (summaryData.hasOwnProperty(key)) {
                insObj.data[key] = getPercentage(summaryData[key].totalIns, summaryData[key].missIns);
                branchObj.data[key] = getPercentage(summaryData[key].totalBranches, summaryData[key].missBranches);
                cxtyObj.data[key] = getPercentage(summaryData[key].totalCxty, summaryData[key].missCxty);
                totalObj.data[key] = getPercentage(summaryData[key].totalLines, summaryData[key].missLines);
                methodObj.data[key] = getPercentage(summaryData[key].totalMethods, summaryData[key].missMethods);
                classObj.data[key] = getPercentage(summaryData[key].totalClasses, summaryData[key].missClasses);
            }
        }

        insData.push(insObj);
        branchData.push(branchObj);
        cxtyData.push(cxtyObj);
        lineData.push(totalObj);
        methodData.push(methodObj);
        classData.push(classObj);
    }
    chartData.push(insData);
    chartData.push(branchData);
    chartData.push(cxtyData);
    chartData.push(lineData);
    chartData.push(methodData);
    chartData.push(classData);

    return chartData;
}

class CodeCoverage extends Component {

    constructor(props) {
        super(props);
        this.state = {
            isLoaded: false,
            chartSummary: [],
            chartData: [],
            value: 0
        };

        this.handleChange = (event, value) => {
            this.setState({value});
        };
    }

    componentDidMount() {
        fetch("https://" + window.location.host + window.contextPath + "/apis/coverage/summary")
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({
                        isLoaded: true,
                        chartSummary: result
                    });
                },
                (error) => {
                    this.setState({
                        isLoaded: true,
                        error
                    });
                }
            );
    }

    render() {
        const {value} = this.state;

        if (!this.state.isLoaded) {
            return <p>Loading...</p>
        } else {
            this.state.chartData = getChartData(this.state.chartSummary);
            return (
                <MuiThemeProvider theme={this.props.muiTheme.name === 'dark' ? darkTheme : lightTheme}>
                    <PageWrapper>
                        <Paper>
                            <div className="component-chart">
                                <AppBar position="static">
                                    <Tabs value={value} onChange={this.handleChange}>
                                        <Tab label="Instruction Coverage"/>
                                        <Tab label="Branch Coverage"/>
                                        <Tab label="Complexity Coverage"/>
                                        <Tab label="Line Coverage"/>
                                        <Tab label="Method Coverage"/>
                                        <Tab label="Class Coverage"/>
                                    </Tabs>
                                </AppBar>
                                {value === 0 &&
                                <TabContainer><LineChart data={this.state.chartData[0]} curve={false}/></TabContainer>}
                                {value === 1 &&
                                <TabContainer><LineChart data={this.state.chartData[1]} curve={false}/></TabContainer>}
                                {value === 2 &&
                                <TabContainer><LineChart data={this.state.chartData[2]} curve={false}/></TabContainer>}
                                {value === 3 &&
                                <TabContainer><LineChart data={this.state.chartData[3]} curve={false}/></TabContainer>}
                                {value === 4 &&
                                <TabContainer><LineChart data={this.state.chartData[4]} curve={false}/></TabContainer>}
                                {value === 5 &&
                                <TabContainer><LineChart data={this.state.chartData[5]} curve={false}/></TabContainer>}
                            </div>
                        </Paper>
                    </PageWrapper>
                </MuiThemeProvider>
            );
        }
    }
}

global.dashboard.registerWidget('CodeCoverage', CodeCoverage);
