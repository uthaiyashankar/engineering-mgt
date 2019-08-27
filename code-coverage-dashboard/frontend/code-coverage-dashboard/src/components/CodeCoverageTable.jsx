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
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import { withStyles } from '@material-ui/core/styles';
import {
    getPercentageData,
    getDateStr,
    formatBuildString,
    createAllowedDatesArray,
    createProductArray,
    buildLabel
} from '../utils/functions';

// styles
const PageWrapper = withStyles({
    root: {
        padding: '30px',
        background: 'transparent',
        boxShadow: 'none'
    }
})(Paper);

const styles = {
    table: {
        tableHead: {
            tableCell: {
                backgroundColor: '#3f51b5',
                color: 'white',
                fontWeight: 500
            }
        },
        TableHead: {
            textDecoration: 'uppercase',
            TableRow: {
                display: 'block'
            }
        },
        tableBody: {
            tableCell: {
                fontSize: '16px',
                color: '#3f51b5',
                cursorPointer: {
                    cursor: 'pointer'
                },
                cursorText: {
                    cursor: 'text'
                }
            },
        },
        TableBody: {
            display: 'block',
            width: '100%',
            overflow: 'auto',
            height: '100px'
        }
    },
    formControl: {
        minWidth: 120
    }
};

const dateHeaderStyle = {
    paddingLeft: '40px',
    fontSize: '18px',
    display: 'inline-block',
    marginTop: 0,
    color: '#3f51b5',
    fontFamily: 'sans-serif',
};

const dateStyle = {
    display: 'inline-block',
    align: 'center',
    color: '#3f51b5',
    fontWeight: 500,
};

const builds = {
    fontSize: '10px',
    color: '#3f51b5',
    fontWeight: 500
};

const lastReport = {
    width: '100%',
    fontSize: '18px',
    textAlign: 'center',
    color: '#3f51b5',
    fontFamily: 'sans-serif'
};

const errorReport = {
    color: '#f44336',
    fontSize: '16px'
};

const DateDiv = {
    float: 'left'
};

const ReportDiv = {
    float: 'right'
};

const TableBorder = {
    border: '2px solid #aaa',
    borderColor: '#3f51b5'
};

const TableDiv = {
    overflowX: 'auto'
};

class CodeCoverageTable extends Component {
    constructor(props) {
        super(props);
        this.state = {
            isLoaded: false,
            tableSummary: [],
            date: new Date(),
            dateString: '',
            allowedDates: [],
            products: [],
            reportPathLoaded: false,
            SERVER_PATH: '' // Tomcat server path where code coverage reports hosted
        };

        this.changeDate = this.changeDate.bind(this);
        this.getLastReportDate = this.getLastReportDate.bind(this);
        this.getTableSummary = this.getTableSummary.bind(this);
    }

    changeDate(date) {
        this.setState({ date: date });
        this.setState({ dateString: getDateStr(date) });
        this.getTableSummary(getDateStr(date));
    }

    getTableSummary(date) {
        fetch(
            'http://' +
            process.env.REACT_APP_HOST +
            ':9999/code_coverage/summary/' +
            date
        )
            .then(res => res.json())
            .then(
                result => {
                    this.setState({
                        isLoaded: true,
                        tableSummary: result,
                        products: createProductArray(result)
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

    getLastReportDate() {
        fetch(
            'http://' +
            process.env.REACT_APP_HOST +
            ':9999/code_coverage/last-report-date'
        )
            .then(res => res.json())
            .then(
                result => {
                    this.setState({
                        isLoaded: true,
                        allowedDates: createAllowedDatesArray(result),
                        dateString: result[0].date,
                        date: new Date(result[0].date)
                    });
                    // get summary for table
                    this.getTableSummary(this.state.dateString);
                },
                error => {
                    console.log('getLastReportDate error:' + error);
                    this.setState({
                        isLoaded: true,
                        error
                    });
                }
            );
    }

    componentDidMount() {
        this.getLastReportDate();
        this.setState({
            SERVER_PATH: process.env.REACT_APP_SERVER_PATH,
            reportPathLoaded: true
        });
    }

    render() {
        var productLabels = [];
        for (let product in this.state.products) {
            productLabels.push(
                buildLabel(
                    product,
                    this.state.products[product],
                    this.state.SERVER_PATH
                )
            );
            productLabels.push(<span> | </span>);
        }
        productLabels.pop();
        if (!this.state.isLoaded) {
            return <p>Loading...</p>;
        }
        if (this.state.tableSummary.length === 0) {
            return <p>No results found.</p>;
        }
        return (
            <PageWrapper>
                <div style={TableDiv}>
                    <div style={DateDiv}>
                        <p style={dateHeaderStyle}>Select Date &nbsp;</p>
                        <DatePicker
                            style={dateStyle}
                            selected={this.state.date}
                            onChange={this.changeDate}
                            includeDates={this.state.allowedDates}
                        />
                    </div>

                    <div style={ReportDiv}>
                        {this.state.reportPathLoaded && this.state.SERVER_PATH && (
                            <div style={lastReport}>
                                <span>Last report</span>
                                <span> [ </span>
                                {productLabels}
                                <span> ] &nbsp;</span>
                            </div>
                        )}
                        {this.state.reportPathLoaded && this.state.SERVER_PATH === '' && (
                            <div style={lastReport}>
                                <p style={errorReport}>Failed to load report paths</p>
                                <p style={errorReport}>Give report server path!</p>
                            </div>
                        )}
                    </div>

                    <Table style={TableBorder}>
                        <colgroup>
                            <col style={{ width: '10%' }} />
                            <col style={{ width: '20%' }} />
                            <col style={{ width: '15%' }} />
                            <col style={{ width: '13%' }} />
                            <col style={{ width: '12%' }} />
                            <col style={{ width: '10%' }} />
                            <col style={{ width: '10%' }} />
                            <col style={{ width: '10%' }} />
                        </colgroup>
                        <TableHead>
                            <TableRow>
                                <TableCell
                                    align="center"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    PRODUCT
                </TableCell>
                                <TableCell
                                    align="center"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    BUILDS
                </TableCell>
                                <TableCell
                                    align="right"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    INSTRUCTIONS (%)
                </TableCell>
                                <TableCell
                                    align="right"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    BRANCHES (%)
                </TableCell>
                                <TableCell
                                    align="right"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    COMPLEXITY (%)
                </TableCell>
                                <TableCell
                                    align="right"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    LINES (%)
                </TableCell>
                                <TableCell
                                    align="right"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    METHODS (%)
                </TableCell>
                                <TableCell
                                    align="right"
                                    style={styles.table.tableHead.tableCell}
                                >
                                    CLASSES (%)
                </TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {this.state.tableSummary.map((row, index) => (
                                <TableRow
                                    key={index}
                                    style={
                                        row[1] > 0
                                            ? styles.table.tableBody.tableCell.cursorPointer
                                            : styles.table.tableBody.tableCell.cursorText
                                    }
                                    hover
                                >
                                    <TableCell component="th" scope="row" align="left" style={styles.table.tableBody.tableCell}>
                                        {row.name}
                                    </TableCell>
                                    <TableCell style={builds} align="center">
                                        {formatBuildString(row.builds)}
                                    </TableCell>
                                    <TableCell align="right" style={styles.table.tableBody.tableCell}>
                                        {getPercentageData(
                                            row.daySummary.totalInstructions,
                                            row.daySummary.missedInstructions
                                        )}
                                    </TableCell>
                                    <TableCell align="right" style={styles.table.tableBody.tableCell}>
                                        {getPercentageData(
                                            row.daySummary.totalBranches,
                                            row.daySummary.missedBranches
                                        )}
                                    </TableCell>
                                    <TableCell align="right" style={styles.table.tableBody.tableCell}>
                                        {getPercentageData(
                                            row.daySummary.totalComplexity,
                                            row.daySummary.missedComplexity
                                        )}
                                    </TableCell>
                                    <TableCell align="right" style={styles.table.tableBody.tableCell}>
                                        {getPercentageData(
                                            row.daySummary.totalLines,
                                            row.daySummary.missedLines
                                        )}
                                    </TableCell>
                                    <TableCell align="right" style={styles.table.tableBody.tableCell}>
                                        {getPercentageData(
                                            row.daySummary.totalMethods,
                                            row.daySummary.missedMethods
                                        )}
                                    </TableCell>
                                    <TableCell align="right" style={styles.table.tableBody.tableCell}>
                                        {getPercentageData(
                                            row.daySummary.totalClasses,
                                            row.daySummary.missedClasses
                                        )}
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </div>
            </PageWrapper>
        );
    }
}

export default CodeCoverageTable;
