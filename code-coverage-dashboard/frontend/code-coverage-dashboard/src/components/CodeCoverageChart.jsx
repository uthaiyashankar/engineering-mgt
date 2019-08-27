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
            'http://' + process.env.REACT_APP_HOST + ':9999/code_coverage/summary'
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
                            <Tab label="Instruction Coverage" />
                            <Tab label="Branch Coverage" />
                            <Tab label="Complexity Coverage" />
                            <Tab label="Line Coverage" />
                            <Tab label="Method Coverage" />
                            <Tab label="Class Coverage" />
                        </Tabs>
                    </AppBar>
                    <TabContainer>
                        <LineChart data={chartData[value]} colors={["#B80000", "#2E7442", "#FF6900", "#7B1FA2"]} curve={false} library={{
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
