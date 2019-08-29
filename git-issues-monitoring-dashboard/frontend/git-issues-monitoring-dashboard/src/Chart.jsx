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
import { Bar } from 'react-chartjs-2';
import axios from 'axios';
import moment from 'moment';


//var randomColor = require('randomcolor'); // import the script
class Chart extends Component {
  constructor(props) {
    super(props);
    this.state = {
      chartData: {},
      timeStamp: ''
    };
  }

  static defaultProps = {
    displayTitle: true,
    displayLegend: true,
    legendPosition: 'bottom',
    chartName: 'Git Issue'
  };

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
      .then(res => {
        var response = res.data;
        var ProductName = response.map(function(e) {
          return e.ProductName;
        });
        var L1IssueCount = response.map(function(e) {
          return e.L1IssueCount;
        });
        var L2IssueCount = response.map(function(e) {
          return e.L2IssueCount;
        });
        var L3IssueCount = response.map(function(e) {
          return e.L3IssueCount;
        });

        this.setState({
          timeStamp: moment
            .unix(res.data[0]['TimeStamp'] / 1000)
            .format('YYYY-MM-DD:hh:mm:ss'),

          chartData: {
            labels: ProductName,
            datasets: [
              {
                label: 'L1 IssueCount',
                data: L1IssueCount,
                backgroundColor: '#8d0f06'
              },
              {
                label: 'L2 IssueCount',
                data: L2IssueCount,
                backgroundColor: '#d45810'
              },
              {
                label: 'L3 IssueCount',
                data: L3IssueCount,
                backgroundColor: '#d4c70e'
              }
            ]
          }
        });
      })
      .catch(error => {
        console.log(error);
      });
  }

  render() {
    return (
      
        <div className='chart'>
          {this.state.timeStamp && (
            <div
              style={{
                color: '#08089e',
                display: 'flex',
                paddingTop: '0px',
                paddingLeft: '10px',
                flexFlow: 'row-reverse',
                fontSize: '18px',
                fontWeight: 'bold'
              }}
            >
              <span> {this.state.timeStamp}</span>
              <span>Last Updated TimeStamp- </span>
            </div>
          )}

          <Bar
            data={this.state.chartData}
            options={{
              hover: {
                animationDuration: 0
              },
              animation: {
                duration: 1,
                onComplete: function() {
                  var chartInstance = this.chart,
                    ctx = chartInstance.ctx;
                  ctx.textAlign = 'center';
                  ctx.textBaseline = 'bottom';
                  this.data.datasets.forEach(function(dataset, i) {
                    var meta = chartInstance.controller.getDatasetMeta(i);
                    meta.data.forEach(function(bar, index) {
                      var data = dataset.data[index];
                      if (data !== 0) {
                        ctx.fillText(data, bar._model.x, bar._model.y - 0);
                      }
                    });
                  });
                }
              },
              title: {
                width: 320
              },

              scales: {
                xAxes: [
                  {
                    ticks: {
                      fontColor: 'black',
                      fontSize: 15,
                      fontWeight: 'bold',
                      fontFamily: 'sans-serif',
                      beginAtZero: true
                    },
                    barPercentage: 1,
                    barThickness: 43,
                    maxBarThickness: 98,
                    minBarLength: 0,
                    gridLines: {
                      display: true,
                      drawBorder: true,
                      offsetGridLines: true,
                      color: ' #d5dee2',
                      drawTicks: true,
                      drawOnChartArea: true,
                      circular: true
                    }
                  }
                ],
                yAxes: [
                  {
                    ticks: {
                      fontColor: 'black',
                      fontSize: 17,
                      beginAtZero: true
                    },
                    barPercentage: 0.5,
                    barThickness: 43,
                    maxBarThickness: 48,
                    minBarLength: 0,
                    fontColor: 'red',
                    fontSize: 18,
                    gridLines: {
                      display: true,
                      drawBorder: true,
                      offsetGridLines: true,
                      color: ' #d5dee2',
                      drawTicks: true,
                      drawOnChartArea: true,
                      circular: true
                    }
                  }
                ]
              },
              legend: {
                labels: {
                  fontColor: '#3f51b5',
                  fontSize: 14
                },
                display: this.props.displayLegend,
                position: this.props.legendPosition
              }
            }}
          />
        </div>
      
    );
  }
}

export default Chart;
