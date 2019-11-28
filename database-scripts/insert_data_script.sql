
INSERT INTO `ENGAPP_GITHUB_ORGANIZATIONS` VALUES 
(-1,  '-1', 'unknown'),
(1, '-1', 'wso2'),
(2, '-1', 'wso2-extensions'),
(3, '-1', 'ballerina-platform'),
(4, '-1', 'ballerina-guides'),
(5, '-1', 'wso2-ballerina'),
(6, '-1', 'ballerinax'),
(7, '-1', 'siddhi-io'),
(8, '-1', 'wso2-cellery'), 
(9, '-1', 'wso2-enterprise');

INSERT INTO `ENGAPP_TEAMS` VALUES 
(-1, 'Unknown', 'Unknown', 'Other'),
(1, 'API Manager', 'APIM', 'Product'),
(2, 'Integration', 'EI', 'Product'),
(3, 'Identitiy & Access Management', 'IAM', 'Product'),
(4, 'Open Banking', 'OB', 'Product'),
(5, 'Installation Experience', 'IE', 'Other'),
(6, 'Cellery', 'Cellery', 'OSS'),
(7, 'Siddhi', 'Siddhi', 'OSS'),
(8, 'Choreo', 'Choreo', 'Product'),
(9, 'Cloud', 'Cloud', 'Product'),
(10, 'Ballerina', 'Ballerina', 'OSS');


update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 7 where URL like 'https://github.com/siddhi-io/%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 2 where URL like 'https://github.com/wso2-extensions/esb-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 6 where URL like 'https://github.com/wso2-cellery/%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 3 where URL like 'https://github.com/wso2-extensions/identity-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 7 where URL like 'https://github.com/wso2-extensions/siddhi-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 10 where URL like 'https://github.com/ballerina%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 1 where URL like 'https://github.com/wso2-extensions/apim-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/aws-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/docker-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/ansible-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/kubernetes-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/puppet-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/dcos-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/testgrid-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/pivotal-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/vagrant-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 3 where URL like '%-is' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 5 where URL like 'https://github.com/wso2/chef-%';
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 1 where URL like '%-apim' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 2 where URL like '%-ei' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 2 where URL like '%-integrator%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 2 where URL like 'https://github.com/wso2/transport-%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 8 where URL like '%choreo%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 10 where URL like 'https://github.com/wso2/ballerina-%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 1 where URL like 'https://github.com/wso2/carbon-apimgt%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 3 where URL like 'https://github.com/wso2/carbon-identity%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 3 where URL like 'https://github.com/wso2/identity-%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 2 where URL like 'https://github.com/wso2/ei-%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 4 where URL like 'https://github.com/wso2/ob-%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 4 where URL like '%open-banking%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 1 where URL like '%microgateway%' and team_ID is NULL;
update ENGAPP_GITHUB_REPOSITORIES set TEAM_ID = 1 where URL like 'https://github.com/wso2/apim-%' and team_ID is NULL;
