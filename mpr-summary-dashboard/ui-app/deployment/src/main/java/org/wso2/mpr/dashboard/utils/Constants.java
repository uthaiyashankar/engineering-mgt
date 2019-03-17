/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 * <p>
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * public
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.mpr.dashboard.utils;


public class Constants {
    // Constants for accessing configuration details.
    static final String CONFIG_FILE_NAME = "application.properties";
    static final String BACKEND_SERVICE_URL = "backend-service.url";
    static final String BACKEND_SERVICE_AUTH_TOKEN = "backend-service.auth.token";
    static final String SSO_KEYSTORE_PATH = "sso.keystore.path";
    static final String SSO_KEYSTORE_PASSWORD = "sso.keystore.password";
    static final String SSO_CERTIFICATE_ALIAS = "sso.certificate.alias";
    static final String SSO_REDIRECT_URL = "sso.redirect-url";
    static final String HTTPS_TRUST_STORE_PATH = "https.trust.store.path";
    static final String HTTPS_TRUST_STORE_PASSWORD = "https.trust.store.password";
    static final String EDITABLE_USER_ROLES = "editable.user.roles";

    public static final String BEARER_AUTH_PREFIX = "Bearer ";
    public static final String ACCESS_CONTROL_ALLOW_HEADERS = "Access-Control-Allow-Headers";
    public static final String ACCESS_CONTROL_ALLOW_HEADERS_VALUE = "Origin, Accept, X-Requested-With, Content-Type, " +
            "Access-Control-Request-Method, Access-Control-Request-Headers";
    public static final String TEXT_PLAIN = "text/plain";


    public static final String ROLES = "roles";
    public static final String USER = "user";




}

