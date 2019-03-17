#!/bin/bash

# Copyright (c) 2019, WSO2 Inc. (http://wso2.com) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#=============== Properties ==============================================
DB_USER=                # User of the code coverage summary DB
DB_PASS=                # Password of the DB user
HOST=                   # DB host
PORT=                   # DB port number
DATABASE=               # DB name
HOME=                   # path to code-coverage-report folder in the server

#=============== Directories =============================================
JACOCO_DIR=${HOME}/jacoco
JACOCO_TMP_REPORT_DIR=${JACOCO_DIR}/tmp_report
CODE_COVERAGE_REPORTS_DIR=${HOME}/code_coverage_reports
TMP_DIRECTORY=${HOME}/tmp_directory
COMMON_EXECS_DIR=${JACOCO_DIR}/exec
COMMON_CLASSES_DIR=${JACOCO_DIR}/class
TMP_DATA_RECORDER=${TMP_DIRECTORY}/tmp_file.txt
OLD_COVERAGE_REPORTS=${HOME}/old_coverage_reports

# create directories to hold jacoco resources downloaded from jenkins
function create_jacoco_directories {
    mkdir ${JACOCO_DIR}
    mkdir ${COMMON_EXECS_DIR}
    mkdir ${COMMON_CLASSES_DIR}
    mkdir ${JACOCO_TMP_REPORT_DIR}
    mkdir ${TMP_DIRECTORY}
}

# remove jacoco and tmp_directory
function remove_jacoco_and_tmp_directory {
    rm -r ${JACOCO_DIR}
    rm -r ${TMP_DIRECTORY}
}

# get last report generated datetime from DB
function get_last_report_datetime_from_db {
    echo $(mysql --user ${DB_USER} -p${DB_PASS} -h ${HOST} -P ${PORT} ${DATABASE} -Bse \
    "SELECT MAX(DATE) FROM CODE_COVERAGE_SUMMARY;")
}

# get date from datetime
# $1: datetime string (2019-02-26 17:11:40)
function get_date_from_datetime {
    read -r last_report_date last_report_time <<<"$1"
    echo ${last_report_date}
}

# clean old_coverage_reports directory. maximum 7 reports.
function clean_old_reports {
    cd ${OLD_COVERAGE_REPORTS}
    rm -r `ls -t | awk 'NR>7'`
    cd $HOME
}

# back up and remove last code coverage reports directory
function backup_last_coverage_reports_directory {
    last_report_datetime=$(get_last_report_datetime_from_db)
    last_report_date=$(get_date_from_datetime ${last_report_datetime})

    if [[ ! -d "$OLD_COVERAGE_REPORTS/$last_report_date" ]]; then
        echo "adding coverage reports to old_coverage_reports/$last_report_date"
        # add coverage reports to old_coverage_reports directory
        mkdir ${OLD_COVERAGE_REPORTS}/${last_report_date}
        cp -r ${CODE_COVERAGE_REPORTS_DIR} ${OLD_COVERAGE_REPORTS}/${last_report_date}
        # clean old_coverage_reports folder
        clean_old_reports
    fi

    # remove code_coverage_reports folder
    rm -r ${CODE_COVERAGE_REPORTS_DIR}
}

# get exec files from multiple jacoco resources folders and put them in to common directory
# pom file takes all exec files inside common directory (jacoco/exec/)
function get_exec_files_to_common_dir {
    cd ${TMP_DIRECTORY}
    iterator=1

    while IFS=$'\t' read -r -a exec_file ; do
        cp ${exec_file} ${COMMON_EXECS_DIR}
        mv ${COMMON_EXECS_DIR}/jacoco.exec ${COMMON_EXECS_DIR}/jacoco${iterator}.exec
        iterator=$((iterator+1))
    done < <(find . -mount -name 'jacoco.exec')
}

# copy class to common classes directory
# $1: path of the class
function cp_instance_classes_to_common_classes_dir {
    cp -r $1 ${COMMON_CLASSES_DIR}
}

# get class files from multiple jacoco resources folders and put them in to common directory
# pom file takes all class files inside common class directory (jacoco/class/classes/)
function get_classes_to_common_dir {
    cd ${TMP_DIRECTORY}

    while IFS=$'\t' read -r -a class_dir ; do
        cp_instance_classes_to_common_classes_dir ${class_dir}
    done < <(find . -mount -name 'classes')
}

# copy report from tmp_report folder to code_coverage_reports/<product name> directory
# pom file generates report in the tmp_report folder
# $1: product abbreviation
function copy_report_form_tmp_report_to_code_coverage_reports {
    # make directory from product name in the code_coverage_reports directory
    mkdir ${CODE_COVERAGE_REPORTS_DIR}/$1
    # copy generated report from ${HOME}/jacoco/tmp_report to ${HOME}/code_coverage_reports/${product_name} directory
    cp -a ${JACOCO_DIR}/tmp_report/. ${HOME}/code_coverage_reports/$1
}

# get value inside <td> inside <tr> by <td> order number
# $1: <td> order number (n th <td> inside <tr>)
function get_td_value { # td order number
    value=$(xmllint --html --xpath "//td[$1]/text()" ${TMP_DATA_RECORDER})
    echo ${value//,} # remove "," from number string
}

# insert report summary to summary table of the DB
# $1: product id
# $2: build repo and number string
# $3: product abbreviation
function insert_report_summary_to_db {
    product_id=$1
    builds=$2
    product_abbr=$3
    date=`date '+%Y-%m-%d %H:%M:%S'`

    touch ${TMP_DATA_RECORDER}
    echo "$(xmllint --html --xpath "//tr/td[contains(text(),'Total')][1]/.." ${CODE_COVERAGE_REPORTS_DIR}/${product_abbr}/index.html)" > ${TMP_DATA_RECORDER}

    # instructions
    ins_data=$(xmllint --html --xpath "//td[2]/text()" ${TMP_DATA_RECORDER})
    read -r ins_missed of ins_total <<<"$ins_data"
    total_ins=${ins_total//,/}
    missed_ins=${ins_missed//,/}

    # branches
    br_data=$(xmllint --html --xpath "//td[4]/text()" ${TMP_DATA_RECORDER})
    read -r br_missed of br_total <<<"$br_data"
    total_br=${br_total//,/}
    missed_br=${br_missed//,/}

    total_cxty=$(get_td_value 7)
    missed_cxty=$(get_td_value 6)
    total_lines=$(get_td_value 9)
    missed_lines=$(get_td_value 8)
    total_methods=$(get_td_value 11)
    missed_methods=$(get_td_value 10)
    total_class=$(get_td_value 13)
    missed_class=$(get_td_value 12)

    # insert data to database
    mysql --user ${DB_USER} -p${DB_PASS} -h ${HOST} -P ${PORT} ${DATABASE} -Bse \
    "INSERT INTO CODE_COVERAGE_SUMMARY VALUES ($product_id, '$builds', '$date', $total_ins, $missed_ins, $total_br, $missed_br, $total_cxty, $missed_cxty, $total_lines, $missed_lines, $total_methods, $missed_methods, $total_class, $missed_class);"

    rm ${TMP_DATA_RECORDER}
}

# delete records older than 100 days from summary table of the DB
function delete_old_summary_records {
    mysql --user ${DB_USER} -p${DB_PASS} -h ${HOST} -P ${PORT} ${DATABASE} -Bse \
    "DELETE FROM CODE_COVERAGE_SUMMARY WHERE DATE < NOW() - INTERVAL 100 DAY;"
}

# log ccReportGenerator scrip running time in a log file
# $1: either "start" / "end"
function log_script_running_time {
    date=`date '+%Y-%m-%d %H:%M:%S'`
    echo "Coverage report generator script $1ed at $date" >> $HOME/code_coverage_log.txt
}

function generator_start_log {
    echo ""
    echo "#####################################################################################################"
    echo "                            CODE COVERAGE GENERATOR                                                  "
    echo "#####################################################################################################"
    echo ""
}

# main method
function MAIN {

    generator_start_log
    log_script_running_time "start"

    # clean last generated reports in  ${HOME}/code_coverage_reports
    backup_last_coverage_reports_directory
    # create cc reports directory
    mkdir ${CODE_COVERAGE_REPORTS_DIR}
    # Get products from database
    while IFS=$'\t' read PRODUCT_ID PRODUCT_NAME PRODUCT_ABBR ;
    do
        echo "####################################################################################################"
        echo PRODUCT_ID:${PRODUCT_ID} PRODUCT_NAME:${PRODUCT_NAME} PRODUCT_ABBR:${PRODUCT_ABBR}

        build_no_str=""

        # create jacoco directories
        create_jacoco_directories

        # Get code coverage report urls
        while IFS=$'\t' read REPO_ID REPO_NAME BUILD_URL ;
        do
            echo "----------------------------------------------------------------------------------------------------"
            echo REPO_ID:${REPO_ID} REPO_NAME:${REPO_NAME} BUILD_URL:${BUILD_URL}

            # Download report zips to the tmp_reports
            if [[ "${#BUILD_URL}" > 0 ]]; then
                cd ${HOME}/tmp_directory
                wget ${BUILD_URL}lastStableBuild/jacoco/resources.zip
                zip_file=(*.zip)

                # Check whether zip file is there
                if [[ -f ${zip_file} ]]; then
                    unzip -q ${zip_file} && mv jacocoResources ${REPO_NAME}
                    rm ${zip_file}
                    # create build no string
                    build_no=$(curl -s ${BUILD_URL}/lastStableBuild/api/json | jq -r '.number')
                    tmp_build_no_str="${REPO_NAME}:${build_no}/"
                    build_no_str+=${tmp_build_no_str}
                else
                    echo "[ERROR] Could not download Jacoco artifact zip. (BUILD_URL: $BUILD_URL)"
                fi
            else
                echo "[ERROR] Code coverage report url is empty (BUILD_URL: $BUILD_URL)"
            fi
            # go to HOME directory back
            cd ${HOME}
        done < <(mysql --user ${DB_USER} -p${DB_PASS} -h ${HOST} -P ${PORT} ${DATABASE} -Bse \
        "SELECT r.REPO_ID, r.REPO_NAME, r.BUILD_URL FROM PRODUCT p, PRODUCT_REPOS r WHERE p.PRODUCT_ID = r.PRODUCT_ID AND r.BUILD_URL IS NOT NULL AND p.PRODUCT_ID=$PRODUCT_ID;")

        # move execs and class to common directory in tmp_directory
        get_exec_files_to_common_dir
        get_classes_to_common_dir

        # Merge reports
        # build pom
        mvn clean install -f ${HOME}/pom.xml # if you get mvn not found error, give mvn path

        copy_report_form_tmp_report_to_code_coverage_reports ${PRODUCT_ABBR}
        # Get summary of the report and enter to DB
        insert_report_summary_to_db ${PRODUCT_ID} ${build_no_str} ${PRODUCT_ABBR}
        # remove jacoco and tmp directories
        remove_jacoco_and_tmp_directory
        rm $HOME/merged.exec

    done < <(mysql --user ${DB_USER} -p${DB_PASS} -h ${HOST} -P ${PORT} ${DATABASE} -Bse \
    "SELECT DISTINCT p.PRODUCT_ID, p.PRODUCT_NAME, p.PRODUCT_ABBR FROM PRODUCT p, PRODUCT_REPOS r WHERE p.PRODUCT_ID = r.PRODUCT_ID AND r.BUILD_URL IS NOT NULL ORDER BY p.PRODUCT_ID;")

    delete_old_summary_records

    log_script_running_time "  end"
}

# MAIN method invocation
MAIN #>> $HOME/full_log.txt 2>&1 # uncomment this line if you want to log full output of the bash file.
