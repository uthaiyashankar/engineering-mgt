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

package org.wso2.git.issue.service;

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
import org.wso2.git.issue.service.internal.DataHolder;
import org.wso2.git.issue.service.internal.RRMConfigurations;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

/**
 * This class do the http actions to retrieve the data from ballerina backend
 **/
public class GitServiceProvider {
    private static final Logger log = LoggerFactory.getLogger(GitServiceProvider.class);
    private static String hostUrl = "";

    static {
        try {
            hostUrl = DataHolder.getInstance().getConfigProvider().getConfigurationObject
                    (RRMConfigurations.class).getGitIssueBackendUrl();
        } catch (ConfigurationException e) {
            log.error("Error occurred while reading Host Url for git issue backend ", e);
        }
    }


    public Object retrieveIssuesFromRepoByLabel(String labels, String repos) throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {

            URIBuilder uriBuilder = new URIBuilder(hostUrl + "repository/label");
            uriBuilder.addParameter("labels", labels);
            uriBuilder.addParameter("repos", repos);

            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                response = EntityUtils.toString(response1.getEntity(), "UTF-8");
            }
        }
        return response;
    }

    public Object retrieveIssuesFromProduct(String product, String labels) throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
            URI uri = new URI(hostUrl + "product/" + product.replace(" ", "%20"));

            URIBuilder uriBuilder = new URIBuilder(uri);
            uriBuilder.addParameter("labels", labels);

            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                HttpEntity entity1 = response1.getEntity();
                response = EntityUtils.toString(entity1, "UTF-8");
            }
        }
        return response;
    }

    public Object retrieveRepoNamesByProduct(String product) throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
            URI uri = new URI(hostUrl + "repos/");

            URIBuilder uriBuilder = new URIBuilder(uri);
            uriBuilder.addParameter("product", product);

            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                HttpEntity entity1 = response1.getEntity();
                response = EntityUtils.toString(entity1, "UTF-8");
            }
        }
        return response;
    }


    public Object retrieveProductNames() throws IOException, URISyntaxException {
        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
            URI uri = new URI(hostUrl + "products/");

            URIBuilder uriBuilder = new URIBuilder(uri);

            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                HttpEntity entity1 = response1.getEntity();
                response = EntityUtils.toString(entity1, "UTF-8");
            }
        }
        return response;
    }
}
