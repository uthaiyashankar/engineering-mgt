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

package src.org.wso2.mprdash.github.email;

@Description {value:"Defines the PR details struct. Correspond to the combination of PRODUCT_PRS, PRODUCT, PRODUCT_REPOS"}
public struct PrDocStatusDetails {
    string productName;
    string productVersion;
    string repoName;
    string prAuthor;
    string prTitle;
    string prUrl;
    int daysSinceMergerdDate;
}

@Description {value:"Define the doc status summary within two weeks struct. Correspond to the combination of PRODUCT_PRS"}
public struct DocStatusSummary {
    int prCountWithinTwoWeeks;
    int totalPrCount;
}
