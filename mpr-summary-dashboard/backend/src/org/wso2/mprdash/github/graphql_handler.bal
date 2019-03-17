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

package src.org.wso2.mprdash.github;

import ballerina.net.http;
import ballerina.collections;
import ballerina.time;
import ballerina.log;
import ballerina.io;
import ballerina.runtime;

public string apiTOKEN = "";
public string apiURL = "";

const int MAX_TIMEOUT = 10;

public const string QUERY_PR = string `{
  organization(login: \"<ORG>\") {
    repository(name: \"<REPO>\") {
      name
      url
      pullRequests(first: 100,
      states: [MERGED],
       orderBy: {field: CREATED_AT, direction: DESC},
       <AFTER>) {
        pageInfo {
          hasNextPage
          endCursor
        }
        nodes {
          id
          author {
            login
          }
          title
          url
          body
          createdAt
          mergedAt
          headRefName
          baseRefName
          milestone {
            title
          }
        }
      }
    }
  }
}
`;

public struct PullRequest {
    string id;
    string author;
    string title;
    string prUrl;
    string repoName;
    time:Time createdAt;
    time:Time mergedAt;
    string head;
    string base;
    int docStatus;
    string milestone;
}

@Description{value:"Set GitHub graphql API URL and access token"}
@Param{value:"url: GitHub graphql API URL"}
@Param{value:"token: GitHub graphql access token"}
@Return{value:"result: Nothing"}
public function setAccessInfo (string url, string token) {
    apiURL = url;
    apiTOKEN = token;
}


function formatQuery (string query, string[] tokens, string[] replaceTokens) (string) {
    int i = 0;
    string queryFormatted = query;
    foreach token in tokens {
        string replaceToken = replaceTokens[i];
        queryFormatted = queryFormatted.replaceAll(token, replaceToken);
        i = i + 1;
    }
    return queryFormatted;
}


public function getPrQuery (string org, string repo, string afterPR) (string) {
    string[] tokens = ["<ORG>", "<REPO>", "<AFTER>"];
    string[] replaceTokens = [org, repo, ""];
    if (afterPR != "") {
        replaceTokens[2] = "after:\"" + afterPR + "\"";
    }
    string query = formatQuery(QUERY_PR, tokens, replaceTokens);
    return query;
}

function getDocStatus (string body) (int) {
    string patternLinks = "((ht|f)tp(s?):\\/\\/|www\\.)"
                          + "(([\\w\\-]+\\.){1,}?([\\w\\-.~]+\\/?)*"
                          + "[\\p{Alnum}.,%_=?&#\\-+()\\[\\]\\*$~@!:/{};']*)";
    string[] docs = body.split("#+");
    Regex regLinks = {pattern:patternLinks};
    Regex regNA = {pattern:"n*/*a"};
    string issueType = "documentation";
    foreach doc in docs {
        string docL = doc.toLowerCase();
        if (docL.contains(issueType.toLowerCase())) {
            var isNA, _ = docL.matchesWithRegex(regNA);
            if (isNA) {
                return DocStatusNoImpact;
            }
            //else {
            //    var links, _ = doc.findAllWithRegex(regLinks);
            //    foreach link in links {
            //        if(link.contains("issues")) {
            //            return DocStatusIssuesPending;
            //        }
            //    }
            //    if((lengthof links)>0) {
            //        return DocStatusDraftReceived;
            //    }
            //}
        }

    }
    return DocStatusNotStarted;
}



public function getRecordsInResponse(json result, time:Time createdFrom)(collections:Vector,boolean) {
    collections:Vector records = {vec:[]};

    var repo, _ = (string)result["data"]["organization"]["repository"]["name"];
    json prsj = result["data"]["organization"]["repository"]["pullRequests"]["nodes"];
    boolean endReached=false;
    foreach pr in prsj {
        var strID, _ = (string)pr["id"];
        var strAuthor, _ = (string)pr["author"]["login"];
        var strTitle, _ = (string)pr["title"];
        var strPR_URL, _ = (string)pr["url"];
        var strBody, _ = (string)pr["body"];
        var strHead, _ = (string)pr["headRefName"];
        var strBase, _ = (string)pr["baseRefName"];
        var milestone = "";
        if (null == pr["milestone"]) {
            milestone = "unknown";
        } else {
            milestone, _ = (string)pr["milestone"]["title"];
        }
        var strCreated, _ = (string)pr["createdAt"];
        time:Time created = time:parse(strCreated, "yyyy-MM-dd'T'HH:mm:ss'Z'");
        var strMerged, _ = (string)pr["mergedAt"];
        time:Time merged = time:parse(strMerged, "yyyy-MM-dd'T'HH:mm:ss'Z'");
        strTitle = strTitle.replaceAll("…","...");

        if(created.time <= createdFrom.time) {
            endReached=true;
            break;
        }

        PullRequest record = {
                                 id:strID,
                                 author:strAuthor,
                                 title:strTitle,
                                 prUrl:strPR_URL,
                                 repoName:repo,
                                 createdAt:time:parse(strCreated, "yyyy-MM-dd'T'HH:mm:ss'Z'"),
                                 mergedAt:time:parse(strMerged, "yyyy-MM-dd'T'HH:mm:ss'Z'"),
                                 head:strHead,
                                 base:strBase,
                                 milestone:milestone,
                                 docStatus:getDocStatus(strBody)
                             };

        records.add(record);
    }

    return records,endReached;
}


public function getPRsInRepo (string org, string repo, time:Time createdFrom) (collections:Vector) {
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient(apiURL, {});
    }

    http:OutRequest req = {};
    http:InResponse resp = {};



    string query = getPrQuery(org, repo, "");
    json jsonPayLoad = {query:query};

    int tries = 0;
    json result = null;

    while(tries < MAX_TIMEOUT) {
        try {
            req = {};
            resp = {};
            req.addHeader("Authorization", "Bearer " + apiTOKEN);
            req.setJsonPayload(jsonPayLoad);
            resp, _ = httpEndpoint.post("", req);
            result = resp.getJsonPayload();
            tries = tries + 1;
        } catch (error e) {
            log:printError("Try " + tries + ": " + e.message);
        } catch(runtime:NullReferenceException e) {
            log:printError("Try " + tries + ": " + e.message);
        }
    }

    if (result==null || result["data"]["organization"]["repository"] == null) {
        return null;
    }

    collections:Vector records = {vec:[]};

    boolean dateOutside=false;

    while (result != null) {
        json prsj = result["data"]["organization"]["repository"]["pullRequests"]["nodes"];
        dateOutside=false;
        foreach pr in prsj {
            var strID, _ = (string)pr["id"];
            var strTitle, _ = (string)pr["title"];
            var strPR_URL, _ = (string)pr["url"];
            var strBody, _ = (string)pr["body"];
            var strHead, _ = (string)pr["headRefName"];
            var strBase, _ = (string)pr["baseRefName"];
            var milestone = "";
            if (null == pr["milestone"]) {
                milestone = "unknown";
            } else {
                milestone, _ = (string)pr["milestone"]["title"];
            }
            var strCreated, _ = (string)pr["createdAt"];
            time:Time created = time:parse(strCreated, "yyyy-MM-dd'T'HH:mm:ss'Z'");
            var strMerged, _ = (string)pr["mergedAt"];
            time:Time merged = time:parse(strMerged, "yyyy-MM-dd'T'HH:mm:ss'Z'");
            strTitle = strTitle.replaceAll("…","...");

            if(created.time <= createdFrom.time) {
                dateOutside=true;
                break;
            }

            PullRequest record = {
                                     id:strID,
                                     title:strTitle,
                                     prUrl:strPR_URL,
                                     repoName:repo,
                                     createdAt:time:parse(strCreated, "yyyy-MM-dd'T'HH:mm:ss'Z'"),
                                     mergedAt:time:parse(strMerged, "yyyy-MM-dd'T'HH:mm:ss'Z'"),
                                     head:strHead,
                                     base:strBase,
                                     milestone:milestone,
                                     docStatus:getDocStatus(strBody)
                                 };
            records.add(record);
        }

        if(dateOutside) {
            break;
        }

        var hasNextPR, err = (boolean)result["data"]["organization"]["repository"]["pullRequests"]["pageInfo"]["hasNextPage"];
        if (hasNextPR && err == null) {
            var cursor_pr, _ = (string)result["data"]["organization"]["repository"]["pullRequests"]["pageInfo"]["endCursor"];
            query = getPrQuery(org, repo, cursor_pr);
            jsonPayLoad = {query:query};
            result = null;
            tries = 0;
            while(tries < MAX_TIMEOUT) {
                try {
                    req = {};
                    resp = {};
                    req.addHeader("Authorization", "Bearer " + apiTOKEN);
                    req.setJsonPayload(jsonPayLoad);
                    resp, _ = httpEndpoint.post("", req);
                    result = resp.getJsonPayload();
                    tries = tries + 1;
                } catch (error e) {
                    log:printError("Try " + tries + ": " + e.message);
                } catch(runtime:NullReferenceException e) {
                    log:printError("Try " + tries + ": " + e.message);
                }
            }
        } else {
            result = null;
        }
    }
    return records;
}

