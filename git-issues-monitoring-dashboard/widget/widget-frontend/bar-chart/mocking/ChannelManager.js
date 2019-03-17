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

// Default dataset for custom Preview
import DATASET from './dataSet/dataset.json';
// Widget Configuration file
import widgetConf from '../resources/widgetConf.json';

/**
 * Working As a Mocking component instead of WSO2/Dashboard-Widget.
 * This part would be not included in the widget and it will load
 * from the Dashboard portal base widget.Subscribing and publishing
 * methods were included here if the widget Configuration file includes
 *  a pubsub type the methods will support
 */
export default class ChannelManager {
  /**
   * Registering a subscription for a widget inorder to gain the events
   * from the sample data set.
   *
   * @param {String} widgetID
   * @param {Function} callBackFunction
   * @param {JSON} configurations
   */
  static subscribeWidget(widgetID, callBackFunction, configurations) {
    // Checking if the Siddhi app contains aggregation part
    if ( widgetConf.configs.providerConfig.configs.config.siddhiApp &&
      widgetConf.configs.providerConfig.configs.config.siddhiApp.includes(
        'aggregation',
      )
    ) {
      callBackFunction(this.aggregationDataRead());
    } else {
      callBackFunction(this.setDataForNormalRead());
    }
  }

  /**
   * Loading data from the sample Data Set
   * @returns {JSON}
   */
  static setDataForNormalRead() {
    const dataSet = {
      data: [],
      metadata: {
        types: [],
        names: [],
      },
    };
    // Assigning the column names
    dataSet.metadata.names = Object.keys(DATASET[0]);
    // Mapping the column values to Ordinal and Linear form
    Object.values(DATASET[0]).forEach((element, index) => {
      if (isNaN(Object.values(DATASET[0])[index])) {
        dataSet.metadata.types.push('ordinal');
      } else {
        dataSet.metadata.types.push('linear');
      }
    });
    // Making the dataset from the filtered data set
    for (let index = 0; index < DATASET.length; index++) {
      dataSet.data.push(Object.values(DATASET[index]));
    }
    return dataSet;
  }

  /**
   * Loading data from the aggregated json files according to the granularity
   * @returns {JSON}
   */
  static aggregationDataRead() {
    // Reading the last writted date event in the stack
    const eventStack = JSON.parse(window.localStorage.getItem('eventStack'));
    const lastDateEvent = eventStack.pop();
    const condition = {
      from: lastDateEvent.from,
      to: lastDateEvent.to,
    };

    // Select the Aggregation table according to the granularity
    switch (lastDateEvent.granularity) {
      case 'seconds':
        return this.filterDataSet(SECONDS, condition);
      case 'minutes':
        return this.filterDataSet(MINUTES, condition);
      case 'hours':
        return this.filterDataSet(HOURS, condition);
      case 'days':
        return this.filterDataSet(DAYS, condition);
      case 'months':
        return this.filterDataSet(MONTHS, condition);
      case 'years':
        return this.filterDataSet(YEARS, condition);

      default:
        console.log('Default Break');
        break;
    }
  }

  /**
   * Filter data from the relavant aggregation table and map the data for publish
   * @param {JSON} DATASET_OBJ : Aggregated JSON object
   * @param {string} condition : condition to filter data
   */
  static filterDataSet(DATASET_OBJ, condition) {
    const dataSet = {
      data: [],
      metadata: {
        types: [],
        names: [],
      },
    };

    // Filter data from the aggregated JSON object according to the condition
    const filteredSet = DATASET_OBJ.filter((data) => {
      if (
        condition.from < data.event.AGG_TIMESTAMP
        && condition.to > data.event.AGG_TIMESTAMP
      ) {
        return true;
      }
      return false;
    }).map((element) => {
      const { name, avgRating, sumRating } = element.event;
      return { name, avgRating, sumRating };
    });

    if (filteredSet.length !== 0) {
      Object.keys(filteredSet[0]).forEach((element) => {
        if (isNaN(filteredSet[0][element])) {
          dataSet.metadata.types.push('ordinal');
        } else {
          dataSet.metadata.types.push('linear');
        }
        dataSet.metadata.names.push(element);
      });

      dataSet.data = filteredSet;
    }

    return dataSet;
  }
}
