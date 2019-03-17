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

package org.wso2.codecoverageservice.beans;

/**
 * This is a beans class for code coverage summary for a particular day.
 */
public class DaySummary {
    private int totalIns;
    private int missIns;
    private int totalBranches;
    private int missBranches;
    private int totalCxty;
    private int missCxty;
    private int totalLines;
    private int missLines;
    private int totalMethods;
    private int missMethods;
    private int totalClasses;
    private int missClasses;

    public int getTotalIns() {
        return totalIns;
    }

    private void setTotalIns(int totalIns) {
        this.totalIns = totalIns;
    }

    public int getMissIns() {
        return missIns;
    }

    private void setMissIns(int missIns) {
        this.missIns = missIns;
    }

    public int getTotalBranches() {
        return totalBranches;
    }

    private void setTotalBranches(int totalBranches) {
        this.totalBranches = totalBranches;
    }

    public int getMissBranches() {
        return missBranches;
    }

    private void setMissBranches(int missBranches) {
        this.missBranches = missBranches;
    }

    public int getTotalCxty() {
        return totalCxty;
    }

    private void setTotalCxty(int totalCxty) {
        this.totalCxty = totalCxty;
    }

    public int getMissCxty() {
        return missCxty;
    }

    private void setMissCxty(int missCxty) {
        this.missCxty = missCxty;
    }

    public int getTotalLines() {
        return totalLines;
    }

    private void setTotalLines(int totalLines) {
        this.totalLines = totalLines;
    }

    public int getMissLines() {
        return missLines;
    }

    private void setMissLines(int missLines) {
        this.missLines = missLines;
    }

    public int getTotalMethods() {
        return totalMethods;
    }

    private void setTotalMethods(int totalMethods) {
        this.totalMethods = totalMethods;
    }

    public int getMissMethods() {
        return missMethods;
    }

    private void setMissMethods(int missMethods) {
        this.missMethods = missMethods;
    }

    public int getTotalClasses() {
        return totalClasses;
    }

    private void setTotalClasses(int totalClasses) {
        this.totalClasses = totalClasses;
    }

    public int getMissClasses() {
        return missClasses;
    }

    private void setMissClasses(int missClasses) {
        this.missClasses = missClasses;
    }

    public DaySummary(int totalIns, int missIns, int totalBranches, int missBranches, int totalCxty, int missCxty,
               int totalLines, int missLines, int totalMethods, int missMethods, int totalClasses, int missClasses) {
        setTotalIns(totalIns);
        setMissIns(missIns);
        setTotalBranches(totalBranches);
        setMissBranches(missBranches);
        setTotalCxty(totalCxty);
        setMissCxty(missCxty);
        setTotalLines(totalLines);
        setMissLines(missLines);
        setTotalMethods(totalMethods);
        setMissMethods(missMethods);
        setTotalClasses(totalClasses);
        setMissClasses(missClasses);
    }

}
