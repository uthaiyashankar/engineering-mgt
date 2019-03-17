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
 *
 */

const readline = require('readline');
const copydir = require('copy-dir');
const chalk = require('chalk');
const CFonts = require('cfonts');
const widgetConf = require('./resources/widgetConf.json');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const WIDGETS_LOCATION = `/wso2/dashboard/deployment/web-ui-apps/portal/extensions/widgets/${
  widgetConf.id
}`;
// const WIDGETS_LOCATION = `./${widgetConf.id}/1`;
const BUILT_DIRECTORY = `./${widgetConf.id}`;

CFonts.say('STREAM PROCESSOR', {
  font: 'block', // define the font face
  align: 'center', // define text alignment
  colors: ['system'], // define all colors
  background: 'transparent', // define the background color, you can also use `backgroundColor` here as key
  letterSpacing: 1, // define letter spacing
  lineHeight: 1, // define the line height
  space: true, // define if the output text should have empty lines on top and on the bottom
  maxLength: '0', // define how many character can be on one line
});

rl.question(
  chalk.bold.blue(
    'Do you want to copy the build folder to SP Dashboard portal (Y/N): ',
  ),
  (answer) => {
    const AllOWED = ['yes', 'YES', 'Yes', 'Y', 'y'];
    if (AllOWED.includes(answer)) {
      console.log(
        chalk.bold(
          '===================================================================',
        ),
      );
      rl.question(
        chalk.bold.blue('Enter Location of <SP HOME> directory : '),
        (location) => {
          console.log(
            `Please wait copying your Build directory to : ${location}`,
          );

          copydir(BUILT_DIRECTORY, location + WIDGETS_LOCATION, (err) => {
            if (err) {
              console.log(chalk.red('Deploying failure...'));
              console.error(err);
            } else {
              console.log(chalk.bold.green('Widget Deployed successfully!!!'));
              console.log(
                chalk.bold.yellow('FROM : ') + chalk.bold(BUILT_DIRECTORY),
              );
              console.log(
                chalk.bold.yellow('TO : ')
                  + chalk.bold(location + WIDGETS_LOCATION),
              );

              CFonts.say('Successful', {
                font: 'simple', // define the font face
                align: 'left', // define text alignment
                colors: ['greenBright'], // define all colors
                background: 'transparent', // define the background color, you can also use `backgroundColor` here as key
                letterSpacing: 1, // define letter spacing
                lineHeight: 1, // define the line height
                space: true, // define if the output text should have empty lines on top and on the bottom
                maxLength: '0', // define how many character can be on one line
              });
            }
          });
          console.log(
            chalk.bold(
              '===================================================================',
            ),
          );
          console.log(
            chalk.bold(
              '===================================================================',
            ),
          );
          rl.close();
        },
      );
    } else {
      CFonts.say('Skipped', {
        font: 'simple', // define the font face
        align: 'left', // define text alignment
        colors: ['yellowBright'], // define all colors
        background: 'transparent', // define the background color, you can also use `backgroundColor` here as key
        letterSpacing: 1, // define letter spacing
        lineHeight: 1, // define the line height
        space: true, // define if the output text should have empty lines on top and on the bottom
        maxLength: '0', // define how many character can be on one line
      });
      console.log(
        chalk.bold.red(
          'Your widget is not included to SP, you have to manully copy the Widget folder to <SP_HOME>/wso2/dashboard/portal/web_ui_apps/portal/extensions/widgets',
        ),
      );
      console.log(
        chalk.bold(
          '===================================================================',
        ),
      );
      console.log(
        chalk.bold(
          '===================================================================',
        ),
      );
      rl.close();
    }
  },
);
