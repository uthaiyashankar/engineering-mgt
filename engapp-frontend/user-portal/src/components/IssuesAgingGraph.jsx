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
import { ColumnChart } from 'react-chartkick';
import 'chart.js';
import axios from 'axios';

export default class IssuesAgingGraph extends Component {
    constructor(props) {
        super(props);
        this.state = {
            isLoaded: false,
            ChartData: []
        };
    }
    componentDidMount() {
        axios
            .create({
                withCredentials: false
            })
            .get(
                'http://' +
                process.env.REACT_APP_HOST +
                ':' +
                process.env.REACT_APP_PORT +
                '/gitIssues/agingDetails'
            )
            .then(res => res.data)
            .then(
                result => {
                    this.setState({
                        isLoaded: true,
                        ChartData: result
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
        if (!this.state.isLoaded) {
            return <p>Loading...</p>;
        }
        return (
            <ColumnChart
                data={this.state.ChartData}
                stacked
                height={this.props.height || ''}
                xtitle='Time Period'
                ytitle='No of issues'
                messages={{ empty: 'No Data Available' }}
                colors={['green','grey', 'yellow', 'purple','orange', 'maroon', 'red','purple','black','brown','blue','#3f51b5','#E9967A']}
                library={{
                    legend: {
                        labels: {
                            fontColor: '#3f51b5'
                        }
                    },
                    scales: {
                        yAxes: [
                            {
                                ticks: { fontColor: '#3f51b5' },
                                scaleLabel: { fontColor: '#3f51b5' }
                            }
                        ],
                        xAxes: [
                            {
                                ticks: { fontColor: '#3f51b5' },
                                scaleLabel: { fontColor: '#3f51b5' }
                            }
                        ]
                    }
                }}
            />
        );
    }
}
