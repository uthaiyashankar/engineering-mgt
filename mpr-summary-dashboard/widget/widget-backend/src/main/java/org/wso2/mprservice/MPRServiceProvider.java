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

package org.wso2.mprservice;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.carbon.config.ConfigurationException;
import org.wso2.carbon.uiserver.spi.RestApiProvider;
import org.wso2.mprservice.beans.RRMConfigurations;
import org.wso2.mprservice.internal.DataHolder;


import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

/**
 * This class is do the http actions to retrieve the data from ballerina backend for MPR Dashboard.
 * The backend needs to be defined in <SP_HOME>/conf/dashboard/deployment.yaml
 **/
public class MPRServiceProvider {

    private static final Logger logger = LoggerFactory.getLogger(RestApiProvider.class);
    private String hostUrl = "";

    public MPRServiceProvider() {

        try {
            hostUrl = DataHolder.getInstance().getConfigProvider()
                    .getConfigurationObject(RRMConfigurations.class).getMprBackendUrl();

            if (StringUtils.isEmpty(hostUrl)) {
                logger.info("No MPR dashboard backend URL defined.");
            }

        } catch (ConfigurationException e) {
            String error = "Error occurred while reading configs from deployment.yaml. " + e.getMessage();
            logger.info(error, e);
        }

    }

    public Object retrieveProducts() throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {

            URIBuilder uriBuilder = new URIBuilder(hostUrl + "/products");
            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                response = EntityUtils.toString(response1.getEntity(), "UTF-8");
            }
        }
        return response;
    }

    public Object retrieveVersions(String product) throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {

            URIBuilder uriBuilder = new URIBuilder(hostUrl + "/versions");
            uriBuilder.addParameter("product", product);

            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                response = EntityUtils.toString(response1.getEntity(), "UTF-8");
            }
        }
        return response;
    }

    public Object retrievePRCountbyStatus(String product, String version) throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
            URI uri = new URI(hostUrl + "/prcount");

            URIBuilder uriBuilder = new URIBuilder(uri);
            uriBuilder.addParameter("product", product);
            uriBuilder.addParameter("version", version);

            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                HttpEntity entity1 = response1.getEntity();
                response = EntityUtils.toString(entity1, "UTF-8");
            }
        }
        return response;
    }

    public Object retrieveTotalPRCount(String product, String version) throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
            URI uri = new URI(hostUrl + "/totalprcount");

            URIBuilder uriBuilder = new URIBuilder(uri);
            uriBuilder.addParameter("product", product);
            uriBuilder.addParameter("version", version);

            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                HttpEntity entity1 = response1.getEntity();
                response = EntityUtils.toString(entity1, "UTF-8");
            }
        }
        return response;
    }
}
