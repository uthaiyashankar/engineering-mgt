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

package org.wso2.mpr.dashboard.model;

import org.wso2.mpr.dashboard.utils.CommonUtil;

public class CustomMessage {

    private String responseType = "error";
    private String message;

    private CustomMessage(String message, String... args) {
        try {
            this.message = (args.length > 0) ? CommonUtil.generateMessage(message, args) : message;
        } catch (Exception ex) {
            this.message = message;
        }
    }

    public CustomMessage(String responseType, String message, String... args) {
        this(message, args);
        this.responseType = responseType;
    }


    public String getResponseType() {
        return responseType;
    }

    public void setResponseType(String responseType) {
        this.responseType = responseType;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
