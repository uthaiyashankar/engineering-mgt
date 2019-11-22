// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.


// ========================================================================================
// TODO : Ideally, these utils should be provided by the Ballerina and standard libraries. 
// I couldn't find suitable functions to do this. Hence, wrote them as utils. If we find 
// Suitable functions, we have to replace these utils with standard functions
// ========================================================================================

function mergeArrays (any[] mergeTo, any[] mergeFrom){
    foreach var item in mergeFrom {
        mergeTo.push(item);
    }
}

// function getCommaSeperatedListFromArray (any[] array) returns string {
//     string commaSeperatedVal = "";
//     foreach var item in array {
//         commaSeperatedVal = commaSeperatedVal + item.toString() + ", ";
//     }

//     //Have to remove the last trailing comma. However, it could be empty array
//     if (array.length() != 0) {
//         commaSeperatedVal =  commaSeperatedVal.substring(0, commaSeperatedVal.length() - 2);
//     }
//     return commaSeperatedVal;
// }
