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
     * @private
     *
     * @type {Map}
     */
    let _props = {};

    /**
     *
     * @private
     *
     * @type {boolean}
     */
    let _presenceSyncEnabled = false;
    /**
     *
     * @private
     *
     * @type {Array}
     */
    let _presenceSyncRules = [];

    /**
     *
     * @private
     *
     * @type {Array}
     */
    let _connectStates = [];

    /**
     *
     * @private
     *
     * @type {Array}
     */
    let _salesforceStates = [];

    /**
     *
     * @type {{}}
     * @private
     */
    let _context = {};

    /**
     * Milliseconds elapsed since last event to allow events to process
     *
     * @private
     *
     * @type {number}
     */
    const _throttleTime = 250;

    /**
     *
     * @type {{salesforceWorkloadChanged: string, salesforceAgentStateChange: string, connectAgentStateChange: string, salesforceWorkAccepted: string}}
     */
    const PRESENCE_SYNC_SOURCE = {
        connectAgentStateChange: 'connectAgentStateChange',
        salesforceAgentStateChange: 'salesforceAgentStateChange',
        salesforceWorkAccepted: 'salesforceWorkAccepted',
        salesforceWorkloadChanged: 'salesforceWorkloadChanged'
    };

    /**
     *
     * @type {{connectAgentState: string, salesforceAgentState: string}}
     */
    const PRESENCE_SYNC_DESTINATION = {
        connectAgentState: 'connectAgentState',
        salesforceAgentState: 'salesforceAgentState'
    };

    /**
     *
     * @type {{connectAgentNewState: string, salesforceNewWorkloadPct: string, staticValue: string, salesforceConfiguredCapacity: string, salesforceServiceChannel: string, salesforceNewWorkload: string, connectAgentOldState: string, salesforceAgentOldState: string, salesforcePreviousWorkload: string, salesforcePreviousWorkloadPct: string, salesforceAgentNewState: string}}
     */
    const PRESENCE_SYNC_OPERAND = {
        connectAgentOldState: 'connectAgentOldState',
        connectAgentNewState: 'connectAgentNewState',
        salesforceAgentOldState: 'salesforceAgentNewState',
        salesforceAgentNewState: 'salesforceAgentNewState',
        salesforceServiceChannel: 'salesforceServiceChannel',
        salesforcePreviousWorkload: 'salesforcePreviousWorkload',
        salesforcePreviousWorkloadPct: 'salesforcePreviousWorkloadPct',
        salesforceNewWorkload: 'salesforceNewWorkload',
        salesforceNewWorkloadPct: 'salesforceNewWorkloadPct',
        salesforceConfiguredCapacity: 'salesforceConfiguredCapacity',
        staticValue: 'staticValue'
    };

    /**
     *
     * @type {Array}
     */
    const LOCKED_STATES = [
        'Busy',
        'Pending',
        'PendingBusy',
        'CallingCustomer',
        'BusyPhone'
    ];

    /**
     * @private
     *
     * @class ac.Utils.PresenceSync
     * @memberOf ac.Utils
     *
     * @namespace ac.Utils.PresenceSync
     */
    ac.Utils.PresenceSync = {
        /**
         * Initializes the ac.Utils.PresenceSync utility
         *
         * @private
         *
         * @static
         * @async
         *
         * @param {Object} props
         * @param {Array} presenceSyncRules
         */
        init : async (props, presenceSyncEnabled, presenceSyncRules) => {
            _props = props;
            _presenceSyncEnabled = presenceSyncEnabled;
            _presenceSyncRules = presenceSyncRules;

            _context.connect = {
                oldState: '',
                newState: ''
            };

            _context.salesforce = {
                oldState: '',
                newState: ''
            };

            if (_presenceSyncEnabled) {
                await ac.Utils.PresenceSync.loadAvailableStates();
            }
            else {
                ac.Utils.Log.warn('Presence sync is not enabled!!!');
            }
        },

        /**
         *
         * @private
         *
         * @static
         * @async
         *
         * @param event
         */
        handleEvent : async (event) => {
            if (_presenceSyncEnabled) {
                await _updateContext(event);

                let rules = _filterRules(event.source);

                if (rules && rules.length > 0) {
                    _processRules(rules);
                } else {
                    ac.Utils.Log.info('No rules configured for event [' + JSON.stringify(event) + ']');
                }
            }
        },

        loadAvailableStates : async () => {
            try {
                _connectStates = await ac.Utils.Agent.getAvailableAgentStates();
                _salesforceStates = await ac.Utils.Salesforce.getAvailableAgentStates();
            }
            catch (err) {
                _presenceSyncEnabled = false;
                ac.Utils.Log.error('Failure in AC_PresenceSyncUtils.init(): ' + JSON.stringify(err));
                ac.Utils.Log.warn('Presence sync is being disabled!!!');
            }
        }
    };

    /**
     *
     * @private
     *
     * @static
     * @async
     *
     * @param event
     */
     const _updateContext = async (event) => {
        try {
            switch (event.source) {
                case PRESENCE_SYNC_SOURCE.connectAgentStateChange:
                    _context.connect.oldState = event.body.oldState;
                    _context.connect.newState = event.body.newState;
                    break;
                case PRESENCE_SYNC_SOURCE.salesforceAgentStateChange:
                    _context.salesforce.newState = event.body.statusApiName;
                    break;
                case PRESENCE_SYNC_SOURCE.salesforceWorkAccepted:
                    let serviceChannel = await _getServiceChannelForWork(event.body.workId);
                    _context.salesforce.serviceChannel = serviceChannel;
                    break;
                case PRESENCE_SYNC_SOURCE.salesforceWorkloadChanged:
                    _context.salesforce.configuredCapacity = parseInt(event.body.configuredCapacity);
                    _context.salesforce.previousWorkload = parseInt(event.body.previousWorkload);
                    _context.salesforce.newWorkload = parseInt(event.body.newWorkload);
                    _context.salesforce.previousWorkloadPct = parseInt(event.body.configuredCapacity) === 0 ? 1 :
                        parseInt(event.body.previousWorkload) / parseInt(event.body.configuredCapacity);
                    _context.salesforce.newWorkloadPct = parseInt(event.body.configuredCapacity) === 0 ? 1 :
                        parseInt(event.body.newWorkload) / parseInt(event.body.configuredCapacity);
                    break;
                default:
                    break;
            }

        }
        catch (err) {
        }
    };

    /**
     *
     * @private
     *
     * @static
     *
     * @param source
     * @returns {Object}
     */
    const _filterRules = (source) => {
        if (_presenceSyncRules && _presenceSyncRules.length > 0) {
            return _presenceSyncRules.filter(function (rule) {
                return ac.Utils.Salesforce.getValueWithNamespace(rule, 'Source__c') === source;
            });
        }
        else {
            return [];
        }
    };

    /**
     *
     * @private
     *
     * @static
     *
     * @param rules
     */
    const _processRules = (rules) => {
        rules.forEach((rule) => {
            _processRule(rule);
        })
    };

    /**
     *
     * @private
     *
     * @static
     *
     * @param rule
     */
    const _processRule = (rule) => {
        let operandA = ac.Utils.Salesforce.getValueWithNamespace(rule, 'OperandA__c');
        let operandAValue;

        if (operandA === PRESENCE_SYNC_OPERAND.staticValue) {
            operandAValue = ac.Utils.Salesforce.getValueWithNamespace(rule, 'OperandACustom__c');
        }
        else {
            operandAValue = _expandOperand(operandA);
        }

        let operandB = ac.Utils.Salesforce.getValueWithNamespace(rule, 'OperandB__c');
        let operandBValue;

        if (operandB === PRESENCE_SYNC_OPERAND.staticValue) {
            operandBValue = ac.Utils.Salesforce.getValueWithNamespace(rule, 'OperandBCustom__c');
        }
        else {
            operandBValue = _expandOperand(operandB);
        }

        let comparator = ac.Utils.Salesforce.getValueWithNamespace(rule, 'Comparator__c');

        let comparison = _processComparison(operandAValue, comparator, operandBValue);

        if (comparison) {
            let targetAgentState;
            if (ac.Utils.Salesforce.getValueWithNamespace(rule, 'Destination__c') === PRESENCE_SYNC_DESTINATION.connectAgentState) {
                targetAgentState = _connectStates[ac.Utils.Salesforce.getValueWithNamespace(rule, 'Value__c')];


                _debouncedSetConnectAgentState(targetAgentState);
            }
            else {
                targetAgentState = _salesforceStates[ac.Utils.Salesforce.getValueWithNamespace(rule, 'Value__c')];
                _debouncedSetSalesforceAgentState(targetAgentState);
            }
        }
    };

    /**
     *
     * @private
     *
     * @static
     *
     * @param operand
     *
     * @returns {string|number}
     */
    const _expandOperand = (operand) => {
        let value;

        switch (operand) {
            case PRESENCE_SYNC_OPERAND.connectAgentOldState:
                value = _context.connect.oldState;
                break;
            case PRESENCE_SYNC_OPERAND.connectAgentNewState:
                value = _context.connect.newState;
                break;
            case PRESENCE_SYNC_OPERAND.salesforceAgentNewState:
                value = _context.salesforce.newState;
                break;
            case PRESENCE_SYNC_OPERAND.salesforcePreviousWorkload:
                value = _context.salesforce.previousWorkload;
                break;
            case PRESENCE_SYNC_OPERAND.salesforcePreviousWorkloadPct:
                value = _context.omni.previousWorkloadPct;
                break;
            case PRESENCE_SYNC_OPERAND.salesforceNewWorkload:
                value = _context.omni.newWorkload;
                break;
            case PRESENCE_SYNC_OPERAND.salesforceNewWorkloadPct:
                value = _context.omni.newWorkloadPct;
                break;
            case PRESENCE_SYNC_OPERAND.salesforceConfiguredCapacity:
                value = _context.omni.configuredCapacity;
                break;
            default: // Literal value without expansion
                value = operand;
        }

        return value;
    };

    /**
     *
     * @private
     *
     * @static
     *
     * @param operandA
     * @param comparator
     * @param operandB
     *
     * @returns {boolean}
     */
    const _processComparison = (operandA, comparator, operandB) => {
        let result = false;

        try {
            comparator = comparator.replace('&lt;', '<').replace('&gt;', '>');

            switch (comparator) {
                case '===':
                    result = operandA === operandB;
                    break;
                case '!==':
                    result = operandA !== operandB;
                    break;
                case '>':
                    result = operandA > operandB;
                    break;
                case '>=':
                    result = operandA >= operandB;
                    break;
                case '<':
                    result = operandA < operandB;
                    break;
                case '<=':
                    result = operandA <= operandB;
                    break;
                default:
                    result = false;
            }
        }
        catch (err) {
            ac.Utils.Log.error(err);
        }

        return result;
    };

    /**
     *
     * @private
     *
     * @static
     *
     * @param destination
     * @param oldState
     * @param newState
     *
     * @returns {boolean}
     */
    const _canProcessStateChange = (destination, oldState, newState) => {
        let canProcessStateChange = false;

        try {
            if (destination === PRESENCE_SYNC_DESTINATION.connectAgentState) {
                if (oldState === newState) {
                    canProcessStateChange = false;
                } else if ($.inArray(oldState, LOCKED_STATES) || $.inArray(newState, LOCKED_STATES)) {
                    canProcessStateChange = false;
                }
            } else if (destination === PRESENCE_SYNC_DESTINATION.salesforceAgentState) {
                if (oldState === newState) {
                    canProcessStateChange = false;
                }
            }
        }
        catch (err) {
            ac.Utils.Log.error(err);
            canProcessStateChange = false;
        }

        return canProcessStateChange;
    };

    /**
     *
     * @private
     *
     * @static
     * @async
     *
     * @param workId
     *
     * @returns {Promise}
     */
    const _getServiceChannelForWork = (workId) => new Promise((resolve, reject) => {
        try {
            Visualforce.remoting.Manager.invokeAction(
                ac.Utils.Salesforce.getNamespaceClassPrefix() + 'AC_Utils.getWorkHolder',
                workId,
                function (result, event) {
                    if (event.status && result) {
                        resolve(result.serviceChannel);
                    } else {
                        reject('_getServiceChannelForWork error');
                    }
                }
            );
        }
        catch (err) {
            reject(err)
        }
    });

    /**
     *
     * @private
     *
     * @static
     * @async
     *
     * @param state
     *
     * @returns {Promise}
     */
    const _setConnectAgentState = async (state) => {
        try {
            let currentState = await ac.Utils.Agent.getAgentState();

            if (currentState.name !== state.name) {
                ac.Utils.Log.info('Setting connect agent state [' + JSON.stringify(state) + ']');
                await ac.Utils.Agent.setAgentState(state);
            }
        }
        catch (err) {
            ac.Utils.Log.error('_setConnectAgentState error');
        }
    };

    /**
     *
     * @private
     *
     * @static
     *
     * @type {debounced}
     */
    const _debouncedSetConnectAgentState = _.debounce(_setConnectAgentState, _throttleTime);

    /**
     *
     * @private
     *
     * @static
     * @async
     *
     * @param state
     *
     * @returns {Promise<void>}
     */
    const _setSalesforceAgentState = async (state) => {
        try {
            let currentState = await ac.Utils.Salesforce.getAgentState();

            if (currentState.statusId !== state) {
                ac.Utils.Log.info('Setting salesforce agent state [' + state + ']');
                if (state === 'Offline') {
                    await ac.Utils.Salesforce.logoutAgent();
                } else {
                    await ac.Utils.Salesforce.setAgentState(state);
                }
            }
        }
        catch (err) {
            ac.Utils.Log.error('_setSalesforceAgentState error');
        }
    };

    /**
     *
     * @private
     *
     */
    const _debouncedSetSalesforceAgentState = _.debounce(_setSalesforceAgentState, _throttleTime);
})(this);
