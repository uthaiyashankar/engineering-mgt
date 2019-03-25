import ballerina/io;
import ballerina/sql;
import ballerinax/jdbc;
import ballerina/http;
import ballerina/log;
import ballerina/config;

http:Client allJobEndpoint = new(config:getAsString("ALL_JOBS_ENDPOINT"));
http:Client xmlDataEndpoint = new(config:getAsString("XML_DATA_ENDPOINT_PART1"));

jdbc:Client dependencyUpdatesDb = new({
        url: config:getAsString("DATABASE_URL"),
        username: config:getAsString("DATABASE_USERNAME"),
        password: config:getAsString("DATABASE_PASSWORD"),
        poolOptions: { maximumPoolSize: 5 },
        dbOptions: { useSSL: false }
    });

type Repo record {
    int repoId;
};

type Summery record {
    int summaryId;
    int repoId;
    int usingLatestVersion;
    int nextVersion;
    int nextIncremental;
    int nextMinor;
    int nextMajor;
    string repoName;
    string orgName;
    string productName;

};

function getAllJobs() {
    var result = allJobEndpoint->get("?pretty=true");
    if (result is http:Response) {
        var jsonResult = result.getJsonPayload();
        if (jsonResult is json) {
            json[] jobs = <json[]>jsonResult.jobs;
            foreach var job in jobs {
                string name = <string>job.name;

                map<string> xmlDataMap = getXmlData(untaint name);
                if (xmlDataMap.length() > 0) {
                    string[] array = name.split("-");
                    string repoName = "";
                    foreach var i in 1...array.length() - 1 {
                        if (i == 1) {
                            repoName = array[i];

                        } else {
                            repoName = repoName + "-" + array[i];
                        }
                    }
                    updateSummeryData(repoName, xmlDataMap);
                }
            }
        } else {
            log:printError("Error when converting json payload");
        }
    } else {
        log:printError("Error when calling the backend: " + result.reason());
    }

}

function getRepoIdFromRepoName(string repoName) returns (json) {
    string sql = "SELECT REPO_ID FROM PRODUCT_REPOS WHERE REPO_NAME=?";
    var result = dependencyUpdatesDb->select(sql, Repo, repoName);
    if (result is table<Repo>) {
        var conversion = json.convert(result);
        if (conversion is json) {
            return conversion;
        } else {
            log:printError("Error in table to json conversion");
        }
    } else {
        log:printError("Select data from PRODUCT_REPOS table failed: "
                + <string>result.detail().message);
    }
}


function getXmlData(string job) returns (map<string>) {
    var result = xmlDataEndpoint->get("/" + job + config:getAsString("XML_DATA_ENDPOINT_PART2"));
    map<string> xmlData = {};
    if (result is http:Response) {
        if (result.statusCode == 200) {
            var textResult = result.getTextPayload();

            if (textResult is string) {
                io:StringReader r = new(textResult);
                var item = r.readXml();

                if (item is xml) {
                    xmlData["usingLastVersion"] = item["summary"]["usingLastVersion"].getTextValue();
                    xmlData["nextVersionAvailable"] = item["summary"]["nextVersionAlailable"].getTextValue();
                    xmlData["nextIncremetalAvailable"] = item["summary"]["nextIncremetalAvailable"].getTextValue();
                    xmlData["nextMinorAvailable"] = item["summary"]["nextMinorAvailable"].getTextValue();
                    xmlData["nextMajorAvailable"] = item["summary"]["nextMajorAvailable"].getTextValue();
                } else {
                    log:printError("Data not in xml format");
                }
            }
        } else {
            log:printInfo("Xml report data not found for job " + job);
        }

    } else {
        log:printError("Error when calling the backend: " + result.reason());
    }
    return xmlData;
}

function getSummeryIdFromRepoId(string repoId) returns (json) {
    string sql = "SELECT SUMMARY_ID FROM DEPENDENCY_SUMMARY WHERE REPO_ID=?";
    var result = dependencyUpdatesDb->select(sql, Summery, repoId);
    if (result is table<Summery>) {
        var conversion = json.convert(result);
        if (conversion is json) {
            return conversion;
        } else {
            log:printError("Error in table to json conversion");
        }
    } else {
        log:printError("Select data from DEPENDENCY_SUMMARY table failed: "
                + <string>result.detail().message);
    }
}

function updateSummeryData(string repoName, map<string> xmlDataMap) {
    int usingLastVersion = parse(<string>xmlDataMap["usingLastVersion"]);
    int nextVersionAvailable = parse(<string>xmlDataMap["nextVersionAvailable"]);
    int nextIncremetalAvailable = parse(<string>xmlDataMap["nextIncremetalAvailable"]);
    int nextMinorAvailable = parse(<string>xmlDataMap["nextMinorAvailable"]);
    int nextMajorAvailable = parse(<string>xmlDataMap["nextMajorAvailable"]);
    json repoIds = getRepoIdFromRepoName(repoName);
    if (repoIds.length() > 0) {
        string repoId = <string>repoIds[0].repoId;
        json summeryIds = getSummeryIdFromRepoId(repoId);
        if (summeryIds.length() > 0) {
            string summeryId = <string>summeryIds[0].summaryId;
            string sql = "UPDATE DEPENDENCY_SUMMARY SET USING_LASTEST_VERSIONS=?," +
                "NEXT_VERSION_AVAILABLE=?, NEXT_INCREMENTAL_AVAILABLE=?,NEXT_MINOR_AVAILABLE=?, NEXT_MAJOR_AVAILABLE=?"
                + " WHERE SUMMARY_ID=?";
            var result = dependencyUpdatesDb->update(sql, usingLastVersion, nextVersionAvailable,
                nextIncremetalAvailable,
                nextMinorAvailable, nextMajorAvailable, summeryId);
            if (<int>result == 1) {
                log:printInfo("Updated dependency summery data of " + repoName);

            } else {
                log:printError("Failed to update dependency summery data of " + repoName);
            }

        } else {
            string sql = "INSERT INTO DEPENDENCY_SUMMARY (REPO_ID, USING_LASTEST_VERSIONS, NEXT_VERSION_AVAILABLE," +
                "NEXT_INCREMENTAL_AVAILABLE,NEXT_MINOR_AVAILABLE,NEXT_MAJOR_AVAILABLE) VALUES(?,?,?,?,?,?)";
            var result = dependencyUpdatesDb->update(sql, repoId, usingLastVersion, nextVersionAvailable,
                nextIncremetalAvailable, nextMinorAvailable, nextMajorAvailable);
            if (<int>result == 1) {
                log:printInfo("Inserted new dependency summery data of " + repoName);

            } else {
                log:printError("Failed to insert dependency summery data of " + repoName);
            }
        }
    } else {
        log:printInfo("No matching repo found");
    }
}

function parse(string num) returns (int) {
    int|error temp = int.convert(num);
    int convertedNum = -1;
    if (temp is int) {
        convertedNum = temp;
    } else {
        log:printError("Error when converting string to int");
    }
    return convertedNum;
}

public function main() {
    getAllJobs();
}
