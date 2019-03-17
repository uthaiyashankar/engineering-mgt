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

import com.zaxxer.hikari.HikariDataSource;
import org.osgi.framework.BundleContext;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.carbon.datasource.core.api.DataSourceService;
import org.wso2.carbon.datasource.core.exception.DataSourceException;
import org.wso2.carbon.uiserver.api.App;
import org.wso2.carbon.uiserver.spi.RestApiProvider;
import org.wso2.codecoverageservice.utils.DataValueHolder;
import org.wso2.msf4j.Microservice;

import java.util.HashMap;
import java.util.Map;

/**
 * Application entry point.
 *
 * @since 0.0.1-SNAPSHOT
 */
@Component(service = RestApiProvider.class, immediate = true)
public class CodeCoverageRestApiProvider implements RestApiProvider {

    public static final String DASHBOARD_PORTAL_APP_NAME = "portal";
    private static final Logger LOGGER = LoggerFactory.getLogger(RestApiProvider.class);

    @Activate
    protected void activate(BundleContext bundleContext) {
        LOGGER.debug("{} activated.", this.getClass().getName());
    }

    @Deactivate
    protected void deactivate(BundleContext bundleContext) {
        LOGGER.debug("{} deactivated.", this.getClass().getName());
    }

    @Override
    public String getAppName() {
        return DASHBOARD_PORTAL_APP_NAME;
    }

    @Override
    public Map<String, Microservice> getMicroservices(App app) {
        Map<String, Microservice> microservices = new HashMap<>(1);
        microservices.put(CodeCoverageService.API_CONTEXT_PATH, new CodeCoverageService());
        LOGGER.info("Code coverage service started.");
        return microservices;
    }

    @Reference(
            name = "org.wso2.carbon.datasource.DataSourceService",
            service = DataSourceService.class,
            cardinality = ReferenceCardinality.AT_LEAST_ONE,
            policy = ReferencePolicy.DYNAMIC,
            unbind = "unregisterDataSourceService"
    )

    protected void onDataSourceServiceReady(DataSourceService dataSourceService) {
        try {
            HikariDataSource dsObject = (HikariDataSource) dataSourceService.getDataSource("RRMDatasource");
            DataValueHolder.getInstance().setDataSource(dsObject);
            LOGGER.info("RRMDatasource object set.");
        } catch (DataSourceException e) {
            LOGGER.error("error occurred while fetching the data source.", e);
        }
    }

    protected void unregisterDataSourceService(DataSourceService dataSourceService) {
        LOGGER.info("Unregistering data sources sample.");
    }
}
