// You must have an AWS account to use the Amazon Connect CTI Adapter.
// Downloading and/or using the Amazon Connect CTI Adapter is subject to the terms of the AWS Customer Agreement,
// AWS Service Terms, and AWS Privacy Notice.
//
// © 2017, Amazon Web Services, Inc. or its affiliates. All rights reserved.
//
// NOTE:  Other license terms may apply to certain, identified software components
// contained within or distributed with the Amazon Connect CTI Adapter if such terms are
// included in the LibPhoneNumber-js and Salesforce Open CTI. For such identified components,
// such other license terms will then apply in lieu of the terms above.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
'use strict';

(function(ac) {
    if (ac.Utils === undefined) {
        ac.Utils = {};
    }

    /**
     *
     * @type {Map}
     */
    let _props = {};

    const CALL_TYPE = {
        INBOUND: sforce.opencti.CALL_TYPE.INBOUND,
        OUTBOUND: sforce.opencti.CALL_TYPE.OUTBOUND,
        INTERNAL:  sforce.opencti.CALL_TYPE.INTERNAL
    };

    /**
     * @class ac.Utils.Salesforce
     * @memberOf ac.Utils
     *
     * @description
     * The ac.Utils.Salesforce class provides helper methods for Salesforce scripting.
     */
    ac.Utils.Salesforce = {
        /**
         * Initializes the ac.Utils.Salesforce utility
         *
         * @private
         *
         * @param {Object} props
         */
        init: async (props) => {
            _props = props;
        },

        /**
         * Returns entity field value taking into account any namespace value
         *
         * @static
         *
         * @param {String} entity - The object
         * @param {String} field - The field
         *
         * @returns {Object}
         */
        getValueWithNamespace : (entity, field, defaultValue = null) => {
            try {
                if (!field.endsWith('__c') && !field.endsWith('__r')) {
                    return entity.hasOwnProperty(field) ?
                        entity[field] : defaultValue;

                } else {
                    let namespace = _getNamespacePagePrefix();

                    return entity.hasOwnProperty(`${namespace}${field}`) ?
                        entity[`${namespace}${field}`] : defaultValue;
                }
            } catch (err) {
                ac.Utils.Log.error('getValueWithNamespace error');
                return defaultValue;
            }
        },

        /**
         * Gets the current page namespace with prepended "__" (double underscore)
         *
         * @static
         *
         * @returns {String}
         */
        getNamespacePagePrefix : () => {
            return _getNamespacePagePrefix();
        },

        /**
         * Gets the current class namespace with prepended "." (period)
         *
         * @static
         *
         * @returns {String}
         */
        getNamespaceClassPrefix : () => {
            return _getNamespaceClassPrefix();
        },

        /**
         * Gets the current Salesforce User Id
         *
         * @static
         *
         * @returns {String}
         */
        getUserId : () => {
            return _getUserId();
        },

        /**
         * Gets the current Salesforce User Name
         *
         * @static
         *
         * @returns {String}
         */
        getUserName : () => {
            return _getUserName();
        },

        /**
         * Gets the current Salesforce User Email
         *
         * @static
         *
         * @returns {String}
         */
        getUserEmail : () => {
            return _getUserEmail();
        },

        /**
         * Gets the current Salesforce Session Id
         *
         * @static
         *
         * @returns {String}
         */
        getSessionId : () => {
            return _getSessionId();
        },

        /**
         * Gets call center settings
         *
         * @static
         * @async
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_getcallcentersettings_lex.htm
         */
        getCallCenterSettings : () => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.getCallCenterSettings({
                    callback: (response) => {
                        if (response && response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('getCallCenterSettings error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(err);
            }
        }),

        /**
         * Gets the cti adatper object for the specified name
         *
         * @static
         * @async
         *
         * @param {String} name - The name
         *
         * @returns {Promise<Object|Error>}
         */
        getCtiAdapter : (name) => new Promise((resolve, reject) => {
            try {
                Visualforce.remoting.Manager.invokeAction(
                    _getNamespaceClassPrefix() + 'AC_Utils.getCtiAdapter',
                    name,
                    (response, event) => {
                        if (event && event.status && response) {
                            resolve(ac.Utils.Common.buildResolve(response));
                        } else {
                            reject(ac.Utils.Common.buildReject('getCtiAdapter error', response.errors));
                        }
                    }
                );
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getCtiAdapter error', err));
            }
        }),

        /**
         * Examines Amazon Connect permissions for outbound calling to determine if click-to-dial should be enabled
         *
         * @static
         *
         * @returns {Boolean}
         *
         * @throws {Error}
         */
        shouldEnableClickToDial : () => {
            try {
                const agent = ac.Utils.Agent.getAgent();

                if (!agent) {
                    throw ac.Utils.Common.buildError('Agent can not be undefined');
                }

                if (agent.getPermissions().includes("outboundCall")) {
                    return true;
                } else {
                    return false;
                }
            } catch (err) {
                throw ac.Utils.Common.buildError('shouldEnableClickToDial error: ' + err.message);
            }
        },

        /**
         * Disables click-to-dial within the Salesforce UI
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_disableclicktodial_lex.htm
         */
        disableClickToDial : () => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.disableClickToDial({
                    callback: (response) => {
                        if (response && response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('disableClickToDial error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('disableClickToDial error', err));
            }
        }),

        /**
         * Enables click-to-dial within the Salesforce UI
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_enableclicktodial_lex.htm
         */
        enableClickToDial : () => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.enableClickToDial({
                    callback: (response) => {
                        if (response && response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('enableClickToDial error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('enableClickToDial error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_getappviewinfo_lex.htm
         */
        getAppViewInfo : () => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.getAppViewInfo({
                    callback: (response) => {
                        if (response && response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('getAppViewInfo error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getAppViewInfo error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_getsoftphonelayout_lex.htm
         */
        getSoftphoneLayout : () => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.getSoftphoneLayout({
                    callback: (response) => {
                        if (response && response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('getSoftphoneLayout error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getSoftphoneLayout error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_refreshview_lex.htm
         */
        refreshView : () => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.refreshView({
                    callback: (response) => {
                        if (response && response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('refreshView error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('refreshView error', err));
            }
        }),

        /**
         * Shows the softphone panel if it is currently not being shown
         *
         * @static
         * @async
         *
         * @example
         * ac.Utils.Salesforce.showSoftphonePanel();
         *
         * @example
         * await ac.Utils.Salesforce.showSoftphonePanel();
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_setsoftphonepanelvisibility_lex.htm
         */
        showSoftphonePanel : async () => {
            try {
                const isSoftphoneVisible = await _isSoftphonePanelVisible();

                if (!isSoftphoneVisible) {
                    await _setSoftphonePanelVisibility(true);
                }
            } catch (err) {
                throw err;
            }
        },

        /**
         * Hides the softphone panel if it is currently being shown
         *
         * @static
         * @async
         *
         * @example
         * ac.Utils.Salesforce.hideSoftphonePanel();
         *
         * @example
         * await ac.Utils.Salesforce.hideSoftphonePanel();
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_setsoftphonepanelvisibility_lex.htm
         */
        hideSoftphonePanel : async () => {
            try {
                const isSoftphoneVisible = await _isSoftphonePanelVisible();

                if (isSoftphoneVisible) {
                    await _setSoftphonePanelVisibility(false);
                }
            } catch (err) {
                throw err;
            }
        },

        /**
         * Screnpops a record based upon a Salesforce Id
         *
         * @static
         * @async
         *
         * @example
         * ac.Utils.Salesforce.screenPopObject('ABC123');
         *
         * @example
         * await ac.Utils.Salesforce.screenPopObject('ABC123');
         *
         * @param {String} recordId - The record id to pop
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         */
        screenPopObject : (recordId) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.screenPop({
                    type: sforce.opencti.SCREENPOP_TYPE.SOBJECT,
                    params: {
                        recordId: recordId
                    },
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('screenPopObject error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('screenPopObject error', err));
            }
        }),

        /**
         * Screenpops to the specified screenPopData configuration
         *
         * @static
         * @async
         *
         * @param {Object} screenPopData - The screenpop data.  Typically returned from a deferred call to searchAndScreenPop
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         */
        screenPop : (screenPopData) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.screenPop({
                    type: screenPopData.type,
                    params: screenPopData.params,
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(null));
                        } else {
                            reject(ac.Utils.Common.buildReject('screenPopUrl error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('screenPopUrl error', err));
            }
        }),


        /**
         * Screenpops a url in a new browser tab or browser window
         *
         * @static
         * @async
         *
         * @example
         * ac.Utils.Salesforce.screenPopUrl("https://www.salesforce.com");
         *
         * @example
         * await ac.Utils.Salesforce.screenPopUrl("https://www.salesforce.com");
         *
         * @param {String} url - The url to pop
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         */
        screenPopUrl : (url) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.screenPop({
                    type: sforce.opencti.SCREENPOP_TYPE.URL,
                    params: {
                        url: url
                    },
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(null));
                        } else {
                            reject(ac.Utils.Common.buildReject('screenPopUrl error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('screenPopUrl error', err));
            }
        }),

        /**
         * Screenpops to an object's home page
         *
         * @static
         * @async
         *
         * @example
         * ac.Utils.Salesforce.screenPopObjectHome('Contact');
         *
         * @example
         * await ac.Utils.Salesforce.screenPopObjectHome('Contact');
         *
         * @param {String} scope
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         */
        screenPopObjectHome : (scope) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.screenPop({
                    type: sforce.opencti.SCREENPOP_TYPE.OBJECT_HOME,
                    params: {
                        scope: scope
                    },
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(null));
                        } else {
                            reject(ac.Utils.Common.buildReject('screenPopObjectHome error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('screenPopObjectHome error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @param {String} listViewId
         * @param {String} scope
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         */
        screenPopList : (listViewId,
                        scope) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.screenPop({
                    type: sforce.opencti.SCREENPOP_TYPE.LIST,
                    params: {
                        listViewId: listViewId,
                        scope: scope
                    },
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(null));
                        } else {
                            reject(ac.Utils.Common.buildReject('screenPopList error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('screenPopList error', err));
            }
        }),

        /**
         * Screen pops to search results based upon the search input.
         *
         * @static
         * @async
         *
         * @example
         * ac.Utils.Salesforce.screenPopSearch('John Smith);
         *
         * @example
         * await ac.Utils.Salesforce.screenPopSearch('John Smith');
         *
         * @param {String} searchString - The string for which to search
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         */
        screenPopSearch : (searchString) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.screenPop({
                    type: sforce.opencti.SCREENPOP_TYPE.SEARCH,
                    params: {
                        searchString: searchString
                    },
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(null));
                        } else {
                            reject(ac.Utils.Common.buildReject('screenPopSearch error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('screenPopSearch error', err));
            }
        }),

        /**
         * Screen pops to a new record of the specified type with specified default field values
         *
         * @static
         * @async
         *
         * @example
         * ac.Utils.Salesforce.screenPopNewRecord('Case', { 'Subject': 'New Case' });
         *
         * @example
         * await ac.Utils.Salesforce.screenPopNewRecord('Case', { 'Subject': 'New Case' });
         *
         * @param {String} entityName - The Salesforce object type (Account, Contact, Lead, etc)
         * @param {Map<String,Object>} defaultFieldValues - Teh default field values for the new record
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_screenpop_lex.htm
         */
        screenPopNewRecord : (entityName,
                             defaultFieldValues) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.screenPop({
                    type: sforce.opencti.SCREENPOP_TYPE.NEW_RECORD_MODAL,
                    params: {
                        entityName: entityName,
                        defaultFieldValues: defaultFieldValues
                    },
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(null));
                        } else {
                            reject(ac.Utils.Common.buildReject('screenPopNewRecord error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('screenPopNewRecord error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @param {String} apexClass
         * @param {String} methodName
         * @param {Map<String,Object>} methodParams
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_runapex_lex.htm
         */
        runApex : (apexClass,
                  methodName,
                  methodParams) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.runApex({
                    apexClass: apexClass,
                    methodName: methodName,
                    methodParams: methodParams,
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('runApex error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('runApex error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @param searchParams
         * @param queryParams
         * @param {Map<String,Object>} defaultFieldValues
         * @param {String} callType
         * @param {Boolean} deferred - true = Do not pop the results, false = Pop the results
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_searchandscreenpop_lex.htm
         */
        searchAndScreenPop : (searchParams,
                             queryParams,
                             defaultFieldValues,
                             callType,
                             deferred) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.searchAndScreenPop({
                    searchParams: searchParams,
                    queryParams: queryParams,
                    defaultFieldValues: defaultFieldValues,
                    callType: callType,
                    deferred: deferred,
                    callback: (response) => {
                        if (response.success) {
                            resolve(ac.Utils.Common.buildResolve(response.returnValue));
                        } else {
                            reject(ac.Utils.Common.buildReject('searchAndScreenPop error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('searchAndScreenPop error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_getservicepresencestatusid.htm
         */
        getAgentState : () => new Promise((resolve, reject) => {
            try {
                sforce.console && sforce.console.presence && sforce.console.presence.getServicePresenceStatusId((result) => {
                    if (result.success) {
                        resolve(ac.Utils.Common.buildResolve(result));
                    } else {
                        reject(ac.Utils.Common.buildReject('getAgentState error', null));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getAgentState error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @param {String} state
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_setservicepresencestatus.htm
         */
        setAgentState : (state) => new Promise((resolve, reject) => {
            try {
                sforce.console && sforce.console.presence && sforce.console.presence.setServicePresenceStatus(
                    state,
                    function (result) {
                        if (result.success) {
                            resolve(ac.Utils.Common.buildResolve(result));
                        } else {
                            reject(ac.Utils.Common.buildReject('setAgentState error', result.errors));
                        }
                    }
                )
            } catch (err) {
                reject(ac.Utils.Common.buildReject('setAgentState error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @returns {Promise<SalesforceAgentState[]|Error>}
         */
        getAvailableAgentStates : () => new Promise((resolve, reject) => {
            try {
                Visualforce.remoting.Manager.invokeAction(
                    _getNamespaceClassPrefix() + 'AC_Utils.getServicePresenceStatuses',
                    function (result, event) {
                        if (event.status && result) {
                            let states = result.map((state) => {
                                return {
                                    key: state.developerName,
                                    value: state.id.substr(0, 15)
                                };
                            });

                            states.push({
                                key: 'Offline',
                                value: 'Offline'
                            });

                            resolve(ac.Utils.Common.buildResolve(Object.assign({}, ...states.map(s => ({[s.key]: s.value})))));
                        } else {
                            reject(ac.Utils.Common.buildReject('getAvailableAgentStates error', result.errors));
                        }
                    }
                );
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getAvailableAgentStates error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_login.htm
         */
        loginAgent : () => new Promise((resolve, reject) => {
            try {
                sforce.console && sforce.console.presence && sforce.console.presence.login((result) => {
                    if (result.success) {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    } else {
                        reject(ac.Utils.Common.buildReject('loginAgent error', result.errors));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('loginAgent error', err));
            }
        }),

        /**
         * Logs out the Salesforce agent
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_logout.htm
         */
        logoutAgent : () => new Promise((resolve, reject) => {
            try {
                sforce.console && sforce.console.presence && sforce.console.presence.logout((result) => {
                    if (result.success) {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    } else {
                        reject(ac.Utils.Common.buildReject('logoutAgent error', result.errors));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('logoutAgent error', err));
            }
        }),

        /**
         * Performs a search and screenpop for the specified phone number and call type
         *
         * @param phoneNumber
         * @param callType
         *
         * @returns {Promise<Object|Error>}
         */
        searchAndScreenPopOnPhoneNumber : (phoneNumber, callType) => {
            return ac.Utils.Salesforce.searchAndScreenPop(phoneNumber, null, null, callType, false);
        },

        /**
         * Gets teh agent's current workload
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_getAgentWorkload.htm
         */
        getAgentWorkload : () => new Promise((resolve, reject) => {
            try {
                sforce.console && sforce.console.presence && sforce.console.presence.getAgentWorkload((result) => {
                    if (result.success) {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    } else {
                        reject(ac.Utils.Common.buildReject('getAgentWorkload error', result.errors));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getAgentWorkload error', err));
            }
        }),

        /**
         * Saves or updates a Salesforce object
         *
         * @static
         * @async
         *
         * @param type
         * @param recordId
         * @param fields
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_savelog_lex.htm
         */
        saveLog : (type, recordId, fields) => new Promise((resolve, reject) => {
            try {
                let value = fields;

                if (recordId) {
                    value.Id = recordId;
                } else {
                    value.entityApiName = type;
                }

                sforce.opencti && sforce.opencti.saveLog({
                    value: value,
                    callback: (response) => {
                        if (response && response.success) {
                            resolve(resolve(ac.Utils.Common.buildResolve(response.returnValue)));
                        } else {
                            reject(ac.Utils.Common.buildReject('saveLog error', response.errors));
                        }
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('saveLog error', err));
            }
        }),

        /**
         * Executes an arbitrary SOQL statement and returns the results
         *
         * @static
         * @async
         *
         * @param {String} soql
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        queryAsync : (soql) => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.query(soql, {
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('query error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('query error', err));
            }
        }),

        /**
         *
         * @static
         *
         * @param soql
         *
         * @returns {*}
         * @throws Error
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples.htm
         */
        querySync : (soql) => {
            try {
                return sforce.connection && sforce.connection.query(soql);
            }
            catch (err) {
                throw err;
            }
        },

        /**
         *
         * @satic
         * @async
         *
         * @param queryLocator
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        queryMoreAsync : (queryLocator) => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.queryMore(queryLocator, {
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('queryMore error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('queryMore error', err));
            }
        }),

        /**
         *
         * @static
         *
         * @param queryLocator
         *
         * @returns {*}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples.htm
         */
        queryMoreSync : (queryLocator) => {
            try {
                return sforce.connection && sforce.connection.queryMore(queryLocator);
            }
            catch (err) {
                throw err;
            }
        },

        /**
         *
         * @static
         * @async
         *
         * @param soql
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        queryAllAsync : (soql) => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.queryAll(soql, {
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('queryAll error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('queryAll error', err));
            }
        }),

        /**
         *
         * @param soql
         *
         * @returns {*}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples.htm
         */
        queryAllSync : (soql) => {
            try {
                return sforce.connection && sforce.connection.queryAll(soql);
            }
            catch (err) {
                throw err;
            }
        },


        /**
         *
         * @static
         * @async
         *
         * @param fields
         * @param type
         * @param ids
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        retrieveAsync : (fields, type, ids) => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.retrieve(fields, type, ids, {
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('retrieve error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('retrieve error', err));
            }
        }),

        /**
         *
         * @static
         *
         * @param fields
         * @param type
         * @param ids
         *
         * @returns {*}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples.htm
         */
        retrieveSync :(fields, type, ids) => {
            try {
                return sforce.connection && sforce.connection.retrieve(fields, type, ids);
            }
            catch (err) {
                throw err;
            }
        },


        /**
         *
         * @static
         * @async
         *
         * @param searchString
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        searchAsync : (searchString) => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.search(searchString, {
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('search error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('search error', err));
            }
        }),

        /**
         *
         * @static
         *
         * @param searchString
         *
         * @returns {*}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples.htm
         */
        searchSync :(searchString) => {
            try {
                return sforce.connection && sforce.connection.search(searchString);
            }
            catch (err) {
                throw err;
            }
        },

        /**
         *
         * @static
         * @async
         *
         * @param sobjects
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        updateAsync : (sobjects) => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.update(sobjects, {
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('update error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('update error', err));
            }
        }),

        /**
         *
         * @static
         *
         * @param sobjects
         *
         * @returns {*}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples.htm
         */
        updateSync : (sobjects) => {
            try {
                return sforce.connection && sforce.connection.update(sobjects);
            }
            catch (err) {
                throw err;
            }
        },

        /**
         *
         * @static
         * @async
         *
         * @param externalIdFieldName
         * @param sobjects
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        upsertAsync : (externalIdFieldName, sobjects) => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.update(externalIdFieldName, sobjects, {
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('upsert error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('upsert error', err));
            }
        }),

        /**
         *
         * @static
         *
         * @param externalIdFieldName
         * @param sobjects
         *
         * @returns {*}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples.htm
         */
        upsertSync : (externalIdFieldName, sobjects) => {
            try {
                return sforce.connection && sforce.connection.update(externalIdFieldName, sobjects);
            }
            catch (err) {
                throw err;
            }
        },

        /**
         *
         * @static
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.ajax.meta/ajax/sforce_api_ajax_more_samples_asynch.htm
         */
        getUserInfo : () => new Promise((resolve, reject) => {
            try {
                sforce.connection && sforce.connection.getUserInfo({
                    onSuccess: (result) => {
                        resolve(resolve(ac.Utils.Common.buildResolve(result)));
                    },
                    onFailure: (err) => {
                        reject(ac.Utils.Common.buildReject('getUserInfo error', err));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getUserInfo error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @param {String} workId
         * @param {String} disposition
         * @param {String} taskId
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_hvs_lex.htm
         */
        completeHvsWorkWithTaskSaved : (workId, disposition, taskId) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.hvs && sforce.opencti.hvs.completeWork({
                    workId: workId,
                    attributes: {
                        disposition: disposition,
                        taskId: taskId
                    },
                    callback: () => {
                        resolve();
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('completeHvsWorkWithTaskSaved error', err));
            }

        }),

        /**
         *
         * @static
         * @async
         *
         * @param {String} workId
         * @param {Boolean} wasConnected
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_cti.meta/api_cti/sforce_api_cti_hvs_lex.htm
         */
        completeHvsWorkWithCallEnd : (workId, wasConnected) => new Promise((resolve, reject) => {
            try {
                sforce.opencti && sforce.opencti.hvs && sforce.opencti.hvs.completeWork({
                    workId: workId,
                    attributes: {
                        wasConnected: wasConnected
                    },
                    callback: () => {
                        resolve();
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('completeHvsWorkWithCallEnd error', err));
            }
        }),

        /**
         * Sets the softphone panel popout capability
         *
         * @static
         * @async
         *
         * @param {Boolean} enabled - true = popout enabled, false = popout disabled
         *
         * @returns {Promise<Object|Error>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_setcustomconsolecomponentpopoutable.htm
         */
        setSoftphonePopoutEnabled : (enabled) => new Promise((resolve, reject) => {
            try {
                sforce.console && sforce.console.setCustomConsoleComponentPopoutable(enabled, (result) => {
                    if (result.success) {
                        resolve(ac.Utils.Common.buildResolve(result));
                    } else {
                        reject(ac.Utils.Common.buildReject('setSoftphonePopoutEnabled error', result.errors));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('setSoftphonePopoutEnabled error', err));
            }
        }),

        /**
         * Gets the collection of top level (primary) tab ids displayed in the Salesforce UI
         *
         * @static
         * @async
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_getprimarytabids.htm
         */
        getPrimaryTabIds : () => new Promise((resolve, reject) => {
            try {
                sforce.console && sforce.console.getPrimaryTabIds(function (result) {
                    if (result && result.ids) {
                        resolve(ac.Utils.Common.buildResolve(result.ids));
                    } else {
                        reject(ac.Utils.Common.buildReject('getPrimaryTabIds error', result.errors));
                    }
                });
            } catch (err) {
                reject(ac.Utils.Common.buildReject('getPrimaryTabIds error', err));
            }
        }),

        /**
         * Gets the object id being displayed on the given tabId
         *
         * @static
         * @async
         *
         * @param {String} tabId - The tab id
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_getpageinfo.htm
         */
        getObjectOnTab : (tabId) => new Promise((resolve, reject) => {
            sforce.console && sforce.console.getPageInfo(tabId, function (result) {
                if (result && result.success) {
                    let obj = {
                        'objectId': JSON.parse(result.pageInfo).objectId,
                        'tabId': tabId
                    };

                    resolve(obj);
                } else {
                    reject(null);
                }
            });
        }),

        /**
         * Gets a map of all visibble primary tabs and their associated objects (if available)
         *
         * @returns {Promise<unknown>}
         *
         * @see https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_getprimarytabids.htm
         */
        getTabObjectMap : () => new Promise((resolve, reject) => {
            let tabObjectMap = {};

            ac.Utils.Salesforce.getPrimaryTabIds().then(function (tabArray) {
                let promises = [];

                tabArray.forEach(function (tabId) {
                    promises.push(ac.Utils.Salesforce.getObjectOnTab(tabId));
                });

                Promise.all(promises).then(function (values) {
                    values.forEach(function (value) {
                        if (value.objectId) {
                            tabObjectMap[value.objectId] = value.tabId;
                        }
                    });
                    resolve(tabObjectMap);
                }).catch(function (error) {
                    resolve(tabObjectMap);
                });
            });
        }),

        /**
         * Gets the do not call value for the provided object (Contact) id
         *
         * @param {String} id - The object id
         * @param {Boolean} defaultValue - The default value if the object id is not found or does not support do not call
         *
         * @returns {boolean}
         */
        isDoNotCall : (id, type, defaultValue) => {
            let isDoNotCall = false;

            try {
                let result = ac.Utils.Salesforce.querySync(`SELECT DoNotCall FROM ${type} WHERE Id = '${id}' LIMIT 1`);

                let records = result.getArray('records');

                if (records && records.length === 1) {
                    isDoNotCall = records[0].DoNotCall === 'true';
                }
                else {
                    isDoNotCall = defaultValue;
                }
            }
            catch (err) {
                ac.Utils.Log.error(err);
            }

            return isDoNotCall;
        }
    }

    /**
     * @private
     *
     * @static
     * @async
     *
     * @returns {Promise|Error}
     */
    const _isSoftphonePanelVisible = () => new Promise((resolve, reject) => {
        try {
            sforce.opencti && sforce.opencti.isSoftphonePanelVisible({
                callback: (response) => {
                    if (response && response.success) {
                        resolve(resolve(ac.Utils.Common.buildResolve(response.returnValue.visible)));
                    } else {
                        reject(ac.Utils.Common.buildReject('_isSoftphonePanelVisible error', response.errors));
                    }
                }
            });
        }
        catch (err) {
            reject(ac.Utils.Common.buildReject('_isSoftphonePanelVisible error', err));
        }
    });

    /**
     * @private
     *
     * @static
     * @async
     *
     * @param visible
     *
     * @returns {Promise|Error}
     */
    const _setSoftphonePanelVisibility = (visible) => new Promise((resolve, reject) => {
        try {
            sforce.opencti && sforce.opencti.setSoftphonePanelVisibility({
                visible: visible,
                callback: (response) => {
                    if (response && response.success) {
                        resolve(response.returnValue);
                    } else {
                        reject(ac.Utils.Common.buildReject('_setSoftphonePanelVisibility error', response.errors));
                    }
                }
            });
        }
        catch (err) {
            reject(ac.Utils.Common.buildReject('_setSoftphonePanelVisibility error', err));
        }
    });

    /**
     * @private
     *
     * @returns {String}
     */
    const _getNamespacePagePrefix = () => {
        return _props['namespacePagePrefix'];
    };

    /**
     * @private

     * @returns {String}
     */
    const _getNamespaceClassPrefix = () => {
        return _props['namespaceClassPrefix'];
    };

    /**
     * @private
     *
     * @returns {String}
     */
    const _getUserId = () => {
        return _props['userId'];
    };

    /**
     * @private
     *
     * @returns {String}
     */
    const _getUserName = () => {
        return _props['userName'];
    };

    /**
     * @private
     *
     * @returns {String}
     */
    const _getUserEmail = () => {
        return _props['userEmail'];
    };

    /**
     * @private
     *
     * @returns {String}
     */
    const _getSessionId = () => {
        return _props['sessionId'];
    };
})(this);