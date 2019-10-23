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

import React, { Component } from 'react';
import { LineChart } from 'react-chartkick';
import 'chart.js';
import AppBar from '@material-ui/core/AppBar';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import Paper from '@material-ui/core/es/Paper/Paper';
import { withStyles } from '@material-ui/core/styles';
import { getChartData, TabContainer } from '../utils/functions';

// styles
const PageWrapper = withStyles({
    root: {
        padding: '30px',
        background: 'transparent',
        boxShadow: 'none',
        textAlign: 'center',
        color: '#3f51b5',
    }
})(Paper);

const DivBoarder = {
    border: '2px solid #aaa',
    overflowX: 'auto',
    borderColor: '#3f51b5',

};

const labelStyles = {
    textTransform: "capitalize",
    fontWeight: 500,
    fontSize: '16px'
};

class CodeCoverage extends Component {
    constructor(props) {
        super(props);
        this.state = {
            isLoaded: false,
            chartSummary: [],
            value: 0
        };

        this.handleChange = (event, value) => {
            this.setState({ value });
        };
    }
    componentDidMount() {
        fetch(
            'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/code_coverage/summary'
        )
            .then(res => res.json())
            .then(
                result => {
                    this.setState({
                        isLoaded: true,
                        chartSummary: result
                    });
                },
                error => {
                    this.setState({
                        isLoaded: true,
                        error
                    });
                }
            );
    }

    render() {
        const { value } = this.state;

        if (!this.state.isLoaded) {
            return <p>Loading...</p>;
        }
        var chartData = getChartData(this.state.chartSummary);
        return (
            <PageWrapper>
                <div>
                    <h1>Code Coverage Dashboard</h1>
                </div>
                <div style={DivBoarder}>
                    <AppBar position="static" fontFamily='Titillium Web'>
                        <Tabs
                            value={value}
                            onChange={this.handleChange}
                            centered
                            indicatorColor="primary"
                            textColor="primary"
                        >
                            <Tab label="Instruction Coverage" style={labelStyles}/>
                            <Tab label="Branch Coverage" style={labelStyles}/>
                            <Tab label="Complexity Coverage" style={labelStyles}/>
                            <Tab label="Line Coverage" style={labelStyles}/>
                            <Tab label="Method Coverage" style={labelStyles}/>
                            <Tab label="Class Coverage" style={labelStyles}/>
                        </Tabs>
                    </AppBar>
                    <TabContainer>
                        <LineChart max={100} suffix="%" data={chartData[value]} colors={["#B80000", "#2E7442", "#FF6900", "#7B1FA2"]} curve={false} library={{
                            legend: {
                                labels: {
                                    fontColor: "#3f51b5"
                                }
                            },
                            scales: {
                                yAxes: [
                                    {
                                        ticks: { fontColor: "#3f51b5" },
                                        scaleLabel: { fontColor: "#3f51b5" }
                                    }
                                ],
                                xAxes: [
                                    {
                                        ticks: { fontColor: "#3f51b5" }
                                    }
                                ]
                            }
                        }} />
                    </TabContainer>
                </div>
            </PageWrapper>
        );
    }
}

export default CodeCoverage;
