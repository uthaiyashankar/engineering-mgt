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
import './App.css';
import Checklist_img from './imgs/checkList_img.png';
import MPRDas_img from './imgs/mprDas_img.png';
import codeCoverage_img from './imgs/codeCoverage_img.png';
import dependencyDas_img from './imgs/dependencyDas_img.png';
import gitIssues_img from './imgs/gitIssues_img.png';

const styles = {
  images: {
    height: '300px',
    width: '350px',
    margin: '30px 50px 10px 30px',
    border: '1px solid #3f51b5'
  }
};
const PageWrapper = {
  padding: '20px',
  background: '#fff',
  boxShadow: 'none',
  color: '#3f51b5',
  textAlign: 'center'
};

const ColoredLine = ({ color }) => (
  <hr
    style={{
      backgroundColor: '#3f51b5',
      height: 2
    }}
  />
);

class App extends Component {
  render() {
    return (
      <div className="App">
        <div style={PageWrapper}>
          <h1 style={{ color: '#3f51b5' }}> Release Readiness Dashboards </h1>
          <ColoredLine />
        </div>
        <div style={{ display: 'inline-block' }}>
          <a
            href={process.env.REACT_APP_checkList}
            target="_blank"
            rel="noopener noreferrer"
          >
            <img
              style={styles.images}
              src={Checklist_img}
              alt="Checklist Dashboard"
            />
            <figcaption> Release Readiness Metrics Dashboard</figcaption>
          </a>
        </div>
        <div style={{ display: 'inline-block' }}>
          <a
            href={process.env.REACT_APP_codeCoverage}
            target="_blank"
            rel="noopener noreferrer"
          >
            <img
              style={styles.images}
              src={codeCoverage_img}
              alt="Code Coverage Dashboard"
            />
            <figcaption> Code Coverage Dashboard</figcaption>
          </a>
        </div>
        <div style={{ display: 'inline-block' }}>
          <a
            href={process.env.REACT_APP_MPRDas}
            target="_blank"
            rel="noopener noreferrer"
          >
            <img style={styles.images} src={MPRDas_img} alt="MPR Dashboard" />
            <figcaption> Merged PR Dashboard</figcaption>
          </a>
        </div>
        <div style={{ display: 'inline-block' }}>
          <a
            href={process.env.REACT_APP_gitIssues}
            target="_blank"
            rel="noopener noreferrer"
          >
            <img
              style={styles.images}
              src={gitIssues_img}
              alt="Git Issue Dashboard"
            />
            <figcaption> Git Issues Monitoring Dashboard</figcaption>
          </a>
        </div>
        <div style={{ display: 'inline-block' }}>
          <a
            href={process.env.REACT_APP_dependencyDas}
            target="_blank"
            rel="noopener noreferrer"
          >
            <img
              style={styles.images}
              src={dependencyDas_img}
              alt="Dependency Dashboard"
            />
            <figcaption> Dependency Dashboard</figcaption>
          </a>
        </div>
      </div>
    );
  }
}

export default App;
