/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 * <p>
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.mpr.dashboard.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.entity.InputStreamEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicHeader;
import org.apache.http.ssl.SSLContexts;
import org.apache.log4j.Logger;
import org.wso2.mpr.dashboard.model.CustomMessage;
import org.wso2.mpr.dashboard.services.exception.ServiceException;
import org.wso2.mpr.dashboard.utils.PropertyReader;

import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;
import java.util.Collections;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import static org.wso2.mpr.dashboard.utils.Constants.BEARER_AUTH_PREFIX;

/**
 * This class is sued to route HTTP request.
 */
public class RoutingService extends HttpServlet {

    private static final Logger logger = Logger.getLogger(RoutingService.class);
    private static final ObjectMapper mapper = new ObjectMapper();

    /**
     * Create a trusted http client to initiate a secure connection with micro services.
     *
     * @return closeableHttpClient
     */
    private static CloseableHttpClient createTrustedHttpClient(PropertyReader properties) {

        HttpClientBuilder httpClientBuilder = HttpClientBuilder.create();

        // Get the keystore file.

        try (InputStream trustStoreFile = Thread.currentThread().getContextClassLoader()
                .getResourceAsStream(properties.getTrustStoreServicePath())) {

            // Make the trusted connection.
            KeyStore trustStore = KeyStore.getInstance("PKCS12");
            trustStore.load(trustStoreFile, properties.getTrustStoreServicePassword().toCharArray());

            HostnameVerifier allowAllHosts = new NoopHostnameVerifier();
            SSLContext sslContext = SSLContexts.custom()
                    .loadTrustMaterial(trustStore, null)
                    .build();
            SSLConnectionSocketFactory sslSocketFactory = new SSLConnectionSocketFactory(sslContext, allowAllHosts);
            httpClientBuilder.setSSLSocketFactory(sslSocketFactory);

            if (logger.isDebugEnabled()) {
                logger.debug("A secure connection is established with the backend service.");
            }

            return httpClientBuilder.build();
        } catch (KeyStoreException | CertificateException | NoSuchAlgorithmException | IOException |
                KeyManagementException e) {
            logger.error("Failed to initiate the connection.", e);
            throw new ServiceException("Failed to initiate the connection.", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest servletRequest, HttpServletResponse servletResponse) throws IOException {

        PropertyReader properties = PropertyReader.getInstance();
        String url = properties.getBackendServiceUrl() + servletRequest.getPathInfo();

        if (servletRequest.getQueryString() != null) {
            url += "?" + URLEncoder.encode(servletRequest.getQueryString(), "UTF-8");
        }


        try {
            // Create the request.
            URIBuilder builder = new URIBuilder(url);
            HttpGet backendRequest = new HttpGet(builder.build());

            backendRequest.setHeaders(Collections.list(servletRequest.getHeaderNames())
                    .stream()
                    .map(header -> new BasicHeader(header, servletRequest.getHeader(header)))
                    .toArray(Header[]::new));
            backendRequest.setHeader(new BasicHeader(HttpHeaders.AUTHORIZATION,
                    BEARER_AUTH_PREFIX + properties.getBackendServiceToken()));

            CloseableHttpClient httpClient = createTrustedHttpClient(properties);
            HttpResponse backendResponse = httpClient.execute(backendRequest);

            if (logger.isDebugEnabled()) {
                logger.debug("Backend response status code : " + backendResponse.getStatusLine().getStatusCode() +
                        " & reason phrase : " + backendResponse.getStatusLine().getReasonPhrase());
            }

            servletResponse.setStatus(backendResponse.getStatusLine().getStatusCode());
            HttpEntity entity = backendResponse.getEntity();
            servletResponse.setHeader(entity.getContentType().getName(), entity.getContentType().getValue());
            entity.writeTo(servletResponse.getOutputStream());

        } catch (URISyntaxException | IOException e) {
            logger.error("Failed to GET response from backend server with url : " + url, e);
            CustomMessage customMessage = new CustomMessage("error", "Failed to get response from server.");
            servletResponse.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            mapper.writeValue(servletResponse.getOutputStream(), customMessage);
        } catch (ServiceException e) {
            logger.error("Failed to create backend connection with url  : " + url, e);
            CustomMessage customMessage = new CustomMessage("error", e.getMessage());
            servletResponse.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            mapper.writeValue(servletResponse.getOutputStream(), customMessage);
        }


    }

    @Override
    protected void doPost(HttpServletRequest servletRequest, HttpServletResponse servletResponse) throws IOException {

        PropertyReader properties = PropertyReader.getInstance();
        String url = properties.getBackendServiceUrl() + servletRequest.getPathInfo();

        if (servletRequest.getQueryString() != null) {
            url += "?" + URLEncoder.encode(servletRequest.getQueryString(), "UTF-8");
        }


        try {
            URIBuilder builder = new URIBuilder(url);
            HttpPost backendRequest = new HttpPost(builder.build());

            backendRequest.setHeaders(Collections.list(servletRequest.getHeaderNames())
                    .stream()
                    .filter(header -> !header.equalsIgnoreCase(HttpHeaders.CONTENT_LENGTH))
                    .map(header -> new BasicHeader(header, servletRequest.getHeader(header)))
                    .toArray(Header[]::new));
            backendRequest.setHeader(new BasicHeader(HttpHeaders.AUTHORIZATION,
                    BEARER_AUTH_PREFIX + properties.getBackendServiceToken()));
            InputStreamEntity streamEntity = new InputStreamEntity(servletRequest.getInputStream());
            backendRequest.setEntity(streamEntity);

            CloseableHttpClient httpClient = createTrustedHttpClient(properties);
            HttpResponse backendResponse = httpClient.execute(backendRequest);

            if (logger.isDebugEnabled()) {
                logger.debug("Backend response status code : " + backendResponse.getStatusLine().getStatusCode() +
                        " & reason phrase : " + backendResponse.getStatusLine().getReasonPhrase());
            }

            servletResponse.setStatus(backendResponse.getStatusLine().getStatusCode());
            HttpEntity entity = backendResponse.getEntity();
            servletResponse.setHeader(entity.getContentType().getName(), entity.getContentType().getValue());
            entity.writeTo(servletResponse.getOutputStream());

        } catch (URISyntaxException | IOException e) {
            logger.error("Failed to POST response from backend server with url" + url, e);
            CustomMessage customMessage = new CustomMessage("error", "Failed to get response from server.");
            servletResponse.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            mapper.writeValue(servletResponse.getOutputStream(), customMessage);
        } catch (ServiceException e) {
            logger.error("Failed to create backend connection with url  : " + url, e);
            CustomMessage customMessage = new CustomMessage("error", e.getMessage());
            servletResponse.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            mapper.writeValue(servletResponse.getOutputStream(), customMessage);
        }
    }
}
