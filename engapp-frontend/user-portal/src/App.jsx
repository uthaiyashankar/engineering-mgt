
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
import './App.css';
import Grid from '@material-ui/core/Grid';
import Container from '@material-ui/core/Container';
import Paper from '@material-ui/core/es/Paper/Paper';
import { withStyles } from '@material-ui/core/styles';
import Popup from './components/Popup';
import IssuesPerTeamTable from './components/IssuesPerTeamTable';
import IssuesForlabelsChart from './components/IssuesForlabelsChart';
import OpenVsClosedGraph from './components/OpenVsClosedChart';
import IssuesAgingGraph from './components/IssuesAgingGraph';

const PageWrapper = withStyles({
  root: {
    padding: '0px 0px 0px px',
    background: 'white',
    boxShadow: 'none',
    textAlign: 'center',
    color: '#3f51b5'
  }
})(Paper);

class App extends Component {
  constructor(props) {
    super(props);
    this.state = { showPopup: false, content: null };
    this.togglePopup = this.togglePopup.bind(this);
  }

  togglePopup(data) {
    this.setState({
      showPopup: !this.state.showPopup,
      content: data
    });
  }

  closePopup() {
    this.setState({
      showPopup: false
    });
  }

  render() {
    return (
      <PageWrapper>
        <div class="heading"> Git Issues Monitoring Dashboard</div>
        <div class="outerDivBorder">
          <React.Fragment>
            {this.state.showPopup && (
              <Popup
                text={this.state.content}
                closePopup={this.closePopup.bind(this)}
              />
            ) }
            <Container fixed>
              <Grid item xs={12} container>
                <Grid xs={12} md={6} lg={6}>
                  <div
                    onClick={e =>
                      this.togglePopup(
                        <PageWrapper>
                          <h1>Issues Count for team</h1>
                          <div class="popDivBorder ">
                            <IssuesPerTeamTable height={100} />
                          </div>
                        </PageWrapper>
                      )
                    }
                  >
                    <PageWrapper>
                      <h1>Issues Count for team</h1>
                      <div className="divBoarder">
                        <IssuesPerTeamTable height={100} />
                      </div>
                    </PageWrapper>
                  </div>
                </Grid>
                <Grid xs={12} md={6} lg={6}>
                  <div class="col-6 col-s-6">
                    <div
                      onClick={e =>
                        this.togglePopup(
                          <PageWrapper>
                            <h1>Issues Count by Severity</h1>
                            <div class="popDivBorder ">
                              <IssuesForlabelsChart height={520} />
                            </div>
                          </PageWrapper>
                        )
                      }
                    >
                      <PageWrapper>
                        <h1>Issues Count by Severity</h1>
                        <div className="divBoarder">
                          <IssuesForlabelsChart height={300} />
                        </div>
                      </PageWrapper>
                    </div>
                  </div>
                </Grid>
              </Grid>
              <Grid item xs={12} md={12} lg={12} container>
                <Grid xs={12} md={6} lg={6}>
                  <div
                    onClick={e =>
                      this.togglePopup(
                        <PageWrapper>
                          <h1>Open vs Closed Chart</h1>
                          <div class="popDivBorder ">
                            <OpenVsClosedGraph height={520} />
                          </div>
                        </PageWrapper>
                      )
                    }
                  >
                    <PageWrapper>
                      <h1>Open vs Closed Chart</h1>
                      <div className="divBoarder">
                        <OpenVsClosedGraph />
                      </div>
                    </PageWrapper>
                  </div>
                </Grid>
                <Grid xs={12} md={6} lg={6}>
                  <div
                    onClick={e =>
                      this.togglePopup(
                        <PageWrapper>
                          <h1>Issues Aging Graph</h1>
                          <div class="popDivBorder ">
                            <IssuesAgingGraph height={520} />
                          </div>
                        </PageWrapper>
                      )
                    }
                  >
                    <PageWrapper>
                      <h1>Issues Aging Graph</h1>
                      <div className="divBoarder">
                        <IssuesAgingGraph height={300} />
                      </div>
                    </PageWrapper>
                  </div>
                </Grid>
              </Grid>
            </Container>
          </React.Fragment>
        </div>
      </PageWrapper>
    );
  }
}
export default App;
