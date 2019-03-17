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

import React from "react";
import Widget from '@wso2-dashboards/widget';
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import {createMuiTheme, MuiThemeProvider, withStyles} from '@material-ui/core/styles';

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

const styles = {
    h4: {
        marginBottom: '20px'
    },
    table: {
        tableHead: {
            tableCell: {
                backgroundColor: '#3f51b5',
                color: 'white',
                fontWeight: 500,
            }
        },
        TableHead: {
            textDecoration: 'uppercase'
        },
        tableBody: {
            tableCell: {
                fontSize: '16px',
                cursorPointer: {
                    cursor: 'pointer'
                },
                cursorText: {
                    cursor: 'text'
                },
            },
            tableCellTotal: {
                fontSize: '18px',
                fontWeight: 700,
                'border-top': '2pt solid gray'
            }
        }
    },
    formControl: {
        margin: '0 20px 30px 0',
        minWidth: 120,
    },
};

const dateHeaderStyle = {
    paddingLeft: "40px",
    display: "inline-block",
    marginRight: "10px",
};

const dateStyle = {
    display: "inline-block",
    align: "center",
    marginLeft: "25px",
};

const builds = {
    fontSize: "11px",
};

const label = {
    padding: "2px 5px 2px 5px",
};

const lastReport = {
    width: "100%",
    textAlign: "center",
};

const lastReportLink = {
    color: "#2196F3",
};

const errorReport = {
    color: "#f44336",
    fontSize: "12px",
};

// methods
// get code coverage percentage
export function getPercentage(total, miss) {
    return (((total - miss) / total) * 100).toFixed(2)
}

// get date as a string (yyyy-mm-dd)
export function getDateStr(dateObj) {
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
}

// format build number string
export function formatBuildString(buildStr) {
    buildStr = buildStr.slice(0, -1);
    let builds = buildStr.split("/");

    return builds.map((item, index) =>
        <span style={label} key={index}>{item}<br/></span>
    );
}

// create Dates array from Date string array
export function createAllowedDatesArray(datesStrArr) {
    let DatesArr = [];
    for (let i = 0; i < datesStrArr.length; i++) {
        DatesArr.push(new Date(datesStrArr[i].date));
    }
    return DatesArr;
}

class CodeCoverageTable extends Widget {

    constructor(props) {
        super(props);
        this.state = {
            isLoaded: false,
            tableSummary: [],
            date: new Date(),
            dateString: '',
            allowedDates: [],
            reportPathLoaded: false,
            reportPathError: "",
            SERVER_PATH: "", // Tomcat server path where code coverage reports hosted
        };

        this.changeDate = this.changeDate.bind(this);
        this.getLastReportDate = this.getLastReportDate.bind(this);
        this.getTableSummary = this.getTableSummary.bind(this);
    }

    changeDate(date) {
        this.setState({date: date});
        this.setState({dateString: getDateStr(date)});
        this.getTableSummary(getDateStr(date));
    };

    getTableSummary(date) {
        fetch("https://" + window.location.host + window.contextPath + "/apis/coverage/table-summary/" + date)
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({
                        isLoaded: true,
                        tableSummary: result
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

    getLastReportDate() {
        fetch("https://" + window.location.host + window.contextPath + "/apis/coverage/last-report-date")
            .then(res => res.json())
            .then(
                (result) => {
                    this.setState({
                        isLoaded: true,
                        allowedDates: createAllowedDatesArray(result),
                        dateString: result[0].date
                    });
                    this.state.date = new Date(this.state.dateString);
                    // get summary for table
                    this.getTableSummary(this.state.dateString);
                },
                (error) => {
                    console.log("getLastReportDate error:" + error);
                    this.setState({
                        isLoaded: true,
                        error
                    });
                }
            );
    }

    componentDidMount() {
        this.getLastReportDate();

        // read sever path where reports hosted
        super.getWidgetConfiguration(this.props.widgetID)
            .then((message) => {
                this.setState({
                    SERVER_PATH: message.data.configs.providerConfig.configs.reports_server_path,
                    reportPathLoaded: true
                });
            })
            .catch((error) => {
                this.setState({
                    reportPathLoaded: false,
                    reportPathError: error,
                });
            });
    }

    render() {
        if (!this.state.isLoaded) {
            return <p>Loading...</p>;
        } else if (this.state.tableSummary.length === 0) {
            return <p>No results found.</p>;
        } else {
            return (
                <MuiThemeProvider theme={this.props.muiTheme.name === 'dark' ? darkTheme : lightTheme}>
                    <PageWrapper>
                        <div className="coverage-table">

                            <div>
                                <p style={dateHeaderStyle}>Select Date</p>
                                <DatePicker style={dateStyle}
                                            selected={this.state.date}
                                            onChange={this.changeDate}
                                            includeDates={this.state.allowedDates}
                                />
                            </div>

                            <Paper>
                                <Table>
                                    <TableHead>
                                        <TableRow>
                                            <TableCell align="center"
                                                       style={styles.table.tableHead.tableCell}>PRODUCT</TableCell>
                                            <TableCell align="center"
                                                       style={styles.table.tableHead.tableCell}>BUILDS</TableCell>
                                            <TableCell align="right"
                                                       style={styles.table.tableHead.tableCell}>INSTRUCTION(%)</TableCell>
                                            <TableCell align="right"
                                                       style={styles.table.tableHead.tableCell}>BRANCHES(%)</TableCell>
                                            <TableCell align="right"
                                                       style={styles.table.tableHead.tableCell}>COMPLEXITY(%)</TableCell>
                                            <TableCell align="right"
                                                       style={styles.table.tableHead.tableCell}>LINES(%)</TableCell>
                                            <TableCell align="right"
                                                       style={styles.table.tableHead.tableCell}>METHODS(%)</TableCell>
                                            <TableCell align="right"
                                                       style={styles.table.tableHead.tableCell}>CLASSES(%)</TableCell>
                                        </TableRow>
                                    </TableHead>
                                    <TableBody>
                                        {this.state.tableSummary.map((row, index) => (
                                            <TableRow key={index}
                                                      style={((row[1] > 0) ? styles.table.tableBody.tableCell.cursorPointer : styles.table.tableBody.tableCell.cursorText)}
                                                      hover>
                                                <TableCell component="th" scope="row"
                                                           align="left">{row.name}</TableCell>
                                                <TableCell style={builds}
                                                           align="left">{formatBuildString(row.build_no)}</TableCell>
                                                <TableCell
                                                    align="right">{getPercentage(row.data.totalIns, row.data.missIns)}</TableCell>
                                                <TableCell
                                                    align="right">{getPercentage(row.data.totalBranches, row.data.missBranches)}</TableCell>
                                                <TableCell
                                                    align="right">{getPercentage(row.data.totalCxty, row.data.missCxty)}</TableCell>
                                                <TableCell
                                                    align="right">{getPercentage(row.data.totalLines, row.data.missLines)}</TableCell>
                                                <TableCell
                                                    align="right">{getPercentage(row.data.totalMethods, row.data.missMethods)}</TableCell>
                                                <TableCell
                                                    align="right">{getPercentage(row.data.totalClasses, row.data.missClasses)}</TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            </Paper>

                            <div>
                                <br/>
                                {this.state.reportPathLoaded && this.state.SERVER_PATH.length > 0 &&
                                <div style={lastReport}>
                                    <span>Last report</span>
                                    <span> [ </span>
                                    <span><a
                                        href={this.state.SERVER_PATH + "/code-coverage-generator/code_coverage_reports/apim"}
                                        target="_blank" style={lastReportLink}>API Management</a></span>
                                    <span> | </span>
                                    <span><a
                                        href={this.state.SERVER_PATH + "/code-coverage-generator/code_coverage_reports/analytics"}
                                        target="_blank" style={lastReportLink}>Analytics</a></span>
                                    <span> | </span>
                                    <span><a
                                        href={this.state.SERVER_PATH + "/code-coverage-generator/code_coverage_reports/iam"}
                                        target="_blank" style={lastReportLink}>IAM</a></span>
                                    <span> | </span>
                                    <span><a
                                        href={this.state.SERVER_PATH + "/code-coverage-generator/code_coverage_reports/ei"}
                                        target="_blank" style={lastReportLink}>Integration</a></span>
                                    <span> ] </span>
                                </div>
                                }
                                {this.state.reportPathLoaded && !this.state.SERVER_PATH.length > 0 &&
                                <div style={lastReport}>
                                    <p style={errorReport}>Failed to load report paths</p>
                                    <p style={errorReport}>Pls check whether you have set "reports_server_path" in
                                        widgetConf.jason</p>
                                    <p style={errorReport}>Given reports server path: {this.state.SERVER_PATH}</p>
                                </div>
                                }
                                {!this.state.reportPathLoaded &&
                                <div className="lastReport">
                                    <p style={errorReport}>Failed to load report paths</p>
                                    <p style={errorReport}>{this.state.reportPathError}</p>
                                </div>
                                }
                            </div>
                        </div>
                    </PageWrapper>
                </MuiThemeProvider>
            )
        }
    }
}

global.dashboard.registerWidget('CodeCoverageTable', CodeCoverageTable);
