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

package org.wso2.codecoverageservice;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.codecoverageservice.beans.DaySummary;
import org.wso2.codecoverageservice.utils.DataValueHolder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Objects;


/**
 * This class is to retrieve the data from wso2 product component test database.
 **/
class CoverageServiceProvider {
    private static final Logger LOGGER = LoggerFactory.getLogger(CoverageServiceProvider.class);

    /**
     * Get coverage summary to display in the line chart.
     *
     * @return chart coverage summary for 100 days
     */
    JsonArray getCoverageSummary() {
        Connection dbConnection = null;
        Statement prodStmt = null;
        Statement summaryStmt = null;
        JsonArray coverageSummary = new JsonArray();

        try {
            dbConnection = DataValueHolder.getInstance().getDataSource().getConnection();
        } catch (SQLException e) {
            LOGGER.error("Database connection failure.", e);
        }

        // add products to coverage summary
        try {
            prodStmt = Objects.requireNonNull(dbConnection).createStatement();
            String productChooser = "SELECT DISTINCT p.PRODUCT_ID, p.PRODUCT_NAME FROM "
                    + "PRODUCT p, PRODUCT_REPOS r WHERE p.PRODUCT_ID = r.PRODUCT_ID AND "
                    + "r.BUILD_URL IS NOT NULL ORDER BY p.PRODUCT_ID";
            ResultSet productsResult = Objects.requireNonNull(prodStmt).executeQuery(productChooser);

            while (productsResult.next()) {
                JsonObject productObj = new JsonObject();
                JsonObject summaryData = new JsonObject();

                // get code coverage summary for particular product
                summaryStmt = dbConnection.createStatement();
                String summaryChooser = "SELECT * FROM PRODUCT p, CODE_COVERAGE_SUMMARY s WHERE "
                        + "p.product_id = s.product_id "
                        + "AND p.product_id = " + productsResult.getInt("product_id")
                        + " ORDER BY date DESC LIMIT 100";
                ResultSet summaryResult = summaryStmt.executeQuery(summaryChooser);

                while (summaryResult.next()) {
                    DaySummary daySummary = new DaySummary(summaryResult.getInt("total_instructions"),
                                                           summaryResult.getInt("missed_instructions"),
                                                           summaryResult.getInt("total_branches"),
                                                           summaryResult.getInt("missed_branches"),
                                                           summaryResult.getInt("total_cxty"),
                                                           summaryResult.getInt("missed_cxty"),
                                                           summaryResult.getInt("total_lines"),
                                                           summaryResult.getInt("missed_lines"),
                                                           summaryResult.getInt("total_methods"),
                                                           summaryResult.getInt("missed_methods"),
                                                           summaryResult.getInt("total_classes"),
                                                           summaryResult.getInt("missed_classes"));
                    summaryData.add(summaryResult.getString("date").split(" ")[0],
                                    new Gson().toJsonTree(daySummary));
                }

                productObj.addProperty("name", productsResult.getString("product_name"));
                productObj.add("data", summaryData);
                coverageSummary.add(productObj);
            }
        } catch (SQLException e) {
            LOGGER.error("Getting product details from database failed");
        } finally {
            closeStatement(dbConnection, prodStmt, summaryStmt);
        }
        return coverageSummary;
    }

    /**
     * get coverage summary to display in the table by date.
     *
     * @param date date want to get the summary
     * @return code coverage summary for a particular date
     */
    JsonArray getTableSummaryByDate(String date) {
        Connection dbConnection = null;
        Statement productStmt = null;
        PreparedStatement ps = null;
        JsonArray coverageSummary = new JsonArray();

        try {
            dbConnection = DataValueHolder.getInstance().getDataSource().getConnection();
        } catch (SQLException e) {
            LOGGER.error("Database connection failure.", e);
        }

        // add products to coverage summary
        try {
            productStmt = Objects.requireNonNull(dbConnection).createStatement();
            String productChooser = "SELECT DISTINCT p.PRODUCT_ID, p.PRODUCT_NAME FROM PRODUCT p, PRODUCT_REPOS r "
                    + "WHERE p.PRODUCT_ID = r.PRODUCT_ID AND r.BUILD_URL IS NOT NULL ORDER BY p.PRODUCT_ID";
            ResultSet productsResult = Objects.requireNonNull(productStmt).executeQuery(productChooser);

            while (productsResult.next()) {
                JsonObject productObj = new JsonObject();

                String summaryChooser = "SELECT * FROM PRODUCT p, CODE_COVERAGE_SUMMARY s WHERE "
                        + " p.product_id = s.product_id AND p.product_id = ? AND s.date LIKE ? "
                        + " ORDER BY s.date DESC LIMIT 1 ";
                ps = dbConnection.prepareStatement(summaryChooser);
                ps.setInt(1, productsResult.getInt("product_id"));
                ps.setString(2,  date + "%");
                ResultSet summaryResult = ps.executeQuery();

                while (summaryResult.next()) {
                    DaySummary daySummary = new DaySummary(summaryResult.getInt("total_instructions"),
                                                           summaryResult.getInt("missed_instructions"),
                                                           summaryResult.getInt("total_branches"),
                                                           summaryResult.getInt("missed_branches"),
                                                           summaryResult.getInt("total_cxty"),
                                                           summaryResult.getInt("missed_cxty"),
                                                           summaryResult.getInt("total_lines"),
                                                           summaryResult.getInt("missed_lines"),
                                                           summaryResult.getInt("total_methods"),
                                                           summaryResult.getInt("missed_methods"),
                                                           summaryResult.getInt("total_classes"),
                                                           summaryResult.getInt("missed_classes"));
                    productObj.add("data", new Gson().toJsonTree(daySummary));
                    productObj.addProperty("date", summaryResult.getString("date"));
                    productObj.addProperty("build_no", summaryResult.getString("builds"));
                }
                productObj.addProperty("name", productsResult.getString("product_name"));
                coverageSummary.add(productObj);
            }
        } catch (SQLException e) {
            LOGGER.error("Getting product details from database failed", e);
        } finally {
            closeStatement(dbConnection, productStmt, ps);
        }
        return coverageSummary;
    }

    /**
     * get last report date from DB.
     * @return last report date
     */
    JsonArray getLastReportDate() {
        Connection dbConnection = null;
        JsonArray dates = new JsonArray();

        try {
            dbConnection = DataValueHolder.getInstance().getDataSource().getConnection();
        } catch (SQLException e) {
            LOGGER.error("Database connection failure.", e);
        }

        String lastReportDateChooser = "SELECT DISTINCT CAST(DATE AS DATE) FROM CODE_COVERAGE_SUMMARY "
                + "ORDER BY DATE DESC;";
        try (PreparedStatement ps = Objects.requireNonNull(dbConnection).prepareStatement(lastReportDateChooser))  {
            ResultSet summaryResult = ps.executeQuery();
            while (summaryResult.next()) {
                JsonObject jsonObject = new JsonObject();
                jsonObject.addProperty("date", summaryResult.getString("CAST(DATE AS DATE)"));
                dates.add(jsonObject);
            }
            summaryResult.close();
        } catch (SQLException e) {
            LOGGER.error("Getting last report date from database failed", e);
        } finally {
            try {
                if (dbConnection != null) {
                    dbConnection.close();
                }
            } catch (Exception e) {
                LOGGER.error("Error occurred when closing SQL connection.", e);
            }
        }
        return dates;
    }

    private void closeStatement(Connection connection, Statement prodStmt, Statement sumStmt) {
        try {
            if (connection != null) {
                connection.close();
            }
            if (prodStmt != null) {
                prodStmt.close();
            }
            if (sumStmt != null) {
                sumStmt.close();
            }
        } catch (SQLException e) {
            LOGGER.error("Error occurred when closing SQL statements.", e);
        }
    }
}
