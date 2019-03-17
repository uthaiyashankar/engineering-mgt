package org.wso2.dependencydashboard;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.carbon.config.ConfigurationException;

import java.io.IOException;
import java.net.URISyntaxException;

/**
 * This class is do the http actions to retrieve the data from ballerina backend for Dependency Dashboard.
 **/
public class DependencySummaryProvider {

    private static final String DEFAULT_HOST = "http://localhost:9091";
    private static final Logger logger = LoggerFactory.getLogger(DependencySummaryProvider.class);

    private String hostUrl = "";

    public DependencySummaryProvider() {

        try {
            hostUrl = DataHolder.getInstance().getConfigProvider()
                    .getConfigurationObject(RRMConfigurations.class).getBackendUrl();

            if (StringUtils.isEmpty(hostUrl)) {
                hostUrl = DEFAULT_HOST;
                logger.info("No dependency dashboard backend URL defined. using default url " + DEFAULT_HOST);
            }

        } catch (ConfigurationException e) {
            String error = "Error occurred while reading configs from deployment.yaml. " + e.getMessage();
            logger.info(error, e);
        }

    }

    public Object findAllSummaryData() throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {

            URIBuilder uriBuilder = new URIBuilder(hostUrl + "/dependency-data/all");
            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                response = EntityUtils.toString(response1.getEntity(), "UTF-8");
            }
        }
        return response;
    }

    public Object findAllProductData() throws IOException, URISyntaxException {

        String response;
        try (CloseableHttpClient httpclient = HttpClients.createDefault()) {

            URIBuilder uriBuilder = new URIBuilder(hostUrl + "/dependency-data/product-data/all");
            HttpGet httpGet = new HttpGet(uriBuilder.build());

            try (CloseableHttpResponse response1 = httpclient.execute(httpGet)) {
                response = EntityUtils.toString(response1.getEntity(), "UTF-8");
            }
        }
        return response;
    }

}
