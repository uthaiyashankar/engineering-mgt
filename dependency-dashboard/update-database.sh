#!/bin/bash

DB_USERNAME=""
DB_PASSWORD=""
DATABASE=""
DB_HOST=""
product=''
usingLastVersion=$(xmllint --xpath 'DependencyUpdatesReport/summary/usingLastVersion/text()' dependency-updates-report.xml)
nextVersionAvailable=$(xmllint --xpath 'DependencyUpdatesReport/summary/nextVersionAlailable/text()' dependency-updates-report.xml)
nextIncremetalAvailable=$(xmllint --xpath 'DependencyUpdatesReport/summary/nextIncremetalAvailable/text()' dependency-updates-report.xml)
nextMinorAvailable=$(xmllint --xpath 'DependencyUpdatesReport/summary/nextMinorAvailable/text()' dependency-updates-report.xml)
nextMajorAvailable=$(xmllint --xpath 'DependencyUpdatesReport/summary/nextMajorAvailable/text()' dependency-updates-report.xml)

function insertDataToDatabase {
repoResult=$(mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOST} ${DATABASE} -e "SELECT REPO_ID FROM PRODUCT_REPOS WHERE REPO_NAME='$product'")
repoId=`echo $repoResult | awk '{print $2}'`

if [ -z "$repoId" ]
then
echo "No matching repo found..."
exit 1
fi

dependencyResult=$(mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOST} ${DATABASE} -e "SELECT SUMMARY_ID FROM DEPENDENCY_SUMMARY WHERE REPO_ID=$repoId")
summaryId=`echo $dependencyResult | awk '{print $2}'`
if [ -z "$summaryId" ]
then
    echo "inserting new summary data..."
    mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOST} ${DATABASE} -e \
    "INSERT INTO DEPENDENCY_SUMMARY (REPO_ID, USING_LASTEST_VERSIONS, NEXT_VERSION_AVAILABLE,NEXT_INCREMENTAL_AVAILABLE,NEXT_MINOR_AVAILABLE,NEXT_MAJOR_AVAILABLE) VALUES('$repoId',$usingLastVersion,$nextVersionAvailable,$nextIncremetalAvailable,$nextMinorAvailable,$nextMajorAvailable)" 
else
    echo "updating summary data..."
        mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOST} ${DATABASE} -e \
    "UPDATE DEPENDENCY_SUMMARY SET USING_LASTEST_VERSIONS=$usingLastVersion, NEXT_VERSION_AVAILABLE=$nextVersionAvailable, NEXT_INCREMENTAL_AVAILABLE=$nextIncremetalAvailable, NEXT_MINOR_AVAILABLE=$nextMinorAvailable, NEXT_MAJOR_AVAILABLE=$nextMajorAvailable WHERE SUMMARY_ID=$summaryId" 
fi
}
# capture named arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}' | awk -F/ '{print $NF}'`

    case ${PARAM} in
        --github-url)
            product=${VALUE}
            ;;
        *)
            echo "ERROR: unknown parameter \"${PARAM}\""
            exit 1
            ;;
    esac
    shift
done

insertDataToDatabase
