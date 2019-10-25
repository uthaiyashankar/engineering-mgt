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
import MaterialTable from 'material-table';
import axios from 'axios';
import 'chart.js';

export default class IssuesForlabelsChart extends Component {
    constructor(props) {
        super(props);
        this.state = {
            isLoaded: false,
            chartSummary: []
        };
    }

    componentDidMount() {
        const getProductNamesURL =
            'http://' +
            process.env.REACT_APP_HOST +
            ':' +
            process.env.REACT_APP_PORT +
            '/gitIssues/issueCount';
        axios
            .create({
                withCredentials: false
            })
            .get(getProductNamesURL)
            .then(res => res.data)
            .then(data => {
                this.setState({ IssueData: data, isLoaded: true });
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
                <link
                    rel="stylesheet"
                    href="https://fonts.googleapis.com/icon?family=Material+Icons"
                />
                <MaterialTable
                    title=''
                    columns={[
                        {
                            title: 'Teams',
                            field: 'name',
                            cellStyle: {
                                backgroundColor: '#E1E7EF',
                                color: 'black'
                            },
                            headerStyle: {
                                backgroundColor: '#05376F'
                            }
                        },
                        {
                            title: 'Num of Issues',
                            field: 'totalIssueCount',
                            cellStyle: {
                                backgroundColor: '#E1E7EF',
                                color: 'black'
                            },
                            headerStyle: {
                                backgroundColor: '#05376F'
                            }
                        }
                    ]}
                    data={this.state.IssueData}
                    options={{
                        responsive: true,
                        exportButton: false,
                        grouping: false,
                        sorting: true,
                        search: false,
                        headerStyle: {
                            backgroundColor: '#01579b',
                            color: '#FFF'
                        }
                    }}
                />
            </div>
        );
    }
}
