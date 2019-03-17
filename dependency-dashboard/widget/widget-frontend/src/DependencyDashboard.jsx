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
import VizG from 'react-vizgrammar';
import Widget from '@wso2-dashboards/widget';
import axios from 'axios';
import { Dropdown, DropdownToggle, DropdownMenu, DropdownItem } from 'reactstrap';
import MenuItem from '@material-ui/core/MenuItem';
import Input from '@material-ui/core/Input';
import { MuiThemeProvider, createMuiTheme } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import AbstractSelect from './AbstractSelect';
import './DependencyDashboard.css';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
const hostUrl = "https://" + window.location.host + window.contextPath + "/apis/dependency-data";

const darkTheme = createMuiTheme({
    palette: {
        type: 'dark'
    }
});

const lightTheme = createMuiTheme({
    palette: {
        type: 'light'
    }
});

const styles = theme => ({
    button: {
        display: 'block',
        marginTop: theme.spacing.unit * 2,
    },
    formControl: {
        margin: theme.spacing.unit,
        minWidth: 120,
    },
});
class DependencyDashboard extends Widget {
    constructor(props) {
        super(props);

        this.tableRows = {
            usingLatestVersion: 'Number of dependencies using the latest version available',
            nextVersion: 'Number of dependencies where the next version available is smaller than a patch version',
            nextIncremental: 'Number of dependencies where the next version available is an patch version update',
            nextMinor: 'Number of dependencies where the next version available is a minor version update',
            nextMajor: 'Number of dependencies where the next version available is a major version update',
        };

        this.state = {
            dependencyData: {},
            productData: {},
            width: this.props.glContainer.width,
            height: this.props.glContainer.height,
            selectedProduct: null,
            orgOpen: false,
            repoOpen: false,
            productOpen: false,
        };

        this.styles = {
            historicalDataButton: {
                position: 'absolute',
                right: 10,
                bottom: 10
            }
        };

        this.handleResize = this.handleResize.bind(this);
        this.props.glContainer.on('resize', this.handleResize);
        this.handleChange = this.handleChange.bind(this);
        this.handleClose = this.handleClose.bind(this);
        this.handleOpen = this.handleOpen.bind(this);
        this.calculateSelectedRepoSummery = this.calculateSelectedRepoSummery.bind(this);
        this.calculateSelectedProductSummery = this.calculateSelectedProductSummery.bind(this);
        this.calculateSelectedOrgSummery = this.calculateSelectedOrgSummery.bind(this);
    }
    handleResize() {
        this.setState({ width: this.props.glContainer.width, height: this.props.glContainer.height });
    }

    componentDidMount() {
        const dependencyDataPromise = axios.get(hostUrl + '/all');
        const productDataPromise = axios.get(hostUrl + '/product-data/all');

        Promise.all([dependencyDataPromise, productDataPromise])
            .then(response => {
                const productData = response[1].data.reduce((acc, data) => {
                    if (!acc[data.orgName]) {
                        acc[data.orgName] = {};
                        acc[data.orgName][data.productName] = {};
                    }
                    if (!acc[data.orgName][data.productName]) {
                        acc[data.orgName][data.productName] = {};
                    }
                    acc[data.orgName][data.productName][data.repoName] = data.repoName;
                    return acc;
                }, {});
                const dependencyDataInit = Object.assign(productData);
                const dependencyData = response[0].data.reduce((acc, data) => {
                    dependencyDataInit[data.orgName][data.productName][data.repoName] = data;
                    return acc;
                }, dependencyDataInit);
                this.setState({
                    dependencyData: dependencyData,
                    productData: productData,
                });
            })
            .catch(error => {
                console.error(error);
            })
    }

    handleChange(event, type) {
        switch (type) {
            case 'orgName':
                this.setState({
                    filteredProducts: this.state.productData[event.target.value],
                    selectedOrg: event.target.value,
                    selectedProduct: null,
                    selectedRepo: null,
                }, () => {
                    this.calculateSelectedOrgSummery();
                })
                break;
            case 'productName':
                this.setState({
                    filteredRepos: this.state.productData[event.target.value],
                    selectedProduct: event.target.value,
                    selectedRepo: null,
                }, this.calculateSelectedProductSummery)
                break;
            case 'repo':
                this.setState({
                    selectedRepo: event.target.value
                }, this.calculateSelectedRepoSummery)
                break;
            default:
        }
    };

    handleClose(type) {
        switch (type) {
            case 'orgName':
                this.setState({ orgOpen: false });
                break;
            case 'productName':
                this.setState({ productOpen: false });
                break;
            case 'repo':
                this.setState({ repoOpen: false });
                break;
            default:
        }
    };

    calculateSelectedOrgSummery() {
        const { dependencyData, selectedOrg } = this.state;
        const products = dependencyData[selectedOrg];

        const { nextIncremental, nextMajor, nextMinor, nextVersion, usingLatestVersion } = Object.keys(products).reduce((acc, product) => {
            const productObject = products[product];
            const temp = Object.keys(productObject).map(repo => {
                const repObject = productObject[repo];
                if (typeof (repObject) === 'object') {
                    acc['nextIncremental'] = acc['nextIncremental'] + repObject['nextIncremental'];
                    acc['nextMajor'] = acc['nextMajor'] + repObject['nextMajor'];
                    acc['nextMinor'] = acc['nextMinor'] + repObject['nextMinor'];
                    acc['nextVersion'] = acc['nextVersion'] + repObject['nextVersion'];
                    acc['usingLatestVersion'] = acc['usingLatestVersion'] + repObject['usingLatestVersion'];
                }
                return acc
            });
            return acc;
        }, {
            nextIncremental: 0,
            nextMajor: 0,
            nextMinor: 0,
            nextVersion: 0,
            usingLatestVersion: 0
        });

        this.setState({
            nextIncremental: nextIncremental,
            nextMajor: nextMajor,
            nextMinor: nextMinor,
            nextVersion: nextVersion,
            usingLatestVersion: usingLatestVersion
        });
    }
    calculateSelectedRepoSummery() {
        const { dependencyData, selectedOrg, selectedProduct, selectedRepo } = this.state;
        const { nextIncremental, nextMajor, nextMinor, nextVersion, usingLatestVersion } = dependencyData[selectedOrg][selectedProduct][selectedRepo];
        this.setState({
            nextIncremental: nextIncremental,
            nextMajor: nextMajor,
            nextMinor: nextMinor,
            nextVersion: nextVersion,
            usingLatestVersion: usingLatestVersion
        });
    }

    calculateSelectedProductSummery() {
        const { dependencyData, selectedOrg, selectedProduct } = this.state;
        const repos = dependencyData[selectedOrg][selectedProduct];

        const { nextIncremental, nextMajor, nextMinor, nextVersion, usingLatestVersion } = Object.keys(repos).reduce((acc, repo) => {
            const repObject = repos[repo];
            if (typeof (repObject) === 'object') {
                acc['nextIncremental'] = acc['nextIncremental'] + repObject['nextIncremental'];
                acc['nextMajor'] = acc['nextMajor'] + repObject['nextMajor'];
                acc['nextMinor'] = acc['nextMinor'] + repObject['nextMinor'];
                acc['nextVersion'] = acc['nextVersion'] + repObject['nextVersion'];
                acc['usingLatestVersion'] = acc['usingLatestVersion'] + repObject['usingLatestVersion'];
            }
            return acc;
        }, {
            nextIncremental: 0,
            nextMajor: 0,
            nextMinor: 0,
            nextVersion: 0,
            usingLatestVersion: 0
        });

        this.setState({
            nextIncremental: nextIncremental,
            nextMajor: nextMajor,
            nextMinor: nextMinor,
            nextVersion: nextVersion,
            usingLatestVersion: usingLatestVersion
        });
    }

    handleOpen(type) {
        switch (type) {
            case 'orgName':
                this.setState({ orgOpen: true });
                break;
            case 'productName':
                this.setState({ productOpen: true });
                break;
            case 'repo':
                this.setState({ repoOpen: true });
                break;
            default:
        }
    };
    render() {
        const { dependencyData, productData, selectedOrg, selectedProduct, selectedRepo } = this.state;
        const { nextIncremental, nextMajor, nextMinor, nextVersion, usingLatestVersion } = this.state;

        const organizationList = productData ? Object.keys(productData).map(key => {
            return <MenuItem value={key}>{key}</MenuItem>;
        }) : <MenuItem value={'None'}>None</MenuItem>;

        const productList = selectedOrg ? Object.keys(productData[selectedOrg]).map(key => {
            return <MenuItem value={key}>{key}</MenuItem>;
        }) : '';

        const repoList = selectedOrg && selectedProduct && productData[selectedOrg][selectedProduct] ?
            Object.keys(productData[selectedOrg][selectedProduct]).map(key => {
                return <MenuItem value={key}>{key}</MenuItem>;
            }) : '';

        const tableRowList = dependencyData ? Object.keys(this.tableRows).map((key, index) => {
            let color = { 'color': '#fffff' }
            if (key === 'usingLatestVersion') {
                color = { 'color': '#23cba7' };
            } else if (key === 'nextVersion' || key === 'nextIncremental' || key === 'nextMinor') {
                color = { 'color': '#e74c3c' }
            }
            return (<TableRow key={index}>
                <TableCell style={color} component="th" scope="row">
                    {this.tableRows[key]}
                </TableCell>
                <TableCell numeric>{this.state[key] ? this.state[key] : 0}</TableCell>
            </TableRow>);
        }) : '';
        return (
            <div className='main'>
                <MuiThemeProvider
                    theme={this.props.muiTheme.name === 'dark' ? darkTheme : lightTheme}>
                    <h1 style={{ 'text-align': 'center' }}>Dependency Summary Dashboard</h1>
                    <FormControl className='form'>
                        <div className='select-wrap'>
                            <InputLabel htmlFor="orgSelect">{'Select Organization'}</InputLabel>
                            <AbstractSelect organizationList={organizationList} selectedItem={selectedOrg}
                                            open={this.state.orgOpen} handleClose={() => { this.handleClose('orgName') }} handleOpen={() => this.handleOpen('orgName')}
                                            handleChange={(e) => this.handleChange(e, 'orgName')} />
                        </div>
                        <div className='select-wrap'>
                            <InputLabel htmlFor="productSelect">{'Select Product'}</InputLabel>
                            <AbstractSelect organizationList={productList} selectedItem={selectedProduct}
                                            open={this.state.productOpen} handleClose={() => this.handleClose('productName')} handleOpen={() => this.handleOpen('productName')}
                                            handleChange={(e) => this.handleChange(e, 'productName')} />
                        </div>

                        <div className='select-wrap'>
                            <InputLabel htmlFor="repoSelect">{'Select repo'}</InputLabel>
                            <AbstractSelect organizationList={repoList} selectedItem={selectedRepo}
                                            open={this.state.repoOpen} handleClose={() => this.handleClose('repo')} handleOpen={() => this.handleOpen('repo')}
                                            handleChange={(e) => this.handleChange(e, 'repo')} />
                        </div>
                    </FormControl>

                    <Paper className='table'>
                        <Table >
                            <TableHead>
                                <TableRow >
                                    <TableCell style={{
                                        color: '#33b5e5'
                                    }} >Description</TableCell>
                                    <TableCell style={{
                                        color: '#33b5e5'
                                    }} numeric>Matric</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {tableRowList}
                            </TableBody>
                        </Table>
                    </Paper>
                </MuiThemeProvider>
            </div>
        );
    }
}

global.dashboard.registerWidget("DependencyDashboard", DependencyDashboard);
