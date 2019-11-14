/*
 *  Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the 'License'); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 *
 */




import React, { Component } from 'react';
import 'chart.js';
import axios from 'axios';
import { Bar } from 'react-chartjs-2';

export default class IssuesForlabelsChart extends Component {
    constructor(props) {
        super(props);
        this.state = {
            chartData: {},
            isLoaded: false
        };
    }

    static defaultProps = {
        displayTitle: true,
        displayLegend: true,
        legendPosition: 'bottom',
        chartName: 'Git Issue'
    };

    componentDidMount() {
        const getProductNamesURL =
            'http://' +
            process.env.REACT_APP_HOST +
            ':' +
            process.env.REACT_APP_PORT +
            '/gitIssues/issueCountBylabel';
        axios
            .create({
                withCredentials: false
            })
            .get(getProductNamesURL)
            .then(res => {
                var response = res.data;
                var ProductName = response.map(function (e) {
                    return e.name;
                });
                var L1IssueCount = response.map(function (e) {
                    return e.L1IssueCount;
                });
                var L2IssueCount = response.map(function (e) {
                    return e.L2IssueCount;
                });
                var L3IssueCount = response.map(function (e) {
                    return e.L3IssueCount;
                });
                this.setState({
                    isLoaded: true,
                    chartData: {
                        labels: ProductName,
                        datasets: [
                            {
                                label: 'Blocker',
                                data: L1IssueCount,
                                backgroundColor: '#8d0f06'
                            },
                            {
                                label: 'Critical',
                                data: L2IssueCount,
                                backgroundColor: '#d45810'
                            },
                            {
                                label: 'Major',
                                data: L3IssueCount,
                                backgroundColor: '#d4c70e'
                            }
                        ]
                    }
                });
            })
            .catch(error => {
                this.setState({
                    isLoaded: true,
                    error
                });
            });
    }

    render() {
        if (!this.state.isLoaded) {
            return <p>Loading...</p>;
        }
        return (
            <div>
                <div className="chart">
                    <Bar
                        height={this.props.height || ''}
                        data={this.state.chartData}
                        options={{
                            maintainAspectRatio: false,
                            responsive: true,
                            scales: {
                                xAxes: [
                                    {
                                        display: true,
                                        ticks: {
                                            fontColor: '#3f51b5',
                                            fontWeight: 'bold',
                                            fontFamily: 'sans-serif',
                                            beginAtZero: true
                                        },
                                        scaleLabel: {
                                            display: true,
                                            labelString: 'Teams',
                                            fontFamily: 'sans-serif',
                                            fontColor: '#3f51b5 ',
                                            fontSize: '18'
                                        }
                                    }
                                ],
                                yAxes: [
                                    {
                                        display: true,
                                        ticks: {
                                            fontColor: 'black',
                                            beginAtZero: true
                                        },
                                        scaleLabel: {
                                            display: true,
                                            labelString: 'No of Issues',
                                            fontFamily: 'sans-serif',
                                            fontColor:  '#3f51b5',
                                            fontSize: '16'
                                        },
                                        fontColor: 'red'
                                    }
                                ]
                            },
                            legend: {
                                labels: {
                                    fontColor: '#3f51b5',
                                },
                                display: 'true',
                                position: 'top'
                            }
                        }}
                    />
                </div>
            </div>
        );
    }
}

