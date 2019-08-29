/*
 * Copyright (c) 2019, WSO2 Inc. (http://wso2.com) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import React, { Component } from 'react';
import MenuItem from '@material-ui/core/MenuItem';
import { MuiThemeProvider, createMuiTheme } from '@material-ui/core/styles';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import Button from '@material-ui/core/Button';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import { withStyles } from '@material-ui/core/styles';
import axios from 'axios';
import Select from '@material-ui/core/Select';
import './components/css/DependencyDashboard.css';

const hostUrl =
  'http://' +
  process.env.REACT_APP_HOST +
  ':' +
  process.env.REACT_APP_PORT +
  '/dependency-data';
const lightTheme = createMuiTheme({
  palette: { 
    type: 'light'
  }
});

const AbstractSelect = props => {
    return (
      <div>
        <Select
          className='select'
          open={props.open}
          onClose={props.handleClose}
          onOpen={props.handleOpen}
          value={props.selectedItem}
          onChange={props.handleChange}
        >
          {props.organizationList}
        </Select>
      </div>
    );
  };

const PageWrapper = withStyles({
  root: {
    padding: '30px',
    background: 'transparent',
    boxShadow: 'none',
    textAlign: 'center'
  }
})(Paper);

class DependencyDashboard extends Component {
  constructor(props) {
    super(props);
    this.tableRows = {
      usingLatestVersion:
        'Number of dependencies using the latest version available',
      nextVersion:
        'Number of dependencies where the next version available is smaller than a patch version',
      nextIncremental:
        'Number of dependencies where the next version available is an patch version update',
      nextMinor:
        'Number of dependencies where the next version available is a minor version update',
      nextMajor:
        'Number of dependencies where the next version available is a major version update'
    };

    this.state = {
      dependencyData: {},
      productData: {},
      selectedProduct: null,
      selectedOrg: null,
      orgOpen: false,
      repoOpen: false,
      productOpen: false
    };

    
    this.calculateSelectedRepoSummery = this.calculateSelectedRepoSummery.bind(
      this
    );
    this.calculateSelectedProductSummery = this.calculateSelectedProductSummery.bind(
      this
    );
    this.calculateSelectedOrgSummery = this.calculateSelectedOrgSummery.bind(
      this
    );
  }

  componentDidMount() {
    const dependencyDataPromise = axios.get(hostUrl + '/all');
    const productDataPromise = axios.get(hostUrl + '/product-data/all');
    Promise.all([dependencyDataPromise, productDataPromise])
      .then(response => {
        const productData = response[1].data.reduce((acc, data) => {
          
            acc[data.orgName] = acc[data.orgName] || {};
            acc[data.orgName][data.productName] = acc[data.orgName][data.productName] || {};
          
          
            acc[data.orgName][data.productName] = acc[data.orgName][data.productName] || {};
          
          acc[data.orgName][data.productName][data.repoName] = data.repoName;
          return acc;
        }, {});
        const dependencyDataInit = Object.assign(productData);
        const dependencyData = response[0].data.reduce((acc, data) => {
          dependencyDataInit[data.orgName][data.productName][
            data.repoName
          ] = data;
          return acc;
        }, dependencyDataInit);
        this.setState({
          dependencyData,
          productData
        });
      })
      .catch(error => {
        console.error(error);
      });
  }

  isEmpty(obj) {
    return Object.keys(obj).length === 0;
  }

  handleChange(event, type) {
    switch (type) {
      case 'orgName':
        this.setState(
          {
            filteredProducts: this.state.productData[event.target.value],
            selectedOrg: event.target.value,
            selectedProduct: null,
            selectedRepo: null
          },
          
            this.calculateSelectedOrgSummery
          
        );
        break;
      case 'productName':
        this.setState(
          {
            filteredRepos: this.state.productData[event.target.value],
            selectedProduct: event.target.value,
            selectedRepo: null
          },
          this.calculateSelectedProductSummery
        );
        break;
      case 'repo':
        this.setState(
          {
            selectedRepo: event.target.value
          },
          this.calculateSelectedRepoSummery
        );
        break;
      default:
    }
  }

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
  }

  calculateSelectedOrgSummery() {
    const { dependencyData, selectedOrg } = this.state;
    const products = dependencyData[selectedOrg];

    const {
      nextIncremental,
      nextMajor,
      nextMinor,
      nextVersion,
      usingLatestVersion
    } = Object.keys(products).reduce(
      (acc, product) => {
        const productObject = products[product];
        Object.keys(productObject).map(repo => {
          const repObject = productObject[repo];

          if (typeof repObject === 'object') {
            acc['nextIncremental'] += repObject['nextIncremental'];
            acc['nextMajor'] += repObject['nextMajor'];
            acc['nextMinor'] += repObject['nextMinor'];
            acc['nextVersion'] += repObject['nextVersion'];
            acc['usingLatestVersion'] += repObject['usingLatestVersion'];
          }
          return acc;
        });
        return acc;
      },
      {
        nextIncremental: 0,
        nextMajor: 0,
        nextMinor: 0,
        nextVersion: 0,
        usingLatestVersion: 0
      }
    );

    this.setState({
      nextIncremental: nextIncremental,
      nextMajor: nextMajor,
      nextMinor: nextMinor,
      nextVersion: nextVersion,
      usingLatestVersion: usingLatestVersion
    });
  }
  calculateSelectedRepoSummery() {
    const {
      dependencyData,
      selectedOrg,
      selectedProduct,
      selectedRepo
    } = this.state;
    const {
      nextIncremental,
      nextMajor,
      nextMinor,
      nextVersion,
      usingLatestVersion
    } = dependencyData[selectedOrg][selectedProduct][selectedRepo];
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

    const {
      nextIncremental,
      nextMajor,
      nextMinor,
      nextVersion,
      usingLatestVersion
    } = Object.keys(repos).reduce(
      (acc, repo) => {
        const repObject = repos[repo];
        console.log('repo objetct' + repObject);
        if (typeof repObject === 'object') {
          acc['nextIncremental'] += repObject['nextIncremental'];
          acc['nextMajor'] +=  repObject['nextMajor'];
          acc['nextMinor'] += repObject['nextMinor'];
          acc['nextVersion'] +=  repObject['nextVersion'];
          acc['usingLatestVersion'] += repObject['usingLatestVersion'];
        }
        return acc;
      },
      {
        nextIncremental: 0,
        nextMajor: 0,
        nextMinor: 0,
        nextVersion: 0,
        usingLatestVersion: 0
      }
    );

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
  }
  render() {
    const {
      dependencyData,
      productData,
      selectedOrg,
      selectedProduct,
      selectedRepo
    } = this.state;

    const lastReportUrl = this.state.selectedRepo
      ? 'https://wso2.org/jenkins/view/sonar/job/sonar/job/sonar-' +
        this.state.selectedRepo +
        '/Dependency_20Report/'
      : '';

    const organizationList = productData ? (
      Object.keys(productData).map(key => {
        return <MenuItem value={key}>{key}</MenuItem>;
      })
    ) : (
      <MenuItem value={'None'}>None</MenuItem>
    );

    const productList = selectedOrg
      ? Object.keys(productData[selectedOrg]).map(key => {
          return <MenuItem value={key}>{key}</MenuItem>;
        })
      : '';

    const repoList =
      selectedOrg &&
      selectedProduct &&
      productData[selectedOrg][selectedProduct]
        ? Object.keys(productData[selectedOrg][selectedProduct]).map(key => {
            return <MenuItem value={key}>{key}</MenuItem>;
          })
        : '';

    const tableRowList = dependencyData
      ? Object.keys(this.tableRows).map((key, index) => {
          let style = { color: '#0c29ac', height: 'auto', fontSize: '20px' };
          if (key === 'usingLatestVersion') {
            style = { color: '#07791a', height: 'auto', fontSize: '20px' };
          } else if (
            key === 'nextVersion' ||
            key === 'nextIncremental' ||
            key === 'nextMinor'
          ) {
            style = { color: '#ca2508', height: '30px', fontSize: '20px' };
          }
          return (
            <TableRow key={index}>
              <TableCell style={style} component='th' scope='row'>
                {this.tableRows[key]}
              </TableCell>
              <TableCell numeric style={{textAlign: 'right'}}>
                  
                {this.state[key] ? this.state[key] : 0}
              </TableCell>
            </TableRow>
          );
        })
      : '';
    return (
      <PageWrapper>
        <div className='main'>
          <MuiThemeProvider theme={lightTheme}>
            <FormControl className='form'>
              <div className='select-wrap' >
                <InputLabel htmlFor='orgSelect'>{'Organization'}</InputLabel>
                <AbstractSelect
                  organizationList={organizationList}
                  selectedItem={selectedOrg}
                  open={this.state.orgOpen}
                  handleClose={() => {
                    this.handleClose('orgName');
                  }}
                  handleOpen={() => this.handleOpen('orgName')}
                  handleChange={e => this.handleChange(e, 'orgName')}
                />
              </div>
              <div className='select-wrap'>
                <InputLabel htmlFor='productSelect'>{'Product'}</InputLabel>
                <AbstractSelect
                  organizationList={productList}
                  selectedItem={selectedProduct}
                  open={this.state.productOpen}
                  handleClose={() => this.handleClose('productName')}
                  handleOpen={() => this.handleOpen('productName')}
                  handleChange={e => this.handleChange(e, 'productName')}
                />
              </div>

              <div className='select-wrap'>
                <InputLabel htmlFor='repoSelect'>{'Repo'}</InputLabel>
                <AbstractSelect
                  organizationList={repoList}
                  selectedItem={selectedRepo}
                  open={this.state.repoOpen}
                  handleClose={() => this.handleClose('repo')}
                  handleOpen={() => this.handleOpen('repo')}
                  handleChange={e => this.handleChange(e, 'repo')}
                />
              </div>
            </FormControl>
            <Paper className='table'>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell
                      style={{
                        color: 'white',
                        fontSize: '22px',
                        backgroundColor: '#060674'
                      }}
                    >
                      Description
                    </TableCell>
                    <TableCell
                      style={{
                        color: 'white',
                        fontSize: '22px',
                        backgroundColor: '#060674',
                        textAlign: 'right'
                      }}
                      numeric
                    >
                      Matric
                    </TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>{tableRowList}</TableBody>
              </Table>
            </Paper>

            {this.state.selectedRepo ? (
              <Button href={lastReportUrl} className='a'>
                Click to view lastest report
              </Button>
            ) : (
              ''
            )}
          </MuiThemeProvider>
        </div>
      </PageWrapper>
    );
  }
}

export default DependencyDashboard;
