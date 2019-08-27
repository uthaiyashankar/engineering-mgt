/*
 *  Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import Paper from '@material-ui/core/Paper';
import Select from '@material-ui/core/Select';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import axios from 'axios';
import appendQuery from 'append-query';
import './index.css';

const PageWrapper = withStyles({
    root: {
        padding: '30px',
        background: 'transparent',
        boxShadow: 'none',
        textAlign: 'center',
        color: '#3f51b5'
    },
})(Paper);

const styles = {
    table: {
        tableHead: {
            statusCell: {
                backgroundColor: '#3f51b5',
                color: 'white',
                fontWeight: 700,
                fontSize: '20px',
            },
            countCell: {
                backgroundColor: '#3f51b5',
                color: 'white',
                fontWeight: 700,
                fontSize: '20px',
                textAlign: 'right'
            }
        },
        tableBody: {
            statusCell: {
                fontSize: '18px',
                color: '#3f51b5',
            },
            countCell: {
                fontSize: '18px',
                color: '#3f51b5',
                textAlign: 'right',
                cursorPointer: {
                    cursor: 'pointer'
                },
                cursorText: {
                    cursor: 'text'
                },
            },
            statusCellTotal: {
                fontSize: '18px',
                fontWeight: 700,
                borderTop: '2pt solid #3f51b5',
                color: '#3f51b5',
            },
            countCellTotal: {
                fontSize: '18px',
                fontWeight: 700,
                borderTop: '2pt solid #3f51b5',
                color: '#3f51b5',
                textAlign: 'right'
            }
        },
        TableBody: {
            display: 'block',
            width: '100%',
            overflow: 'auto',
            height: '100px'
        }
    },
    TableBorder: {
        border: '2px solid #aaa',
        borderColor: '#3f51b5'
    },
    formControl: {
        margin: '0 20px 30px 0',
        minWidth: 200,
    },
    selectDiv: {
        overflowX: "auto",
        padding: '5px',
        textAlign: 'left',

    },
};

const ColoredLine = ({ color }) => (
    <hr
        style={{
            backgroundColor: '#3f51b5',
            height: 2
        }}
    />
);

export default class MPRSummary extends Component {
    constructor(props, context) {
        super(props);
        this.state = {
            order: 'desc',
            rows: [
                ['Not Started', 0],
                ['Draft Received', 0],
                ['No Draft', 0],
                ['In-progress', 0],
                ['Issues Pending', 0]
            ],
            selectedProduct: '',
            selectedVersion: '',
            totalPRCount: 0,
            products: [],
            versions: []
        };
        this.handleChangeVersion = this.handleChangeVersion.bind(this);
        this.handleChangeProduct = this.handleChangeProduct.bind(this);
        this.loadVersions = this.loadVersions.bind(this);
        this.loadPRTable = this.loadPRTable.bind(this);
        this.clearTable = this.clearTable.bind(this);
        this.clearVersion = this.clearVersion.bind(this);
        this.handleRowClick = this.handleRowClick.bind(this);
    }

    /**
     * Clear MPR count table
     * */
    clearTable() {
        let rows = [
            ['Not Started', 0],
            ['Draft Received', 0],
            ['No Draft', 0],
            ['In-progress', 0],
            ['Issues Pending', 0]
        ];
        this.setState({ rows, totalPRCount: 0 });
    }

    /**
     * Clear version selector
     * */
    clearVersion() {
        this.setState({ selectedVersion: '' });
    }

    /**
     * Retrieve products from the API
     * */
    loadProducts() {
        const getProductsUrl = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/products';
        axios
            .get(getProductsUrl)
            .then(response => {
                if (response.hasOwnProperty('data')) {
                    this.setState({
                        products: Object.values(response.data.data),
                        selectedProduct: this.state.selectedProduct,
                    });
                    this.loadVersions(this.state.selectedProduct);
                } else {
                    console.error('No data in products.');
                }
            })
            .catch(error => {
                this.setState({
                    faultyProviderConf: true
                });
            });
    }

    /**
     * Retrieve versions of the prodcuts
     * */
    loadVersions(product) {
        const url = 'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/versions?product=' + product;
        axios
            .get(url)
            .then(response => {
                if (response.hasOwnProperty('data')) {
                    let versions = Object.values(response.data.data);
                    versions.unshift('All');
                    this.setState({
                        versions: versions,
                        //selectedVersion: versions[0]
                    });
                    this.loadPRTable(product, this.state.selectedVersion);
                } else {
                    console.error('Versions not available.');
                }
            })
            .catch(error => {
                this.setState({
                    faultyProviderConf: true
                });
            });
    }

    /* *
     * Retrieve MPR count based on product & version
     * */
    loadPRTable(productName, prodVersion) {
        let count = 0;
        let url =
            'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/prcount?product=' +
            productName +
            '&version=' +
            prodVersion;
        axios
            .get(url)
            .then(response => {
                if (response.hasOwnProperty('data')) {
                    let newRows = this.state.rows.slice(0);
                    response.data.data.forEach(record => {
                        for (var i = 0; i < newRows.length; i++) {
                            if (record.docStatus === i) {
                                newRows[i][1] = record.count;
                            }
                        }
                    });
                    // Retrieve total PR count for given product-version
                    let totCountUrl =
                        'http://' + process.env.REACT_APP_HOST + ':' + process.env.REACT_APP_PORT + '/totalprcount?product=' +
                        productName +
                        '&version=' +
                        prodVersion;
                    axios
                        .get(totCountUrl)
                        .then(response => {
                            if (response.hasOwnProperty('data')) {
                                count = response.data.data.count;
                                // set the MPR count for each status and total for each product-version
                                this.setState({ rows: newRows, totalPRCount: count });
                            } else {
                                console.error('Cannot retrieve total PR count.');
                            }
                        })
                        .catch(error => {
                            this.setState({
                                faultyProviderConf: true
                            });
                        });
                } else {
                    console.error('Cannot retrieve PRs.');
                }
            })
            .catch(error => {
                this.setState({
                    faultyProviderConf: true
                });
            });
    }

    /**
     * Handle product change in product-selector
     * */
    handleChangeProduct(event) {
        this.setState({ selectedProduct: event.target.value });
        this.clearVersion();
        this.clearTable();
        this.loadVersions(event.target.value);
    }

    /**
     * Handle changes in the version selector
     * */
    handleChangeVersion(event) {
        this.setState({ selectedVersion: event.target.value });
        this.clearTable();
        this.loadPRTable(this.state.selectedProduct, event.target.value);
    }

    handleRowClick(e, data) {
        let status = ['Not Started', 'Draft Received', 'No Draft', 'In-progress', 'Issues Pending']
        if (data[1] === 0) {
            alert('No Merged PRs');
            return;
        }
        let docStat = data[0];
        for (var i = 0; i < status.length; i++) {
            if (docStat === status[i]) {
                docStat = i
            }
        }

        let info = {
            product: this.state.selectedProduct,
            version: this.state.selectedVersion,
            status: docStat,
            start: new Date(2018, 0, 1).toISOString(),
            end: new Date().toISOString()
        }
        var mprDashboardUrl = 'https://identity-internal-gateway.cloud.wso2.com/t/wso2internal928/mprdash'
        let redirectUrl = appendQuery(mprDashboardUrl, info);
        window.open(redirectUrl);
    }

    componentDidMount() {
        this.loadProducts();
    }


    /**
     * Render MPR Summary widget with selectors and table
     * */
    render() {
        const { rows, products, versions, totalPRCount } = this.state;

        return (
            <PageWrapper>
                <div><h1>Doc status of Merged PRs</h1></div>
                <ColoredLine />

                {/* Product selector */}
                <div style={styles.selectDiv}>
                    {/* Product Name Select */}
                    <FormControl style={styles.formControl}>
                        <InputLabel htmlFor="product-name">Product Name</InputLabel>
                        <Select
                            value={this.state.selectedProduct}
                            onChange={this.handleChangeProduct}
                        >
                            {products.map(
                                (product) => <MenuItem key={product} value={product}> {product} </MenuItem>
                            )}

                        </Select>
                    </FormControl>

                    {/* Product Version Select */}
                    <FormControl style={styles.formControl}>
                        <InputLabel htmlFor="product-version">Product Version</InputLabel>
                        <Select
                            disabled={this.state.versions.length === 0}
                            value={this.state.selectedVersion}
                            onChange={this.handleChangeVersion}
                        >
                            {versions.map(
                                (version) => <MenuItem key={version} value={version}> {version} </MenuItem>
                            )}

                        </Select>
                    </FormControl>
                </div>


                {/* MPR summary table */}
                <Paper>
                    <div>
                        <Table style={styles.TableBorder}>
                            <TableHead>
                                <TableRow>
                                    <TableCell style={styles.table.tableHead.statusCell}>
                                        Doc Status
                                    </TableCell>
                                    <TableCell style={styles.table.tableHead.countCell}>
                                        MPR count
                                    </TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {rows.map(row => {
                                    return (
                                        <TableRow
                                            key={row}
                                            style={
                                                row[1] > 0
                                                    ? styles.table.tableBody.countCell.cursorPointer
                                                    : styles.table.tableBody.countCell.cursorText
                                            }
                                            hover
                                            onClick={e => {
                                                if (row[1] === 0) {
                                                    return;
                                                } else {
                                                    this.handleRowClick(e, row);
                                                }
                                            }}
                                        >
                                            <TableCell style={styles.table.tableBody.statusCell}>
                                                {row[0]}
                                            </TableCell>
                                            <TableCell style={styles.table.tableBody.countCell}>
                                                {row[1]}
                                            </TableCell>
                                        </TableRow>
                                    );
                                })}
                                <TableRow>
                                    <TableCell style={styles.table.tableBody.statusCellTotal}>
                                        Total no of merged PRs with pending documentation tasks
                  </TableCell>
                                    <TableCell style={styles.table.tableBody.countCellTotal}>
                                        {totalPRCount}
                                    </TableCell>
                                </TableRow>
                            </TableBody>
                        </Table>
                    </div>
                </Paper>
            </PageWrapper>
        );
    }
}
