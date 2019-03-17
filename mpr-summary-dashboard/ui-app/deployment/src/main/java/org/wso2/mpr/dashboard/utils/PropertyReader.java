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

package org.wso2.mpr.dashboard.utils;

import org.apache.log4j.Logger;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * This class is used to access application properties.
 */

public class PropertyReader {

    private static final Logger log = Logger.getLogger(PropertyReader.class);
    private static final String configFileName = Constants.CONFIG_FILE_NAME;
    private static PropertyReader instance = null;
    private String backendServiceUrl;
    private String backendServiceToken;
    private String ssoKeyStorePath;
    private String ssoKeyStorePassword;
    private String ssoCertAlias;
    private String ssoRedirectUrl;
    private String trustStoreServicePath;
    private String trustStoreServicePassword;
    private String[] editableUserRoles;

    private PropertyReader() {
        InputStream inputStream = getClass().getClassLoader().getResourceAsStream(configFileName);
        loadConfigs(inputStream);
    }

    public static PropertyReader getInstance() {
        if (instance == null) {
            instance = new PropertyReader();
        }

        return instance;
    }

    /**
     * Load configs from the file.
     *
     * @param input - input stream of the file
     */
    private void loadConfigs(InputStream input) {

        Properties prop = new Properties();
        try {
            prop.load(input);
            this.backendServiceUrl = prop.getProperty(Constants.BACKEND_SERVICE_URL);
            this.backendServiceToken = prop.getProperty(Constants.BACKEND_SERVICE_AUTH_TOKEN);
            this.ssoKeyStorePath = prop.getProperty(Constants.SSO_KEYSTORE_PATH);
            this.ssoKeyStorePassword = prop.getProperty(Constants.SSO_KEYSTORE_PASSWORD);
            this.ssoCertAlias = prop.getProperty(Constants.SSO_CERTIFICATE_ALIAS);
            this.ssoRedirectUrl = prop.getProperty(Constants.SSO_REDIRECT_URL);
            this.trustStoreServicePath = prop.getProperty(Constants.HTTPS_TRUST_STORE_PATH);
            this.trustStoreServicePassword = prop.getProperty(Constants.HTTPS_TRUST_STORE_PASSWORD);
            this.editableUserRoles = prop.getProperty(Constants.EDITABLE_USER_ROLES).split(",");

        } catch (FileNotFoundException e) {
            log.error("The configuration file is not found", e);
        } catch (IOException e) {
            log.error("The File cannot be read", e);
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    log.warn("The File InputStream is not closed", e);
                }
            }
        }

    }

    public String getBackendServiceUrl() {
        return backendServiceUrl;
    }

    public String getBackendServiceToken() {
        return backendServiceToken;
    }

    public String getSsoKeyStorePath() {
        return ssoKeyStorePath;
    }

    public String getSsoKeyStorePassword() {
        return ssoKeyStorePassword;
    }

    public String getSsoCertAlias() {
        return ssoCertAlias;
    }

    public String getSsoRedirectUrl() {
        return ssoRedirectUrl;
    }

    public String getTrustStoreServicePath() {
        return trustStoreServicePath;
    }

    public String getTrustStoreServicePassword() {
        return trustStoreServicePassword;
    }

    public String[] getEditableUserRoles() {
        return editableUserRoles;
    }
}
