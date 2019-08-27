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
import { FormControl, InputLabel, Select, MenuItem, Tooltip } from '@material-ui/core';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import axios from 'axios';
import appendQuery from 'append-query';
import {
    loadData,
    loadVersions,
    getJiraIssues,
    getGitIssues,
    getCodeCoverage,
    getMPRCount,
    getDependencySummary,
} from '../utils/utilFunc';

const PageWrapper = {
    padding: '30px',
    background: 'transparent',
    boxShadow: 'none',
    color: '#3f51b5',
    textAlign: 'center'
};

const styles = {
    table: {
        tableHead: {
            tableCell: {
                backgroundColor: '#3f51b5',
                color: 'white',
                fontWeight: 700,
                fontSize: '20px',
                textAlign: 'center'
            },
            progressCell: {
                backgroundColor: '#3f51b5',
                color: 'white',
                fontWeight: 700,
                fontSize: '20px',

            }
        },
        tableBody: {
            tableCell: {
                fontSize: '18px',
                color: '#14307A',
                textAlign: 'center',
                cursorPointer: {
                    cursor: 'pointer'
                },
                cursorText: {
                    cursor: 'text'
                },
                padding: '0px 24px 0px 16px'
            },
            progressCell: {
                fontSize: '16px',
                textAlign: 'Left',
                color: '#14307A',
                cursorPointer: {
                    cursor: 'pointer'
                },
                cursorText: {
                    cursor: 'text'
                },
                padding: '0px 24px 0px 16px'
            }
        },
        TableBody: {
            display: 'block',
            width: '100%',
            overflow: 'auto',
            height: '100px',
        }
    },

    SelectDiv: {
        overflowX: 'auto',
        padding: '5px',
        textAlign: 'left'
    },

    TableDiv: {
        overflowX: "auto",
    },

    FormControl: {
        margin: '0 20px 30px 0',
        minWidth: 200
    },

    TableBorder: {
        border: '2px solid #aaa',
        borderColor: '#3f51b5'
    },

    RED: {
        height: '20px',
        width: '20px',
        backgroundColor: '#FF3C33',
        borderRadius: '50%',
        display: 'inline-block'
    },

    YELLOW: {
        height: '20px',
        width: '20px',
        backgroundColor: '#FFDD33',
        borderRadius: '50%',
        display: 'inline-block'
    },

    GREEN: {
        height: '20px',
        width: '20px',
        backgroundColor: '#79F63B',
        borderRadius: '50%',
        display: 'inline-block'
    },

    GREY: {
        height: '20px',
        width: '20px',
        backgroundColor: '#AFAFAF',
        borderRadius: '50%',
        display: 'inline-block'
    }

}

const ColoredLine = ({ color }) => (
    <hr
        style={{
            backgroundColor: '#3f51b5',
            height: 2
        }}
    />
);
export default class Checklist extends Component {

    constructor(props) {
        super(props);
        this.state = {
            selectedProductName: '',
            productNameList: [],
            selectedProductVersion: '',
            productVersionList: [],
            loading: false,

            jiraSecScan: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecScanStatus: { status: styles.GREY, desc: "" },
            jiraSecScanLoading: false,

            jiraPerf: { totalIssues: '', openIssues: '', refLink: '' },
            jiraPerfStatus: { status: styles.GREY, desc: '' },
            jiraPerfLoading: false,

            jiraCommitment: { totalIssues: '', openIssues: '', refLink: '' },
            jiraCommitmentStatus: { status: styles.GREY, desc: '' },
            jiraCommitmentLoading: false,

            jiraSecCust: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecCustStatus: { status: styles.GREY, desc: '' },
            jiraSecCustLoading: false,

            jiraSecExt: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecExtStatus: { status: styles.GREY, desc: '' },
            jiraSecExtLoading: false,

            jiraSecInt: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecIntStatus: { status: styles.GREY, desc: '' },
            jiraSecIntLoading: false,

            gitIssues: { L1Issues: '', L2Issues: '', L3Issues: '', refLink: '' },
            gitIssuesLoading: false,
            gitIssueL1Status: { status: styles.GREY, desc: '' },
            gitIssueL2Status: { status: styles.GREY, desc: '' },
            gitIssueL3Status: { status: styles.GREY, desc: '' },

            codeCoverage: {
                instructionCov: '', branchCov: '', complexityCov: '',
                lineCov: '', methodCov: '', classCov: '', refLink: ''
            },
            codeCoverageStatus: { status: styles.GREY, desc: '' },
            codeCoverageLoading: false,

            mergedPRCount: { mprCount: '', refLink: '' },
            mergedPRCountStatus: { status: styles.GREY, desc: '' },
            mergedPRCountLoading: false,

            dependencySummary: { dependencySummary: '', refLink: '' },
            dependencySummaryStatus: { status: styles.GREY, desc: '' },
            dependencySummaryLoading: false
        };
        this.handleChangeProductName = event => {
            this.setState({ [event.target.name]: event.target.value });
            this.setState({
                selectedProductName: event.target.value,
            });
        };

        this.handleChangeProductVersion = event => {
            this.setState({
                [event.target.name]: event.target.value
            });
            this.setState({
                selectedProductVersion: event.target.value,
            });
        }
    }

    componentDidMount() {
        const getProductNamesURL = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/checklist/productNames';

        axios.create({
            withCredentials: false,
        })
            .get(getProductNamesURL)
            .then(response => {
                if (response.hasOwnProperty('data')) {
                    this.setState({
                        productNameList: Object.values(response.data.products)
                    });
                }
            })
            .catch(error => {
                console.log(error)
            });
    }

    componentDidUpdate(prevProps, prevState) {
        if (this.state.selectedProductName !== prevState.selectedProductName) {
            this.resetState();
            this.setState({
                loading: true
            })
            let versionURL = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/checklist/versions/' + this.state.selectedProductName;
            axios.create({
                withCredentials: false,
            })
                .get(versionURL)
                .then(
                    res => {
                        this.setState({
                            loading: false,
                            productVersionList: res.data.versions.map(
                                version => ({
                                    versionTitle: version.title,
                                    versionNumber: version.number
                                })),
                        })
                    }
                )
                .catch(error => {
                    console.log(error);
                });
        }

        if (this.state.selectedProductVersion !== prevState.selectedProductVersion) {
            this.resetState();
            let infoVersion = { version: this.state.selectedProductVersion.versionNumber }
            let infoTitle = { version: this.state.selectedProductVersion.versionTitle }

            let gitIssuesURL = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/checklist/gitIssues/' + this.state.selectedProductName;
            gitIssuesURL = appendQuery(gitIssuesURL, infoVersion);

            let codeCoverageURL = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/checklist/codeCoverage/' + this.state.selectedProductName;

            let mergedPRCountURL = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/checklist/mprCount/' + this.state.selectedProductName;
            mergedPRCountURL = appendQuery(mergedPRCountURL, infoTitle);

            let dependencyURL = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/checklist/dependency/' + this.state.selectedProductName;

            var jiraTypesArray = ['sec-scan', 'perf-report', 'commitment', 'sec-cust', 'sec-ext', 'sec-int'];

            for (var i = 0; i < jiraTypesArray.length; i++) {
                let Query = {
                    version: this.state.selectedProductVersion.versionTitle, labels: jiraTypesArray[i]
                }

                let jiraURL = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/checklist/jiraIssues/' + this.state.selectedProductName;
                jiraURL = appendQuery(jiraURL, Query);

                // Jira Issues
                switch (jiraTypesArray[i]) {
                    case "sec-scan": {
                        this.setState({
                            jiraSecScanLoading: true
                        })
                        axios.create({
                            withCredentials: false,
                        })
                            .get(jiraURL)
                            .then(
                                res => {
                                    this.setState({
                                        jiraSecScan: res.data,
                                        jiraSecScanLoading: false
                                    },
                                        function () {
                                            if (typeof this.state.jiraSecScan.openIssues === 'undefined' && typeof this.state.jiraSecScan.totalIssues === 'undefined') {
                                                return
                                            }
                                            if (this.state.jiraSecScan.openIssues > 0) {
                                                this.setState({
                                                    jiraSecScanStatus: {
                                                        status: styles.RED,
                                                        desc: 'RED : Security Scan reports are present'
                                                    }
                                                });
                                            } else {
                                                this.setState({
                                                    jiraSecScanStatus: {
                                                        status: styles.GREEN,
                                                        desc: 'GREEN : No Security Scan reports are present'
                                                    }
                                                });
                                            }
                                        }
                                    );
                                }
                            ).catch(error => {
                                console.log(error);
                            });
                        break;
                    }

                    case "perf-report": {
                        this.setState({
                            jiraPerfLoading: true
                        })
                        axios.create({
                            withCredentials: false,
                        })
                            .get(jiraURL)
                            .then(
                                res => {
                                    this.setState({
                                        jiraPerf: res.data,
                                        jiraPerfLoading: false
                                    },
                                        function () {
                                            if (typeof this.state.jiraPerf.openIssues === 'undefined' && typeof this.state.jiraPerf.totalIssues === 'undefined') {
                                                return
                                            }
                                            else if (this.state.jiraPerf.openIssues > 0) {
                                                this.setState({
                                                    jiraPerfStatus: {
                                                        status: styles.RED,
                                                        desc: 'RED : Performance Analysis Reports are present'
                                                    }
                                                });
                                            } else {
                                                this.setState({
                                                    jiraPerfStatus: {
                                                        status: styles.GREEN,
                                                        desc: 'GREEN : No Performance Analysis Reports present'
                                                    }
                                                });
                                            }
                                        }
                                    );
                                }
                            ).catch(error => {
                                console.log(error);
                            });


                        break;
                    }

                    case "commitment": {
                        this.setState({
                            jiraCommitmentLoading: true
                        })
                        axios.create({
                            withCredentials: false,
                        })
                            .get(jiraURL)
                            .then(
                                res => {
                                    this.setState({
                                        jiraCommitment: res.data,
                                        jiraCommitmentLoading: false
                                    },
                                        function () {
                                            if (typeof this.state.jiraCommitment.openIssues === 'undefined' && typeof this.state.jiraCommitment.totalIssues === 'undefined') {
                                                return
                                            }
                                            if (this.state.jiraCommitment.openIssues > 0) {
                                                this.setState({
                                                    jiraCommitmentStatus: {
                                                        status: styles.RED,
                                                        desc: 'RED : Customer Commitments are present'
                                                    }
                                                });
                                            } else {
                                                this.setState({
                                                    jiraCommitmentStatus: {
                                                        status: styles.GREEN,
                                                        desc: 'GREEN : No Customer Commitments are present'
                                                    }
                                                });
                                            }
                                        }
                                    );
                                }
                            ).catch(error => {
                                console.log(error);
                            });

                        break;
                    }

                    case "sec-cust": {
                        this.setState({
                            jiraSecCustLoading: true
                        })
                        axios.create({
                            withCredentials: false,
                        })
                            .get(jiraURL)
                            .then(
                                res => {
                                    this.setState({
                                        jiraSecCust: res.data,
                                        jiraSecCustLoading: false
                                    },
                                        function () {
                                            if (typeof this.state.jiraSecCust.openIssues === 'undefined' && typeof this.state.jiraSecCust.totalIssues === 'undefined') {
                                                return
                                            }
                                            if (this.state.jiraSecCust.openIssues > 0) {
                                                this.setState({
                                                    jiraSecCustStatus: {
                                                        status: styles.RED,
                                                        desc: 'RED : Security issues identified by the customer are present'
                                                    }
                                                });
                                            } else {
                                                this.setState({
                                                    jiraSecCustStatus: {
                                                        status: styles.GREEN,
                                                        desc: 'GREEN : No Security issues identified by the customer'
                                                    }
                                                });
                                            }
                                        }
                                    );
                                }
                            ).catch(error => {
                                console.log(error);
                            });

                        break;
                    }

                    case "sec-ext": {
                        this.setState({
                            jiraSecExtLoading: true
                        })
                        axios.create({
                            withCredentials: false,
                        })
                            .get(jiraURL)
                            .then(
                                res => {
                                    this.setState({
                                        jiraSecExt: res.data,
                                        jiraSecExtLoading: false
                                    },
                                        function () {
                                            if (typeof this.state.jiraSecExt.openIssues === 'undefined' && typeof this.state.jiraSecExt.totalIssues === 'undefined') {
                                                return
                                            }
                                            if (this.state.jiraSecExt.openIssues > 0) {
                                                this.setState({
                                                    jiraSecExtStatus: {
                                                        status: styles.RED,
                                                        desc: 'RED : Security issues by external testing are present'
                                                    }
                                                });
                                            } else {
                                                this.setState({
                                                    jiraSecExtStatus: {
                                                        status: styles.GREEN,
                                                        desc: 'GREEN : No Security issues identified by external testing'
                                                    }
                                                });
                                            }
                                        }
                                    );
                                }
                            ).catch(error => {
                                console.log(error);
                            });
                        break;
                    }

                    case "sec-int": {
                        this.setState({
                            jiraSecIntLoading: true
                        })
                        axios.create({
                            withCredentials: false,
                        })
                            .get(jiraURL)
                            .then(
                                res => {
                                    this.setState({
                                        jiraSecInt: res.data,
                                        jiraSecIntLoading: false
                                    },
                                        function () {
                                            if (typeof this.state.jiraSecInt.openIssues === 'undefined' && typeof this.state.jiraSecInt.totalIssues === 'undefined') {
                                                return
                                            }
                                            if (this.state.jiraSecInt.openIssues > 0) {
                                                this.setState({
                                                    jiraSecIntStatus: {
                                                        status: styles.RED,
                                                        desc: 'RED : Security issues by internal testing are present'
                                                    }
                                                });
                                            } else {
                                                this.setState({
                                                    jiraSecIntStatus: {
                                                        status: styles.GREEN,
                                                        desc: 'GREEN : No Security issues identified by internal testing'
                                                    }
                                                });
                                            }
                                        }
                                    );
                                }
                            ).catch(error => {
                                console.log(error);
                            });
                        break;
                    }
                    default: {
                        break;
                    }

                }
            }

            //Git issues 
            this.setState({
                gitIssuesLoading: true
            })
            axios.create({
                withCredentials: false,
            })
                .get(gitIssuesURL)
                .then(
                    res => {
                        this.setState({
                            gitIssuesLoading: false,
                            gitIssues: res.data
                        },
                            function () {
                                if (typeof this.state.gitIssues.L1Issues === 'undefined') {
                                    this.setState({
                                        gitIssueL1Status: {
                                            status: styles.GREY,
                                        }
                                    });
                                }
                                else if (this.state.gitIssues.L1Issues > 0) {
                                    this.setState({
                                        gitIssueL1Status: {
                                            status: styles.RED,
                                            desc: 'RED : Number of L1 issues is greater than 0'
                                        }
                                    });
                                } else {
                                    this.setState({
                                        gitIssueL1Status: {
                                            status: styles.GREEN,
                                            desc: 'GREEN : No L1 issues open'

                                        }
                                    });
                                }

                                if (typeof this.state.gitIssues.L2Issues === 'undefined') {
                                    this.setState({
                                        gitIssueL2Status: {
                                            status: styles.GREY,
                                        }
                                    });
                                }
                                else if (this.state.gitIssues.L2Issues > 0 && this.state.gitIssues.L2Issues <= 5) {
                                    this.setState({
                                        gitIssueL2Status: {
                                            status: styles.YELLOW,
                                            desc: 'YELLOW : Number of L2 issues is greater than 0 and less than or equal to 5'
                                        }
                                    });
                                } else if (this.state.gitIssues.L2Issues > 5) {
                                    this.setState({
                                        gitIssueL2Status: {
                                            status: styles.RED,
                                            desc: 'RED : Number of L2 issues is greater than 5'
                                        }
                                    });
                                } else {
                                    this.setState({
                                        gitIssueL2Status: {
                                            status: styles.GREEN,
                                            desc: 'GREEN : No L2 issues open'
                                        }
                                    });
                                }

                                if (typeof this.state.gitIssues.L3Issues === 'undefined') {
                                    this.setState({
                                        gitIssueL3Status: {
                                            status: styles.GREY,
                                        }
                                    });
                                }
                                else if (this.state.gitIssues.L3Issues > 50) {
                                    this.setState({
                                        gitIssueL3Status: {
                                            status: styles.YELLOW,
                                            desc: 'YELLOW : No of L3 issues is greater than 50'
                                        }
                                    });
                                } else {
                                    this.setState({
                                        gitIssueL3Status: {
                                            status: styles.GREEN,
                                            desc: 'GREEN : No of L3 issues is less than or equal to 50'
                                        }
                                    })
                                }
                            }
                        );
                    }
                ).catch(error => {
                    console.log(error);
                });

            //Code coverage
            this.setState({
                codeCoverageLoading: true
            })
            axios.create({
                withCredentials: false,
            })
                .get(codeCoverageURL)
                .then(
                    res => {
                        this.setState({
                            codeCoverageLoading: false,
                            codeCoverage: res.data
                        },
                            function () {
                                if (this.state.codeCoverage.lineCov === '0') {
                                    return
                                }
                                if (this.state.codeCoverage.lineCov <= 40) {
                                    this.setState({
                                        codeCoverageStatus: {
                                            status: styles.RED,
                                            desc: 'RED : Line coverage is less than or equal to 40%'
                                        }
                                    });
                                } else if ((this.state.codeCoverage.lineCov > 40) && (this.state.codeCoverage.lineCov < 70)) {
                                    this.setState({
                                        codeCoverageStatus: {
                                            status: styles.YELLOW,
                                            desc: 'YELLOW : Line coverage is between 40% and 70%'
                                        }
                                    });
                                } else {
                                    this.setState({
                                        codeCoverageStatus: {
                                            status: styles.GREEN,
                                            desc: 'GREEN : Line coverage is greater than 70%'
                                        }
                                    });
                                }
                            }
                        );
                    }
                ).catch(error => {
                    console.log(error);
                });

            //Merged PR Count
            this.setState({
                mergedPRCountLoading: true
            });
            axios.create({
                withCredentials: false,
            })
                .get(mergedPRCountURL)
                .then(
                    res => {
                        this.setState({
                            mergedPRCountLoading: false,
                            mergedPRCount: res.data
                        },
                            function () {
                                if (typeof this.state.gitIssues.L1Issues === 'undefined') {
                                    return
                                }
                                if (this.state.mergedPRCount.mprCount > 20) {
                                    this.setState({
                                        mergedPRCountStatus: {
                                            status: styles.RED,
                                            desc: 'RED : Number of PRs with pending doc tasks is greater than 20'
                                        }
                                    });
                                } else {
                                    this.setState({
                                        mergedPRCountStatus: {
                                            status: styles.GREEN,
                                            desc: 'GREEN : Number of PRs with pending doc tasks is less than or equal to 20'
                                        }
                                    });
                                }
                            }
                        );
                    }
                ).catch(error => {
                    console.log(error);
                });

            //Dependency Summary
            this.setState({
                dependencySummaryLoading: true
            });
            axios.create({
                withCredentials: false,
            })
                .get(dependencyURL)
                .then(
                    res => {
                        this.setState({
                            dependencySummary: res.data,
                            dependencySummaryLoading: false
                        },
                            function () {
                                if (this.state.dependencySummary.dependencySummary < 10) {
                                    this.setState({
                                        dependencySummaryStatus: {
                                            status: styles.GREEN,
                                            desc: 'GREEN : Number of Dependencies is less than or equal to 10'
                                        }
                                    });
                                } else {
                                    this.setState({
                                        dependencySummaryStatus: {
                                            status: styles.RED,
                                            desc: 'RED : Number of Dependencies is greater than 10'
                                        }
                                    });
                                }
                            }
                        );
                    }
                ).catch(error => {
                    console.log(error);
                });
        }
    }

    resetState() {
        this.setState({
            jiraSecScan: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecScanStatus: { status: styles.GREY, desc: '' },

            jiraPerf: { totalIssues: '', openIssues: '', refLink: '' },
            jiraPerfStatus: { status: styles.GREY, desc: '' },

            jiraCommitment: { totalIssues: '', openIssues: '', refLink: '' },
            jiraCommitmentStatus: { status: styles.GREY, desc: '' },

            jiraSecCust: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecCustStatus: { status: styles.GREY, desc: '' },

            jiraSecExt: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecExtStatus: { status: styles.GREY, desc: '' },

            jiraSecInt: { totalIssues: '', openIssues: '', refLink: '' },
            jiraSecIntStatus: { status: styles.GREY, desc: '' },

            gitIssues: { L1Issues: '', L2Issues: '', L3Issues: '', refLink: '' },
            gitIssueL1Status: { status: styles.GREY, desc: '' },
            gitIssueL2Status: { status: styles.GREY, desc: '' },
            gitIssueL3Status: { status: styles.GREY, desc: '' },

            codeCoverage: {
                instructionCov: '', branchCov: '', complexityCov: '',
                lineCov: '', methodCov: '', classCov: '', refLink: ''
            },
            codeCoverageStatus: { status: styles.GREY, desc: '' },

            mergedPRCount: { mprCount: '', refLink: '' },
            mergedPRCountStatus: { status: styles.GREY, desc: '' },

            dependencySummary: { dependencySummary: '', refLink: '' },
            dependencySummaryStatus: { status: styles.GREY, desc: '' },
        })
    }

    render() {
        return (
            <div style={PageWrapper}>
                <div>
                    <h1> Release Readiness Metrics </h1>
                </div>
                <ColoredLine />
                <div style={styles.SelectDiv}>
                    {/* Product Name Select */}
                    <FormControl style={styles.FormControl}>
                        <InputLabel htmlFor="product-name"> Product Name </InputLabel>
                        <Select
                            value={this.state.selectedProductName}
                            onChange={this.handleChangeProductName}
                        >
                            {this.state.productNameList.map(
                                (product) => <MenuItem key={product} value={product}> {product} </MenuItem>
                            )}

                        </Select>
                    </FormControl>

                    {/* Product Version Select */}
                    {loadVersions(this.state.loading, this.state.productVersionList, this.state.selectedProductVersion, this.handleChangeProductVersion)}
                </div>

                {/* Table Div */}
                <div style={styles.TableDiv_style}>
                    <Table style={styles.TableBorder}>
                        <colgroup>
                            <col style={{ width: '20%' }} />
                            <col style={{ width: '50%' }} />
                            <col style={{ width: '30%' }} />
                        </colgroup>

                        <TableHead>
                            <TableRow style={{ height: 60 }}>
                                <TableCell style={styles.table.tableHead.tableCell}>  Status </TableCell>
                                <TableCell style={styles.table.tableHead.tableCell}> Metrics </TableCell>
                                <TableCell style={styles.table.tableHead.progressCell}> Progress </TableCell>
                            </TableRow>
                        </TableHead>

                        <TableBody>

                            { /* JIRA : Security Scan */}
                            <TableRow style={{ height: 70 }} >
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.jiraSecScanStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.jiraSecScanStatus.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows the Security Scan results"
                                        placement="top">
                                        <p>Security Scan Reports</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.jiraSecScanLoading, getJiraIssues(this.state.jiraSecScan))}
                                </TableCell>
                            </TableRow>

                            { /* JIRA : Performance Analysis */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.jiraPerfStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.jiraPerfStatus.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows the Performance Analysis Report results"
                                        placement="top">
                                        <p>Performance Analysis Report</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.jiraPerfLoading, getJiraIssues(this.state.jiraPerf))}
                                </TableCell>
                            </TableRow>

                            { /* JIRA : Commitment */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.jiraCommitmentStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.jiraCommitmentStatus.status}></span>
                                    </Tooltip>
                                </TableCell >
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip title="Shows the Customer Commitments" placement="top">
                                        <p>Customer Commitments</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.jiraCommitmentLoading, getJiraIssues(this.state.jiraCommitment))}
                                </TableCell>
                            </TableRow>

                            { /* JIRA : Security Customer */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.jiraSecCustStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.jiraSecCustStatus.status}> </span>
                                    </Tooltip>
                                </TableCell >
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows Security issues identified by Customers"
                                        placement="top">
                                        <p>Security issues by customers</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.jiraSecCustLoading, getJiraIssues(this.state.jiraSecCust))}
                                </TableCell>
                            </TableRow>

                            { /* JIRA : Security External */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.jiraSecExtStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.jiraSecExtStatus.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows Security issues identified by External security researchers and OSS users"
                                        placement="top">
                                        <p>Security issues by external testing</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.jiraSecExtLoading, getJiraIssues(this.state.jiraSecExt))}
                                </TableCell>
                            </TableRow>

                            { /* JIRA : Security Internal */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.jiraSecIntStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.jiraSecIntStatus.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows Security issues identified by Internal security testing"
                                        placement="top">
                                        <p>Security issues by internal testing</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.jiraSecIntLoading, getJiraIssues(this.state.jiraSecCust))}
                                </TableCell>
                            </TableRow>

                            { /* Git Issue : L1 */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.gitIssueL1Status.desc}
                                        placement="right-end">
                                        <span style={this.state.gitIssueL1Status.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Number of L1 issues"
                                        placement="top">
                                        <p> L1 Issues </p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.gitIssuesLoading, getGitIssues(this.state.gitIssues.L1Issues, this.state.gitIssues.refLink))}
                                </TableCell>
                            </TableRow>

                            { /* Git Issue : L2 */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.gitIssueL2Status.desc}
                                        placement="right-end">
                                        <span style={this.state.gitIssueL2Status.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Number of L2 issues"
                                        placement="top">
                                        <p> L2 Issues </p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.gitIssuesLoading, getGitIssues(this.state.gitIssues.L2Issues, this.state.gitIssues.refLink))}
                                </TableCell>
                            </TableRow>

                            { /* Git Issue : L3 */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.gitIssueL3Status.desc}
                                        placement="right-end">
                                        <span style={this.state.gitIssueL3Status.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Number of L3 issues"
                                        placement="top">
                                        <p> L3 Issues </p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.gitIssuesLoading, getGitIssues(this.state.gitIssues.L3Issues, this.state.gitIssues.refLink))}
                                </TableCell>
                            </TableRow>

                            { /* Code Coverage */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.codeCoverageStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.codeCoverageStatus.status}></span>
                                    </Tooltip>

                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows Code coverage statistics"
                                        placement="top">
                                        <p>Code coverage</p>
                                    </Tooltip>

                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.codeCoverageLoading, getCodeCoverage(this.state.codeCoverage))}
                                </TableCell>
                            </TableRow>

                            { /* Merged PR count Status */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.mergedPRCountStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.mergedPRCountStatus.status}></span>
                                    </Tooltip>

                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows number of Merged PRs with pending Documentaion tasks"
                                        placement="top">
                                        <p>Merged PRs with pending Doc tasks</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.mergedPRCountLoading, getMPRCount(this.state.mergedPRCount))}
                                </TableCell>
                            </TableRow>

                            { /* Dependency Summary */}
                            <TableRow>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title={this.state.dependencySummaryStatus.desc}
                                        placement="right-end">
                                        <span style={this.state.dependencySummaryStatus.status}></span>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.tableCell}>
                                    <Tooltip
                                        title="Shows number of Dependencies where the next verison available is smaller than a patch"
                                        placement="top">
                                        <p>Dependencies where the next version available is smaller than a patch</p>
                                    </Tooltip>
                                </TableCell>
                                <TableCell style={styles.table.tableBody.progressCell}>
                                    {loadData(this.state.dependencySummaryLoading, getDependencySummary(this.state.dependencySummary))}
                                </TableCell>
                            </TableRow>

                        </TableBody>
                    </Table>
                </div>
            </div>
        )
    };
}
