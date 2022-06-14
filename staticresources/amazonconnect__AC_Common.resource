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
     * @private
     *
     * @type {Map}
     */
    let _props = {};

    const DOM_ELEMENTS = {
        BOTTOM_PANEL: '#bottomPanel'
    };

    /**
     * @class ac.Utils.Common
     * @memberOf ac.Utils
     *
     * @description
     * The ac.Utils.Common class provides helper methods for general scripting.
      */
    ac.Utils.Common = {
        /**
         * Initializes the ac.Utils.Commons utility
         *
         * @private
         *
         * @param {Map} props
         */
        init: (props) => {
            _props = props;
        },

        /**
         *
         * @private
         *
         * @static
         *
         * @param results
         *
         * @returns {Object}
         */
        buildResolve : (results) => {
            return results;
        },

        /**
         *
         * @private
         *
         * @static
         *
         * @param message
         * @param error
         *
         * @returns {{message: *, error: *}}
         */
        buildReject : (message, error) => {
            return {
                message: message,
                error: error
            };
        },

        /**
         *
         * @private
         *
         * @static
         *
         * @param message
         *
         * @returns {Error}
         */
        buildError : (message) => {
            return new Error(message);
        },

        /**
         * Provides a delay in further processing
         *
         * @memberOf ac.Utils.Common
         *
         * @static
         * @async
         *
         * @param {Number} ms - The number of milliseconds to delay
         */
        delay: (ms) => {
            return new Promise(resolve => setTimeout(resolve, ms));
        },

        /**
         * Updates or adds a key:value to the list of stored properties.
         *
         * @memberOf ac.Utils.Common
         * @static
         *
         * @param {String} key - The map entry key (name)
         * @param {String|Number|Object} value - The map entry value
         *
         * @see getProperty
         * @see getAllProperties
         */
        setProperty: (key, value) => {
            _props[key] = value;
        },

        /**
         * Returns the value of a provided key or default value if the key is not found.
         *
         * @static
         *
         * @param {String} key - The map entry key (name)
         * @param {Object} defaultValue - The default value to return if the key is not found
         *
         * @returns {String|Number|Object}
         *
         * @see setProperty
         * @see getAllProperties
         *
         * @example
         * let testProperty = ac.Utils.Common.getProperty('testName');
         *
         * @example
         * let testProperty = ac.Utils.Common.getProperty('testName', 'This is the default value');
         */
        getProperty: (key, defaultValue) => {
            return _props[key] || defaultValue;
        },

        /**
         * Gets all stored properties.
         *
         * @static
         *
         * @returns {Map}
         *
         * @see getProperty
         * @see setProperty
         *
         * @example
         * let propMap = ac.Utils.Common.getAllProperties();
         */
        getAllProperties: () => {
            return _props;
        },

        /**
         * Hides the bottom panel
         *
         * @static
         *
         * @example
         * ac.Utils.Common.hideBottomPanel();
         */
        hideBottomPanel : () => {
            _setBottomPanelVisible(false);
        },

        /**
         * Shows the bottom panel
         *
         * @static
         *
         * @example
         * ac.Utils.Common.showBottomPanel();
         */
        showBottomPanel : () => {
            _setBottomPanelVisible(true);
        },

        /**
         * Formats a provided phone number and country code in E.164 format.
         *
         * @static
         *
         * @param {String} phoneNumber - The phone number to format
         * @param {String} countryCode - The country code to which to format the phone number
         *
         * @returns {String}
         *
         * @example
         * let e164 = ac.Utils.Common.formatPhoneNUmberE164('8885551212', 'US');
         */
        formatPhoneNumberE164 : (phoneNumber, countryCode) => {
            if (libphonenumber.isSupportedCountry(countryCode)) {
                return libphonenumber.formatNumber(libphonenumber.parse(phoneNumber, countryCode), 'E.164');
            }

            return libphonenumber.formatNumber(libphonenumber.parse(phoneNumber, ac.Utils.Common.getProperty('defaultCountryCode', 'US')), 'E.164');
        },

        /**
         * Formats a provided phone number in the specified country format.
         *
         * @satic
         *
         * @param {String} phoneNumber - The phone number to format
         * @param {String} countryCode - The country code to which to format the phone number
         *
         * @returns {String}
         */
        formatPhoneNumber : (phoneNumber, countryCode) => {
            if (libphonenumber.isSupportedCountry(countryCode)) {
                return libphonenumber.parse(phoneNumber, countryCode).phone;
            }
        },

        /**
         * Capitalize a provided string
         *
         * @param {String} s - The string to capitalize
         *
         * @returns {string}
         *
         * @example
         * let capFirstName = ac.Utils.Common.capitalize('joe');
         * let capLastName = ac.Utils.Common.capitalize('smith');
         */
        capitalize  : (s) => {
            if (typeof s !== 'string') {
                return ''
            }

            return s.charAt(0).toUpperCase() + s.slice(1)
        },

        /**
         *
         * @private
         *
         * @param agent
         */
        connectAgentOnInit: (agent) => {
            if (ac.Utils.Salesforce.shouldEnableClickToDial()) {
                ac.Utils.Salesforce.enableClickToDial();
            } else {
                ac.Utils.Salesforce.disableClickToDial();
            }
        },

        /**
         *
         * @private
         *
         * @param agentStateChange
         */
        connectAgentOnStateChange: (agentStateChange) => {
            let ctiAdapter = ac.Utils.Common.getProperty('ctiAdapter');

            if (ac.Utils.Salesforce.getValueWithNamespace(ctiAdapter, 'PresenceSyncEnabled__c')) {
                ac.Utils.PresenceSync.handleEvent({
                    source: 'connectAgentStateChange',
                    body: agentStateChange
                });
            }
        },

        /**
         *
         * @private
         *
         * @param agent
         */
        connectAgentOnRefresh: (agent) => {
        },

        /**
         *
         * @private
         *
         * @param agent
         */
        connectAgentOnRoutable: (agent) => {
            ac.Utils.CtiAttributes.hideAttributesIndicator();
            ac.Utils.CtiAttributes.hideLinksIndicator();
            ac.Utils.CtiAttributes.depopulate();
        },

        /**
         *
         * @private
         *
         * @param agent
         */
        connectAgentOnNotRoutable: (agent) => {
        },

        /**
         *
         * @private
         *
         * @param agent
         */
        connectAgentOnOffline: (agent) => {
        },

        /**
         *
         * @private
         *
         * @param agent
         */
        connectAgentOnAfterCallWork: (agent) => {
        },

        /**
         *
         * @private
         *
         * @param agent
         */
        connectAgentOnError: (agent) => {
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectVoiceContactOnInit: (contact) => {
            _contactOnInit(contact);
            _createContactChannel(contact);
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectVoiceContactOnIncoming: (contact) => {
            ac.Utils.Salesforce.showSoftphonePanel();
            ac.Utils.CtiAttributes.populate(contact);
        },

        /**
         *
         * @private
         *
         * @param contacte
         */
        connectVoiceContactOnConnecting: (contact) => {
            ac.Utils.Salesforce.showSoftphonePanel();
            ac.Utils.CtiAttributes.populate(contact);
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectVoiceContactOnAccepted: (contact) => {
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectVoiceContactOnConnected: (contact) => {
              if (contact.isInbound()) {
                ac.Utils.CtiAttributes.showAttributesIndicator();
                ac.Utils.CtiAttributes.showLinksIndicator();
            }
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectVoiceContactOnEnded: (contact) => {
            _contactOnEnded(contact);
            _updateContactChannel(contact);
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectVoiceContactOnMissed: (contact) => {
            _contactOnMissed(contact);
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectChatContactOnInit: (contact) => {
            _contactOnInit(contact);
            _createContactChannel(contact);
        },

        /**
         * @private
         *
         * @param contact
         */
        connectChatContactOnIncoming : (contact) => {
            ac.Utils.Salesforce.showSoftphonePanel();
            ac.Utils.CtiAttributes.populate(contact);
        },

        /**
         *
         * @private
         *
         * @param contact
         * @private
         */
        connectChatContactOnConnecting: (contact) => {
            ac.Utils.Salesforce.showSoftphonePanel();
            ac.Utils.CtiAttributes.populate(contact);
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectChatContactOnAccepted: (contact) => {
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectChatContactOnConnected: (contact) => {
            if (contact.isInbound()) {
                ac.Utils.CtiAttributes.showAttributesIndicator();
                ac.Utils.CtiAttributes.showLinksIndicator();
            }
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectChatContactOnEnded: (contact) => {
            _contactOnEnded(contact);
            _updateContactChannel(contact);

            ac.Utils.CtiAttributes.hideAttributesIndicator();
            ac.Utils.CtiAttributes.hideLinksIndicator();
            ac.Utils.CtiAttributes.depopulate();
        },

        /**
         *
         * @private
         *
         * @param contact
         */
        connectChatContactOnMissed: (contact) => {
            _contactOnMissed(contact);
        },

        /**
         *
         * @private
         *
         * @param event
         */
        salesforcePresencesStatusChanged: (event) => {
            let ctiAdapter = ac.Utils.Common.getProperty('ctiAdapter');

            if (ac.Utils.Salesforce.getValueWithNamespace(ctiAdapter, 'PresenceSyncEnabled__c')) {
                ac.Utils.PresenceSync.handleEvent({
                    source: 'salesforceAgentStateChange',
                    body: event
                });
            }
        },

        /**
         *
         * @private
         *
         * @param event
         */
        salesforcePresenceLogout : (event) => {
            let ctiAdapter = ac.Utils.Common.getProperty('ctiAdapter');

            if (ac.Utils.Salesforce.getValueWithNamespace(ctiAdapter, 'PresenceSyncEnabled__c')) {
                ac.Utils.PresenceSync.handleEvent({
                    source: 'salesforceAgentLogout',
                    body: event
                });
            }
        },

        /**
         *
         * @private
         *
         * @param event
         */
        salesforcePresenceWorkloadChanged : (event) => {
            let ctiAdapter = ac.Utils.Common.getProperty('ctiAdapter');

            if (ac.Utils.Salesforce.getValueWithNamespace(ctiAdapter, 'PresenceSyncEnabled__c')) {
                ac.Utils.PresenceSync.handleEvent({
                    source: 'salesforceWorkloadChanged',
                    body: event
                });
            }
        },

        /**
         *
         * @private
         *
         * @param event
         */
        salesforcePresenceWorkAccepted : (event) => {
            let ctiAdapter = ac.Utils.Common.getProperty('ctiAdapter');

            if (ac.Utils.Salesforce.getValueWithNamespace(ctiAdapter, 'PresenceSyncEnabled__c')) {
                ac.Utils.PresenceSync.handleEvent({
                    source: 'salesforceWorkAccepted',
                    body: event
                });
            }
        },

        /**
         *
         * @private
         *
         * @param payload
         *
         * @example payload
         * {"number":"(769) 555-7272","recordId":"0033i0000032PdBAAU","recordName":"Mark Kingston","objectType":"Contact"}
         */
        salesforceOnClickToDial : (payload) => {
        },

        /**
         *
         * @private
         *
         * @param payload
         */
        salesforceNavigationChange : (payload) => {
        },

        /**
         *
         * @private
         *
         * @param payload
         */
        salesforceHvsWorkStart : (payload) => {
        }
    };

    /**
     *
     * @private
     *
     * @param contact
     */
    const _contactOnInit = (contact) => {
        ac.Utils.Common.setProperty('contactMissed', false);

        let now = new Date();
        ac.Utils.Common.setProperty('contactStartDate', now);
        ac.Utils.Common.setProperty('contactStartTime', now.getTime());
        ac.Utils.Common.setProperty('contactStartDateTime', now.toISOString());
    };

    /**
     *
     * @private
     *
     * @param contact
     */
    const _contactOnEnded = (contact) => {
        let now = new Date();
        ac.Utils.Common.setProperty('contactEndDate', now);
        ac.Utils.Common.setProperty('contactEndTime', now.getTime());
        ac.Utils.Common.setProperty('contactEndDateTime', now.toISOString());

        let contactStartTime = ac.Utils.Common.getProperty('contactStartTime', 0);
        let contactEndTime = ac.Utils.Common.getProperty('contactEndTime', 0);

        ac.Utils.Common.setProperty('contactInteractionDuration', Math.floor((contactEndTime - contactStartTime) / 1000));
    };

    /**
     *
     * @private
     *
     * @param contact
     */
    const _contactOnMissed = (contact) => {
        ac.Utils.Common.setProperty('contactMissed', true);
    };

    /**
     *
     * @private
     *
     * @param contact
     *
     * @returns {Promise<unknown>}
     */
    const _createContactChannel = async (contact) => {
        try {
            let agent = ac.Utils.Agent.getAgent();

            let customerConnection = ac.Utils.Contact.getCustomerConnection(contact);

            let phoneNumber = customerConnection.getEndpoint().phoneNumber;
            let containsAtSymbol = phoneNumber.indexOf('@') > -1;
            let customerPhoneNumber = phoneNumber.substring(0, containsAtSymbol ? phoneNumber.indexOf('@') : phoneNumber.length).replace('sip:', '');

            let contactType = ac.Utils.Contact.getContactType(contact);

            let contactStatus = ac.Utils.Contact.getContactStatus(contact);

            let namespace = ac.Utils.Salesforce.getNamespacePagePrefix();

            let contactChannel = {};

            contactChannel[namespace + 'AgentName__c'] = agent.getName();
            contactChannel[namespace + 'AgentLoginUsername__c'] = agent.getConfiguration().username;
            contactChannel[namespace + 'CustomerNumber__c'] = customerPhoneNumber;
            contactChannel[namespace + 'ContactId__c'] = contact.getContactId();
            contactChannel[namespace + 'QueueName__c'] = contact.getQueue().name || '';
            contactChannel[namespace + 'InitiationMethod__c'] = contactType;
            contactChannel[namespace + 'CallStatus__c'] = contactStatus;
            contactChannel[namespace + 'Attributes__c'] = ac.Utils.Contact.getAttributesAsString(contact);

            let result = await ac.Utils.Salesforce.saveLog(namespace + 'AC_ContactChannels__c', null, contactChannel);

            if (result) {
                ac.Utils.Common.setProperty('contactChannelId', result.recordId);
            }

            return result;
        }
        catch (err) {
            throw err;
        }
    };

    /**
     *
     * @private
     *
     * @param visible
     */
    const _setBottomPanelVisible = (visible) => {
        if (visible) {
            $(DOM_ELEMENTS.BOTTOM_PANEL).removeClass('slds-hide');
        }
        else {
            $(DOM_ELEMENTS.BOTTOM_PANEL).addClass('slds-hide');
        }
    };

    /**
     *
     * @private
     *
     * @param contact
     *
     * @returns {Promise<unknown>}
     */
    const _updateContactChannel = async (contact) => {
        try {
            let contactChannelId = ac.Utils.Common.getProperty('contactChannelId', null);

            if (contactChannelId) {
                let contactStartDateTime = ac.Utils.Common.getProperty('contactStartDateTime');

                let contactEndDateTime = ac.Utils.Common.getProperty('contactEndDateTime');

                let contactInteractionDuration = ac.Utils.Common.getProperty('contactInteractionDuration');

                let contactStatus = ac.Utils.Common.getProperty('contactMissed', false) ? 'Missed' : 'Completed';

                let namespace = ac.Utils.Salesforce.getNamespacePagePrefix();

                let contactChannel = {};

                contactChannel['Id'] =contactChannelId
                contactChannel[namespace + 'CallStartTimestamp__c'] = contactStartDateTime;
                contactChannel[namespace + 'CallEndTimestamp__c'] = contactEndDateTime;
                contactChannel[namespace + 'CallStatus__c'] = contactStatus;
                contactChannel[namespace + 'InteractionDuration__c'] = contactInteractionDuration;

                let result = await ac.Utils.Salesforce.saveLog(namespace + 'AC_ContactChannels__c', contactChannelId, contactChannel);

                ac.Utils.Common.setProperty('contactChannelId', null);

                return result;
            }
        }
        catch (err) {
            throw err;
        }
    };
})(this);