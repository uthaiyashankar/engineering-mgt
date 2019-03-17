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
import ballerina.util;

const string AUTH_FILE = config:getGlobalValue("auth.file");


function generateToken() (string) {
    string uuid = util:uuid();
    string token = util:base64Encode(uuid);
    io:println("Token: " + token);
    return token;
}

function writeToken(string token) {
    try {
        io:CharacterChannel channel =
        getFileCharacterChannel(AUTH_FILE, "w", "UTF-8");
        _ = channel.writeCharacters(token,0);
    } catch(error err) {
        log:printError(err.message);
    }
}

function readToken() (string) {
    try {
        io:CharacterChannel channel =
        getFileCharacterChannel(AUTH_FILE, "r", "UTF-8");
        string strToken = channel.readAllCharacters();
        return strToken;
    } catch(error err) {
        log:printError(err.message);
    }
    return null;
}

public function changeToken() {
    writeToken(generateToken());
}

public function validateToken(string token)(boolean ) {
    if(token==readToken()) {
        return true;
    }
    return false;
}