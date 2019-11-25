-- =======================================
-- Main tables
-- =======================================
DROP TABLE IF EXISTS `ENGAPP_TEAMS`;
CREATE TABLE `ENGAPP_TEAMS` (
  `TEAM_ID` int(11) NOT NULL,
  `TEAM_NAME` varchar(100) NOT NULL,
  `TEAM_ABBR` varchar(45) NOT NULL,
  `TEAM_TYPE` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`TEAM_ID`)
);


DROP TABLE IF EXISTS `ENGAPP_GITHUB_ORGANIZATIONS`;
CREATE TABLE `ENGAPP_GITHUB_ORGANIZATIONS` (
  `ORG_ID` int(11) NOT NULL AUTO_INCREMENT,
  `GITHUB_ID` varchar(50) NOT NULL,
  `ORG_NAME` varchar(100) NOT NULL,
  PRIMARY KEY (`ORG_ID`)
  );

DROP TABLE IF EXISTS `ENGAPP_GITHUB_REPOSITORIES`;
CREATE TABLE `ENGAPP_GITHUB_REPOSITORIES` (
  `REPOSITORY_ID` int(11) NOT NULL AUTO_INCREMENT,
  `GITHUB_ID` varchar(50) NOT NULL,
  `REPOSITORY_NAME` varchar(150) NOT NULL,
  `ORG_ID` int(11) NOT NULL,
  `URL` varchar(150) NOT NULL,
  `TEAM_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`REPOSITORY_ID`),
  KEY `FK_ORG_ID_idx` (`ORG_ID`),
  KEY `FK_TEAM_ID_idx` (`TEAM_ID`),
  CONSTRAINT `FK_ORG_ID` FOREIGN KEY (`ORG_ID`) REFERENCES `ENGAPP_GITHUB_ORGANIZATIONS` (`ORG_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_TEAM_ID` FOREIGN KEY (`TEAM_ID`) REFERENCES `ENGAPP_TEAMS` (`TEAM_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS `ENGAPP_GITHUB_ISSUES`;
CREATE TABLE `ENGAPP_GITHUB_ISSUES` (
  `ISSUE_ID` int(11) NOT NULL AUTO_INCREMENT,
  `GITHUB_ID` varchar(45) NOT NULL,
  `REPOSITORY_ID` int(11) NOT NULL,
  `CREATED_DATE` datetime DEFAULT NULL,
  `UPDATED_DATE` datetime DEFAULT NULL,
  `CLOSED_DATE` datetime DEFAULT NULL,
  `CREATED_BY` varchar(100) NOT NULL,
  `ISSUE_TYPE` varchar(100) NOT NULL,
  `HTML_URL` varchar(500) DEFAULT NULL,
  `LABELS` varchar(500) DEFAULT NULL,
  `ASSIGNEES` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`ISSUE_ID`),
  KEY `FK_REPOSITORY_ID_idx` (`REPOSITORY_ID`),
  CONSTRAINT `FK_REPOSITORY_ID` FOREIGN KEY (`REPOSITORY_ID`) REFERENCES `ENGAPP_GITHUB_REPOSITORIES` (`REPOSITORY_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS `ENGAPP_ISSUE_COUNT`;
CREATE TABLE `ENGAPP_ISSUE_COUNT` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `DATE` date NOT NULL,
  `OPEN_ISSUES` int(11) NOT NULL DEFAULT '0',
  `CLOSED_ISSUES` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
);


-- =============================================
-- History Table
-- ============================================

/* Template: Replace <TABLENAME>, <PRIMARYKEY>, <FOREIGNKEY>

DROP TABLE IF EXISTS `<TABLENAME>_H`;
CREATE TABLE <TABLENAME>_H LIKE <TABLENAME>;
ALTER TABLE <TABLENAME>_H MODIFY COLUMN <PRIMARYKEY> int(11) NOT NULL,
   DROP PRIMARY KEY,
   DROP KEY <FOREIGNKEY>,
   DROP KEY <FOREIGNKEY2>,
   ADD COLUMN START_DATE DATETIME,
   ADD COLUMN END_DATE DATETIME;

*/

DROP TABLE IF EXISTS `ENGAPP_GITHUB_ISSUES_H`;
CREATE TABLE ENGAPP_GITHUB_ISSUES_H LIKE ENGAPP_GITHUB_ISSUES;
ALTER TABLE ENGAPP_GITHUB_ISSUES_H MODIFY COLUMN ISSUE_ID int(11) NOT NULL,
   DROP PRIMARY KEY,
   DROP KEY FK_REPOSITORY_ID_idx,
   ADD COLUMN START_DATE DATETIME,
   ADD COLUMN END_DATE DATETIME;

DROP TABLE IF EXISTS `ENGAPP_GITHUB_ORGANIZATIONS_H`;
CREATE TABLE ENGAPP_GITHUB_ORGANIZATIONS_H LIKE ENGAPP_GITHUB_ORGANIZATIONS;
ALTER TABLE ENGAPP_GITHUB_ORGANIZATIONS_H MODIFY COLUMN ORG_ID int(11) NOT NULL,
   DROP PRIMARY KEY,
   ADD COLUMN START_DATE DATETIME,
   ADD COLUMN END_DATE DATETIME;

DROP TABLE IF EXISTS `ENGAPP_GITHUB_REPOSITORIES_H`;
CREATE TABLE ENGAPP_GITHUB_REPOSITORIES_H LIKE ENGAPP_GITHUB_REPOSITORIES;
ALTER TABLE ENGAPP_GITHUB_REPOSITORIES_H MODIFY COLUMN REPOSITORY_ID int(11) NOT NULL,
   DROP PRIMARY KEY,
   DROP KEY FK_ORG_ID_idx,
   DROP KEY FK_TEAM_ID_idx,
   ADD COLUMN START_DATE DATETIME,
   ADD COLUMN END_DATE DATETIME;


DROP TABLE IF EXISTS `ENGAPP_TEAMS_H`;
CREATE TABLE ENGAPP_TEAMS_H LIKE ENGAPP_TEAMS;
ALTER TABLE ENGAPP_TEAMS_H MODIFY COLUMN TEAM_ID int(11) NOT NULL,
   DROP PRIMARY KEY,
   ADD COLUMN START_DATE DATETIME,
   ADD COLUMN END_DATE DATETIME;



-- ==============================================
-- Triggers
-- =============================================

/* Template:  Replace <TABLENAME>, <PRIMARYKEY> with correct values

DELIMITER //

DROP TRIGGER IF EXISTS <TABLENAME>_HISTORY_ON_INSERT//
CREATE TRIGGER <TABLENAME>_HISTORY_ON_INSERT AFTER INSERT ON <TABLENAME>
FOR EACH ROW
BEGIN
	INSERT INTO <TABLENAME>_H  (SELECT *, NOW(), NULL FROM <TABLENAME> WHERE <PRIMARYKEY> = NEW.<PRIMARYKEY>);
END//


DROP TRIGGER IF EXISTS <TABLENAME>_HISTORY_ON_UPDATE//
CREATE TRIGGER <TABLENAME>_HISTORY_ON_UPDATE AFTER UPDATE ON <TABLENAME>
FOR EACH ROW
BEGIN
	UPDATE <TABLENAME>_H SET END_DATE = NOW() WHERE <PRIMARYKEY> = NEW.<PRIMARYKEY> AND END_DATE IS NULL;
    INSERT INTO <TABLENAME>_H  (SELECT *, NOW(), NULL FROM <TABLENAME> WHERE <PRIMARYKEY> = NEW.<PRIMARYKEY>);
END
//

DROP TRIGGER IF EXISTS <TABLENAME>_HISTORY_ON_DELETE//
CREATE TRIGGER <TABLENAME>_HISTORY_ON_DELETE AFTER DELETE ON <TABLENAME>
FOR EACH ROW
BEGIN
	UPDATE <TABLENAME>_H SET END_DATE = NOW() WHERE <PRIMARYKEY> = OLD.<PRIMARYKEY> AND END_DATE IS NULL;
END
//

DELIMITER ;

*/

DELIMITER //

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_ISSUES_HISTORY_ON_INSERT//
CREATE TRIGGER ENGAPP_GITHUB_ISSUES_HISTORY_ON_INSERT AFTER INSERT ON ENGAPP_GITHUB_ISSUES
FOR EACH ROW 	
BEGIN
	INSERT INTO ENGAPP_GITHUB_ISSUES_H  (SELECT *, NOW(), NULL FROM ENGAPP_GITHUB_ISSUES WHERE ISSUE_ID = NEW.ISSUE_ID);
END//
    

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_ISSUES_HISTORY_ON_UPDATE//
CREATE TRIGGER ENGAPP_GITHUB_ISSUES_HISTORY_ON_UPDATE AFTER UPDATE ON ENGAPP_GITHUB_ISSUES
FOR EACH ROW 	
BEGIN
	UPDATE ENGAPP_GITHUB_ISSUES_H SET END_DATE = NOW() WHERE ISSUE_ID = NEW.ISSUE_ID AND END_DATE IS NULL;
    INSERT INTO ENGAPP_GITHUB_ISSUES_H  (SELECT *, NOW(), NULL FROM ENGAPP_GITHUB_ISSUES WHERE ISSUE_ID = NEW.ISSUE_ID);
END
//    

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_ISSUES_HISTORY_ON_DELETE//
CREATE TRIGGER ENGAPP_GITHUB_ISSUES_HISTORY_ON_DELETE AFTER DELETE ON ENGAPP_GITHUB_ISSUES
FOR EACH ROW 
BEGIN
	UPDATE ENGAPP_GITHUB_ISSUES_H SET END_DATE = NOW() WHERE ISSUE_ID = OLD.ISSUE_ID AND END_DATE IS NULL;
END
//

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_ORGANIZATIONS_HISTORY_ON_INSERT//
CREATE TRIGGER ENGAPP_GITHUB_ORGANIZATIONS_HISTORY_ON_INSERT AFTER INSERT ON ENGAPP_GITHUB_ORGANIZATIONS
FOR EACH ROW 	
BEGIN
	INSERT INTO ENGAPP_GITHUB_ORGANIZATIONS_H  (SELECT *, NOW(), NULL FROM ENGAPP_GITHUB_ORGANIZATIONS WHERE ORG_ID = NEW.ORG_ID);
END//
    

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_ORGANIZATIONS_HISTORY_ON_UPDATE//
CREATE TRIGGER ENGAPP_GITHUB_ORGANIZATIONS_HISTORY_ON_UPDATE AFTER UPDATE ON ENGAPP_GITHUB_ORGANIZATIONS
FOR EACH ROW 	
BEGIN
	UPDATE ENGAPP_GITHUB_ORGANIZATIONS_H SET END_DATE = NOW() WHERE ORG_ID = NEW.ORG_ID AND END_DATE IS NULL;
    INSERT INTO ENGAPP_GITHUB_ORGANIZATIONS_H  (SELECT *, NOW(), NULL FROM ENGAPP_GITHUB_ORGANIZATIONS WHERE ORG_ID = NEW.ORG_ID);
END
//    

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_ORGANIZATIONS_HISTORY_ON_DELETE//
CREATE TRIGGER ENGAPP_GITHUB_ORGANIZATIONS_HISTORY_ON_DELETE AFTER DELETE ON ENGAPP_GITHUB_ORGANIZATIONS
FOR EACH ROW 
BEGIN
	UPDATE ENGAPP_GITHUB_ORGANIZATIONS_H SET END_DATE = NOW() WHERE ORG_ID = OLD.ORG_ID AND END_DATE IS NULL;
END
//

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_REPOSITORIES_HISTORY_ON_INSERT//
CREATE TRIGGER ENGAPP_GITHUB_REPOSITORIES_HISTORY_ON_INSERT AFTER INSERT ON ENGAPP_GITHUB_REPOSITORIES
FOR EACH ROW
BEGIN
	INSERT INTO ENGAPP_GITHUB_REPOSITORIES_H  (SELECT *, NOW(), NULL FROM ENGAPP_GITHUB_REPOSITORIES WHERE REPOSITORY_ID = NEW.REPOSITORY_ID);
END//


DROP TRIGGER IF EXISTS ENGAPP_GITHUB_REPOSITORIES_HISTORY_ON_UPDATE//
CREATE TRIGGER ENGAPP_GITHUB_REPOSITORIES_HISTORY_ON_UPDATE AFTER UPDATE ON ENGAPP_GITHUB_REPOSITORIES
FOR EACH ROW
BEGIN
	UPDATE ENGAPP_GITHUB_REPOSITORIES_H SET END_DATE = NOW() WHERE REPOSITORY_ID = NEW.REPOSITORY_ID AND END_DATE IS NULL;
    INSERT INTO ENGAPP_GITHUB_REPOSITORIES_H  (SELECT *, NOW(), NULL FROM ENGAPP_GITHUB_REPOSITORIES WHERE REPOSITORY_ID = NEW.REPOSITORY_ID);
END
//

DROP TRIGGER IF EXISTS ENGAPP_GITHUB_REPOSITORIES_HISTORY_ON_DELETE//
CREATE TRIGGER ENGAPP_GITHUB_REPOSITORIES_HISTORY_ON_DELETE AFTER DELETE ON ENGAPP_GITHUB_REPOSITORIES
FOR EACH ROW
BEGIN
	UPDATE ENGAPP_GITHUB_REPOSITORIES_H SET END_DATE = NOW() WHERE REPOSITORY_ID = OLD.REPOSITORY_ID AND END_DATE IS NULL;
END
//

DROP TRIGGER IF EXISTS ENGAPP_TEAMS_HISTORY_ON_INSERT//
CREATE TRIGGER ENGAPP_TEAMS_HISTORY_ON_INSERT AFTER INSERT ON ENGAPP_TEAMS
FOR EACH ROW
BEGIN
	INSERT INTO ENGAPP_TEAMS_H  (SELECT *, NOW(), NULL FROM ENGAPP_TEAMS WHERE TEAM_ID = NEW.TEAM_ID);
END//


DROP TRIGGER IF EXISTS ENGAPP_TEAMS_HISTORY_ON_UPDATE//
CREATE TRIGGER ENGAPP_TEAMS_HISTORY_ON_UPDATE AFTER UPDATE ON ENGAPP_TEAMS
FOR EACH ROW
BEGIN
	UPDATE ENGAPP_TEAMS_H SET END_DATE = NOW() WHERE TEAM_ID = NEW.TEAM_ID AND END_DATE IS NULL;
    INSERT INTO ENGAPP_TEAMS_H  (SELECT *, NOW(), NULL FROM ENGAPP_TEAMS WHERE TEAM_ID = NEW.TEAM_ID);
END
//

DROP TRIGGER IF EXISTS ENGAPP_TEAMS_HISTORY_ON_DELETE//
CREATE TRIGGER ENGAPP_TEAMS_HISTORY_ON_DELETE AFTER DELETE ON ENGAPP_TEAMS
FOR EACH ROW
BEGIN
	UPDATE ENGAPP_TEAMS_H SET END_DATE = NOW() WHERE TEAM_ID = OLD.TEAM_ID AND END_DATE IS NULL;
END
//

DELIMITER ;
