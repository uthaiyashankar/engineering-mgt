//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//


package src.org.wso2.mprdash.appdata;

import ballerina.io;
import ballerina.time;
import ballerina.config;
import ballerina.log;

boolean isConfigLoaded = false;
string dateFile;
public time:Time START_DATE = time:createTime(2018,1,1,0,0,0,0,"");

@Description {value:"Load date update file path"}
function loadConfig() {
    try {
        dateFile = config:getGlobalValue("update.file");
        isConfigLoaded = true;

    } catch(error err) {
        log:printError(err.message);
    }
}

@Description {value:"Get a FileCharacterChannel with given paramaters."}
@Param {value:"filePath: Location of the file"}
@Param {value:"persmission: File permission"}
@Param {value:"encoding: File encoding"}
@Return {value:"CharacterChannel: Character Channel"}
public function getFileCharacterChannel (string filePath, string permission, string encoding)
(io:CharacterChannel) {

    io:ByteChannel channel = io:openFile(filePath, permission);

    io:CharacterChannel characterChannel = io:createCharacterChannel(channel, encoding);
    return characterChannel;
}

@Description {value:"Write update date"}
@Param {value:"updateDate: Last update date of records"}
public function writeUpdateDate(time:Time updateDate) {
    if(!isConfigLoaded) {
        loadConfig();
    }

   try {
       io:CharacterChannel channel =
       getFileCharacterChannel(dateFile, "w", "UTF-8");
       _ = channel.writeCharacters(updateDate.format("yyyy-MM-dd'T'HH:mm:ss'Z'"),0);
   } catch(error err) {
       log:printError(err.message);
   }
}

@Description {value:"Read the last update date"}
@Return {value:"Time: Time of last update"}
public function readUpdateDate() (time:Time) {
    if(!isConfigLoaded) {
        loadConfig();
    }
    time:Time updateDate = null;
    try {
        io:CharacterChannel channel =
        getFileCharacterChannel(dateFile, "r", "UTF-8");
        string strDate = channel.readAllCharacters();
        updateDate = time:parse(strDate, "yyyy-MM-dd'T'HH:mm:ss'Z'");
    } catch(error err) {
        log:printError(err.message);
    }
    return updateDate;
}

@Description {value:"Reset the date to START_DATE"}
public function resetDate() {
    writeUpdateDate(START_DATE);
}
