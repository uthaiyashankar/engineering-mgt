/*
 * Copyright (c) 2019, WSO2 Inc. (http://wso2.com) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import React from 'react';
import './../App.css';
import Loader from 'react-loader-spinner';
import Spinner from 'react-spinner-material';
import { FormControl, InputLabel, Select, MenuItem } from '@material-ui/core';

const styles = {
    warning: {
        textAlign: 'center',
        color: 'red',
        fontSize: '14px',
        fontFamily: 'sans-serif'
    },
    FormControl: {
        margin: '0 20px 30px 0',
        minWidth: 200
    }
}

export let loadData = (loading, func) => {
    return loading ?
        <span style={{
            width: "50",
            height: "50",
            display: "flex",
            justifyContent: "left",
            alignItems: "left"
        }}
        >
            <Loader type="ThreeDots" textAlign="right" color="#3f51b5" height="50" width="50" /></span> : func
}

export let loadVersions = (loading, versions, selectedProductVersion, handleChangeProductVersion) => {
    return loading ?
        <FormControl><Spinner size={30} spinnerColor={"#3f51b5"} spinnerWidth={2} visible={true} /> Loading versions </FormControl >
        : <FormControl style={styles.FormControl}>
            <InputLabel htmlFor="product-version"> Product Version </InputLabel>
            <Select
                disabled={versions.length === 0}
                value={selectedProductVersion}
                onChange={handleChangeProductVersion}
            >
                {versions.map(
                    (version) =>
                        <MenuItem key={version.versionNumber} value={version}> {version.versionTitle} </MenuItem>
                )}
            </Select>
        </FormControl>
}

export let getJiraIssues = (jiraIssues) => {
    if (jiraIssues.length === 0) {
        return <span style={styles.warning}>N/A</span>;
    } else
        return (
            <span>
                <a
                    href={
                        jiraIssues.refLink
                    }
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    {jiraIssues.openIssues}</a><span> open</span>

                <span>/ {jiraIssues.totalIssues} close</span>
            </span>
        );
}

export let getGitIssues = (issues, refLink) => {
    if (typeof issues === 'undefined') {
        return <span style={styles.warning}>N/A</span>;
    } else {
        return (
            <span>
                <a
                    href={
                        refLink
                    }
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    {issues}
                </a>

            </span>
        );
    }
};

export let getCodeCoverage = (coverage) => {
    if (coverage.lineCov === '0') {
        return <span style={styles.warning}>N/A</span>;
    } else {
        return (
            <ul>
                <li>
                    <a href={coverage.refLink} target="_blank" rel="noopener noreferrer">
                        {coverage.instructionCov}
                    </a> % : Instruction coverage
                </li>
                <li>
                    <a href={coverage.refLink} target="_blank" rel="noopener noreferrer">
                        {coverage.complexityCov}
                    </a> % : Complexity coverage
                </li>
                <li>
                    <a href={coverage.refLink} target="_blank" rel="noopener noreferrer">
                        {coverage.lineCov}
                    </a> % : Line coverage
                </li>
                <li>
                    <a href={coverage.refLink} target="_blank" rel="noopener noreferrer">
                        {coverage.methodCov}
                    </a> % : Method coverage
                </li>
                <li>
                    <a href={coverage.refLink} target="_blank" rel="noopener noreferrer">
                        {coverage.classCov}
                    </a> % : Class coverage
                </li>
            </ul>
        );
    }
};

export let getMPRCount = (mergedPRCount) => {
    if (typeof mergedPRCount.mprCount === 'undefined') {
        return <span style={styles.warning}>N/A</span>;
    } else {
        return (
            <span>
                <a
                    href={
                        mergedPRCount.refLink
                    }
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    {mergedPRCount.mprCount}
                </a>

            </span>
        );
    }
};

export let getDependencySummary = (dependencySummary) => {
    if (typeof dependencySummary.dependencySummary === 'undefined') {
        return <span style={styles.warning}>N/A</span>;
    } else {
        return (
            <span>
                <a
                    href={
                        dependencySummary.refLink
                    }
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    {dependencySummary.dependencySummary}
                </a>

            </span>
        );
    }
};
