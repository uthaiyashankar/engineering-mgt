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

string GITHUB_VAR_ENDCURSOR = "endCursor";
string GITHUB_VAR_ORG = "organization";

string QUERY_GET_USERS_OF_ORG = string `
query($${GITHUB_VAR_ORG}: String!, $${GITHUB_VAR_ENDCURSOR}: String){
  ${GITHUB_RATELIMIT},
  organization(login:$${GITHUB_VAR_ORG}){
    membersWithRole(first:100, after:$${GITHUB_VAR_ENDCURSOR}) {
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

string QUERY_GET_REPOS_OF_ORG = string `
query($${GITHUB_VAR_ORG}: String!, $${GITHUB_VAR_ENDCURSOR}: String){
  ${GITHUB_RATELIMIT},
  organization(login:$${GITHUB_VAR_ORG}){
    repositories(first:100, after:$${GITHUB_VAR_ENDCURSOR}) {
      ${GITHUB_PAGINATION},
      nodes {
        databaseId,
        name,
        url,
        isPrivate
      }
    }
  }
}`;


// query($endCursor:String, $since:DateTime){
//   repository(name:"analytics-is", owner:"wso2"){
//     issues(first:10, after:$endCursor, filterBy:{since:$since}){
//       nodes{
//         title,
//         url,
//         createdAt,
//         updatedAt,
//         closedAt,
//         assignees(first:10){
//           nodes{
//             login
//           }
//         },
//         labels(first:10){
//           nodes{
//             name
//           }
//         }
//       }
//     }
//   }
// }


// 2019-12-05T05:19:03Z
// query($endCursor:String){
//   repository(name:"analytics-is", owner:"wso2"){
//     pullRequests(first:100, after:$endCursor, states:[OPEN]){
//       nodes{
//         title,
//         url,
//         createdAt,
//         updatedAt,
//         closedAt,
//         reviews(last:1){
//           nodes{
//             author{
//               login
//             },
//             state
//           }
//         }
//       }
//     }
//   }
// }

// query{
//   rateLimit{
//     cost,
//     remaining,
//     resetAt
//   },
// 	search(type:ISSUE, first:100, query:"repo:wso2/analytics-is is:pr updated:>2019-10-15T07:11:48Z"){
//     pageInfo{
//       endCursor,
//       hasNextPage
//     },
//     nodes{
//       ... on PullRequest{
//         url,
//         title
//         createdAt
//         updatedAt
//         closedAt
//         state
//         reviews(last:1){
//           nodes{
//             state
//           }
//         }
//       }
//     }
//   }
// }