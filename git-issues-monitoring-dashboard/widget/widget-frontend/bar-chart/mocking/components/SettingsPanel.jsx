/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import React, { Component } from "react";
import {
  ExpansionPanel,
  ExpansionPanelDetails,
  ExpansionPanelSummary,
  Button,
  Tabs,
  Tab,
  AppBar,
  Typography,
  FormControl,
  FormControlLabel,
  RadioGroup,
  Radio,
  Select,
  MenuItem,
  Grid,
  IconButton
} from "@material-ui/core";
import widgetConf from "../../resources/widgetConf.json";
import ExpandMoreIcon from "@material-ui/icons/ExpandMore";
import DateTimePicker from "react-datetime-picker";
import PublisherEventStack from "./PublisherEventStack";
import moment from "moment";
import LightBulbFillIcon from "./assets/LightBulbFill.jsx";
import LightBulbOutlineIcon from "./assets/LightBulbOutline.jsx";

export class SettingsPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      openExpansion: false,
      tabIndex: false,
      subscriberModel: "Custom values",
      startDate: new Date("2018-01-01 00:00:00"),
      endDate: new Date("2019-01-01 00:00:00"),
      simulationEventCount: 0,
      granularity: "month",
      theme: "dark"
    };
  }
  /**
   * Change the theme of the widget
   * @param {String} theme - Theme applied (DARK/LIGHT)
   */
  toggleTheme = () => {
    const { theme } = this.state;
    const currentTheme = theme === "dark" ? "light" : "dark";
    this.setState({ theme: currentTheme });
    this.props.changeTheme(currentTheme);
  };


  /**
   * Render the publisher configuration component to preview the events triggered
   * @param { JSON } eventStack - Current eventStack
   * @return { JSX }
   */
  renderPublisherConfigs = eventStack => {
    return (
      <div>
        <ExpansionPanel>
          <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                width: "100%"
              }}
            >
              <Typography style={{ fontWeight: "bold" }}>
                Event Stack
              </Typography>
              <Typography>{eventStack ? eventStack.length : 0}</Typography>
            </div>
          </ExpansionPanelSummary>
          <ExpansionPanelDetails>
            <PublisherEventStack eventStack={eventStack} />
          </ExpansionPanelDetails>
        </ExpansionPanel>
      </div>
    );
  };

  /**
   * Render the subscriber Configurations including publisher simulation
   * @param {JSON} eventStack - Current Event Stack
   * @returns {JSX}
   */
  renderSubscriberConfigs = eventStack => {
    const { setSimulationModel } = this.props;
    const { updateEventStack } = this.props;
    return (
      <div>
        <Typography style={{ fontWeight: "bold" }}>Simulation Model</Typography>
        <FormControl component="fieldset" style={{ marginLeft: "20px" }}>
          <RadioGroup
            style={{ display: "inline", justifyContent: "space-between" }}
            value={this.state.subscriberModel}
            onChange={event => {
              const value = event.target.value;
              updateEventStack(new Array());
              this.setState({ subscriberModel: value }, () => {
                setSimulationModel(value);
              });
            }}
          >
            <FormControlLabel
              value="Dummy publisher"
              control={<Radio />}
              label="Dummy publisher"
            />
            <FormControlLabel
              value="Custom values"
              control={<Radio />}
              label="Custom values"
            />
          </RadioGroup>
        </FormControl>
        {this.state.subscriberModel === "Custom values" &&
          this.renderCustomPublisher(eventStack)}
        <ExpansionPanel>
          <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />}>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                width: "100%"
              }}
            >
              <Typography style={{ fontWeight: "bold" }}>
                Event Stack
              </Typography>
              <Typography>{eventStack ? eventStack.length : 0}</Typography>
            </div>
          </ExpansionPanelSummary>
          <ExpansionPanelDetails>
            <PublisherEventStack eventStack={eventStack} />
          </ExpansionPanelDetails>
        </ExpansionPanel>
      </div>
    );
  };

  /**
   * Render the custom publisher component
   * @param {JSON} eventStack
   * @returns {JSX}
   */
  renderCustomPublisher = eventStack => {
    const { startDate, endDate, granularity } = this.state;
    return (
      <div style={{ marginLeft: "5%" }}>
        <Typography style={{ fontWeight: "bold" }}>
          You can publish your own Date range
        </Typography>
        <Grid container>
          <Grid item xs={12} lg={4}>
            <Grid container>
              <Grid item xs={3}>
                <span>From : </span>
              </Grid>
              <Grid item xs={4}>
                <DateTimePicker
                  onChange={date => {
                    this.setState({ startDate: date });
                  }}
                  value={startDate}
                />
              </Grid>
            </Grid>
          </Grid>
          <Grid item xs={12} lg={4}>
            <Grid container>
              <Grid item xs={3}>
                <span>To : </span>
              </Grid>
              <Grid item xs={4}>
                <DateTimePicker
                  onChange={date => {
                    this.setState({ endDate: date });
                  }}
                  value={endDate}
                />
              </Grid>
            </Grid>
          </Grid>
          <Grid item xs={12} lg={4}>
            <Grid container>
              <Grid item xs={6}>
                <Select
                  value={granularity}
                  onChange={event => {
                    this.setState({ granularity: event.target.value });
                  }}
                >
                  <MenuItem value={"second"}>second</MenuItem>
                  <MenuItem value={"minute"}>minute</MenuItem>
                  <MenuItem value={"hour"}>hour</MenuItem>
                  <MenuItem value={"day"}>day</MenuItem>
                  <MenuItem value={"month"}>month</MenuItem>
                  <MenuItem value={"year"}>year</MenuItem>
                </Select>
              </Grid>
              <Grid item xs={6}>
                <Button
                  size={"small"}
                  color={"primary"}
                  onClick={() => this.handleCustomDateEventPublish(eventStack)}
                  style={{
                    backgroundColor: "#333333",
                    color: "white"
                  }}
                >
                  Publish
                </Button>
              </Grid>
            </Grid>
          </Grid>
        </Grid>
      </div>
    );
  };

  /**
   * Handle Custom event publishing
   * @param {JSON} eventStack - Current Event Stack
   *
   */

  handleCustomDateEventPublish = eventStack => {
    const { startDate, endDate, granularity } = this.state;
    const { updateEventStack } = this.props;
    const dateRange = {
      from: moment(startDate).format("x"),
      to: moment(endDate).format("x"),
      granularity
    };
    global.callBackFunction(dateRange);
    if (!eventStack) {
      eventStack = [];
    }
    eventStack.push(dateRange);
    updateEventStack(eventStack);
  };

  /**
   * Rendering the Settings Panel Component
   * @returns {JSX}
   */
  render() {
    const { publisherSimulation } = this.props;
    const { tabIndex, openExpansion, theme } = this.state;
    const pubSubTypes = widgetConf.configs.pubsub.types;
    const publisherVisibility = pubSubTypes.includes("publisher")
      ? "inline-block"
      : "none";
    const subscriberVisibility = pubSubTypes.includes("subscriber")
      ? "inline-block"
      : "none";
    return (
      <div>
        <ExpansionPanel
          style={{ marginBottom: "5px" }}
          expanded={this.state.openExpansion}
        >
          <ExpansionPanelSummary style={{ padding: "0px", margin: "0px" }}>
            <AppBar
              position="static"
              style={{
                backgroundColor: "#222425",
                margin: "0px",
                padding: "0px"
              }}
            >
              <Tabs
                style={{
                  margin: "0px",
                  padding: "0px"
                }}
                value={tabIndex}
                onChange={(value, event) => {
                  if (tabIndex === event && openExpansion) {
                    this.setState({
                      openExpansion: false
                    });
                  } else {
                    this.setState({ tabIndex: event, openExpansion: "true" });
                  }
                }}
                fullWidth
              >
                <IconButton
                  onClick={() => {
                    this.toggleTheme("light");
                  }}
                >
                  {theme === "dark" ? (
                    <LightBulbFillIcon />
                  ) : (
                      <LightBulbOutlineIcon />
                    )}
                </IconButton>

                <Tab
                  label="Publisher"
                  style={{ color: "#ffffff", display: publisherVisibility }}
                />

                <Tab
                  label="Publisher Simulations"
                  style={{ color: "#ffffff", display: subscriberVisibility }}
                />
              </Tabs>
            </AppBar>
          </ExpansionPanelSummary>
          <ExpansionPanelDetails
            style={{
              border: "1px solid #222425",
              padding: "15px",
              display: "block"
            }}
          >
            {tabIndex === 1 &&
              this.renderPublisherConfigs(publisherSimulation.eventStack)}
            {tabIndex === 2 &&
              this.renderSubscriberConfigs(publisherSimulation.eventStack)}
          </ExpansionPanelDetails>
        </ExpansionPanel>
      </div>
    );
  }
}

export default SettingsPanel;
