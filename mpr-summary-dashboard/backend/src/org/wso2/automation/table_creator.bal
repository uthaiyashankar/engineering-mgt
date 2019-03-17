import ballerina.io;
import ballerina.config;
import ballerina.data.sql;

string DB_NAME;
string DB_USER;
string DB_PASSWORD;
string DB_HOST;
int DB_PORT;
string DB_URL;


public function loadDatabaseDefinitions() (error) {
    try {
        DB_NAME=config:getGlobalValue("db.name");
        DB_USER=config:getGlobalValue("db.user");
        DB_PASSWORD=config:getGlobalValue("db.password");
        DB_HOST=config:getGlobalValue("db.host");
        var port,_ = <int>(config:getGlobalValue("db.port"));
        DB_PORT=port;
        DB_URL="jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME + "?useSSL=false";
    } catch (error e) {
        return e;
    }
    return null;
}


struct EmailAddressRecord {
    int userId;
    string emailAddress;
}

struct GithubUserRecord {
    string timeStamp;
    string gitId;
    string productTeam;
    string emailAddress;
    string githubOrg;
    string RepoName;
    string name;
    string privileges;
    string repoName2;
    string wEmail;
    string intern;
    string githubVerifiedEmail;
    string wEmailB;
    string empty;
    string nameB;
}


function getEmailAddresses()(string[]) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD,
        {maximumPoolSize:5, url:DB_URL});
    }
    string[] emailAddresses = [];
    int i = 0;
    table dtEmailAddresses = testDB.select("SELECT * from EMAIL_ADDRESSES", null, typeof EmailAddressRecord);
    while (dtEmailAddresses.hasNext()) {
        var rs, _ = (EmailAddressRecord)dtEmailAddresses.getNext();
        emailAddresses[i] = rs.emailAddress;
        i = i + 1;
    }

    testDB.close();

    return emailAddresses;

}



function getGitMapping(string email)(string) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD,
        {maximumPoolSize:5, url:DB_URL});
    }
    string gitMapping="";
    int i = 0;
    string sqlStr = "SELECT * from GITHUB_USERS WHERE " +
                    "`Email Address`='" + email + "' OR " +
                    "`W Email`='" + email + "'";

    table dtGitMappings = testDB.select(sqlStr, null, typeof GithubUserRecord );
    while (dtGitMappings.hasNext()) {
        var rs, _ = (GithubUserRecord)dtGitMappings.getNext();

        string fullName = rs.name.toLowerCase().replace(" ","");
        string emailL = email.toLowerCase().replace("@wso2.com","");
        if(fullName.contains(emailL)) {
            if(rs.gitId!=email) {
                gitMapping = rs.gitId;
                break;
            }
        }

        string[] names = rs.name.toLowerCase().split(" ");
        foreach name in names{
            if(rs.gitId!=email) {
                gitMapping = rs.gitId;
                break;
            }
        }
        i = i + 1;
    }

    testDB.close();
    gitMapping = gitMapping.replace("https://github.com/","");
    return gitMapping;

}

function createGithubIDs(sql:Parameter[][] bPara) {
    endpoint<sql:ClientConnector> testDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD,
        {maximumPoolSize:5, url:DB_URL});
    }
    int ret = testDB.update("DROP TABLE IF EXISTS GITHUB_IDS", null);
    // ret = testDB.update("CREATE TABLE GITHUB_IDS(ID INT AUTO_INCREMENT,
    //                             EMAIL_ADDRESS VARCHAR(100),GIT_ID VARCHAR(100), PRIMARY KEY (ID))", null);
    // int[] c = testDB.batchUpdate("INSERT INTO GITHUB_IDS (EMAIL_ADDRESS,GIT_ID) VALUES (?,?)", bPara);

    int i = 0;
    foreach para in bPara {
        string sqlUpdate = string `
        INSERT INTO INSERT INTO GITHUB_IDS (EMAIL_ADDRESS,GIT_ID)
        SELECT * FROM (SELECT ? EMAIL_ADDRESS, SELECT ? AS GIT_ID) AS tmp
        WHERE NOT EXISTS (
            SELECT * FROM GITHUB_IDS WHERE EMAIL_ADDRESS = '<EMAIL>'
        ) LIMIT 1;`;
        var emailAddress,_ = (string)para[0].value;
        sqlUpdate = sqlUpdate.replace("<EMAIL>", emailAddress);
        int c = testDB.update(sqlUpdate, para);
        i = i + 1;
    }
    testDB.close();
}


function main(string[] args) {
    var err = loadDatabaseDefinitions();
    string[] emailAddresses = getEmailAddresses();
    sql:Parameter[][] bPara = [];
    int i = 0;
    foreach emailAddress in emailAddresses {
        sql:Parameter p1 = {sqlType:sql:Type.VARCHAR, value:emailAddress};
        sql:Parameter p2 = {sqlType:sql:Type.VARCHAR, value:getGitMapping(emailAddress)};
        sql:Parameter[] item1 = [p1, p2];
        bPara[i] = item1;

        i = i + 1;
    }
    createGithubIDs(bPara);
}