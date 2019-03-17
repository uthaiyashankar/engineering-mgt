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

package org.wso2.mpr.dashboard.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.log4j.Logger;
import org.wso2.mpr.dashboard.model.CustomMessage;
import org.wso2.mpr.dashboard.utils.PropertyReader;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import static org.wso2.mpr.dashboard.utils.Constants.ACCESS_CONTROL_ALLOW_HEADERS;
import static org.wso2.mpr.dashboard.utils.Constants.ACCESS_CONTROL_ALLOW_HEADERS_VALUE;
import static org.wso2.mpr.dashboard.utils.Constants.ROLES;
import static org.wso2.mpr.dashboard.utils.Constants.TEXT_PLAIN;
import static org.wso2.mpr.dashboard.utils.Constants.USER;

/**
 *
 */
public class AuthorizationService extends HttpServlet {
    private static final Logger logger = Logger.getLogger(AuthorizationService.class);
    private static final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            response.setHeader(ACCESS_CONTROL_ALLOW_HEADERS, ACCESS_CONTROL_ALLOW_HEADERS_VALUE);
            response.setContentType(TEXT_PLAIN);

            String[] roles = String.valueOf(request.getSession().getAttribute(ROLES)).split(",");
            String username = String.valueOf(request.getSession().getAttribute(USER));

            boolean editable = false;
            L1: for (String role : roles) {
                for (String editableRole : PropertyReader.getInstance().getEditableUserRoles()) {
                    if (role.contains(editableRole)) {
                        editable = true;
                        break L1;
                    }
                }
            }

            mapper.writeValue(response.getOutputStream(), new AccessGrant(username, editable));

        } catch (IOException e) {
            logger.error("Failed to request access grants", e);
            CustomMessage customMessage = new CustomMessage("error", "Failed to get response from server.");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            mapper.writeValue(response.getOutputStream(), customMessage);
        }
    }

    private class AccessGrant {
        private String username;
        private boolean editable;

        AccessGrant(String username, boolean editable) {
            this.username = username;
            this.editable = editable;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public boolean isEditable() {
            return editable;
        }

        public void setEditable(boolean editable) {
            this.editable = editable;
        }
    }
}
