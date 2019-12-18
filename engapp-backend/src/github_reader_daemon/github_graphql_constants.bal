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

//The pattern is : GITHUB_VARIABLES + variables + GITHUB_QUERY_START + query + GITHUB_QUERY_END

string GITHUB_PAGINATION_ENDCURSOR = "endCursor";
string GITHUB_PAGINATION = string `
pageInfo{
  endCursor,
  hasNextPage
}`;


string GITHUB_RATELIMIT = string `
rateLimit{
  remaining,
  resetAt
}`;

//=====================================
//Getting members of Organizations
//=====================================
string GET_MEMBERS_OF_ORG_VAR_ORG = "organization";

string QUERY_GET_MEMBERS_OF_ORG = string `
query($${GET_MEMBERS_OF_ORG_VAR_ORG}: String!, $${GITHUB_PAGINATION_ENDCURSOR}: String){
  ${GITHUB_RATELIMIT},
  organization(login:$${GET_MEMBERS_OF_ORG_VAR_ORG}){
    membersWithRole(first:100, after:$${GITHUB_PAGINATION_ENDCURSOR}) {
      ${GITHUB_PAGINATION},
      nodes {
        id,
        login,
        name,
        company,
        email,
        url,
        websiteUrl
      }
    }
  }
}`;

