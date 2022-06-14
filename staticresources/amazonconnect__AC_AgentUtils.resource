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
     * @rivate
     *
     * @type {Map}
     */
    let _props = {};

    /**
     * @class ac.Utils.Agent
     * @memberOf ac.Utils
     *
     * @description
     * The ac.Utils.Agent class provides helper methods for Amazon Connect agent scripting.
     *
     * @see https://github.com/aws/amazon-connect-streams/blob/master/Documentation.md#agent-api
     */
    ac.Utils.Agent = {
        /**
         * @private
         * @static
         *
         * @param props
         */
        init : (props) => {
            _props = props;
        },

        /**
         * Gets the list of quick connects available to the current agent
         *
         * @static
         * @async
         *
         * @returns {Promise<Array|Error>}
         *
         * @example
         * let qcList = await ac.Utils.Agent.getQuickConnectList();
         */
        getQuickConnectionList : () => new Promise((resolve, reject) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    resolve(ac.Utils.Common.buildResolve([]));
                }

                agent.getEndpoints(agent.getAllQueueARNs(),
                    {
                        success: data => {
                            let endpoints = data.endpoints || [];

                            let quickConnects = endpoints.filter(item => {
                                return item.type === 'phone_number';
                            });

                            resolve(ac.Utils.common.buildResolve(quickConnects));
                        },
                        failure: _ => {
                            reject(ac.Utils.Common.buildReject('Failed to get quick connection list.', null));
                        }
                    }
                );
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('getQuickConnectionList error', err));
            }
        }),

        /**
         *
         * @static
         * @async
         *
         * @returns {Promise<Array|Error>}
         *
         *  @example
         * let tcList = await ac.Utils.Agent.getTransferConnList();
         */
        getTransferConnList : () => new Promise((resolve, reject) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    resolve(ac.Utils.Common.buildResolve([]));
                }

                agent.getEndpoints(agent.getAllQueueARNs(),
                    {
                        success: data => {
                            let endpoints = data.endpoints || [];
                            resolve(ac.Utils.Common.buildResolve(endpoints));
                        },
                        failure: _ => {
                            reject(ac.Utils.Common.buildReject('Failed to get transfer connection list', null));
                        }
                    }
                );
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('getTransferConnList error', err));
            }
        }),

        /**
         * Generates and returns an endpoint for a provided phone number.
         *
         * @static
         *
         * @param phoneNumber - The phone number for which to generate an endpoint
         *
         * @returns {ConnectEndpoint}
         *
         * @throws {Error}
         *
         * @example
         * let endpoint = ac.Utils.Agent.getEndpointByPhoneNumber('+18885551212');
         */
        getEndpointByPhoneNumber : (phoneNumber = null) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                   throw ac.Utils.Common.buildError('Agent can not be undefined');
                }

                if (!phoneNumber) {
                    throw ac.Utils.Common.buildError('Phone number required');
                }

                phoneNumber = phoneNumber.replace(/\s/g, '');

                let endpoint = connect.Endpoint.byPhoneNumber(phoneNumber);

                return endpoint;
            }
            catch (err) {
                throw ac.Utils.Common.buildError('getEndpointByPhoneNumber error: ' + err.message);
            }
        },

        /**
         * Dials a provided phone number and connects or conferences that endpoint.
         *
         * @static
         * @async
         *
         * @param phoneNumber - The phone number to dial
         *
         * @returns {Promise<Object|Error>}
         *
         * @example
         * ac.Utils.Agent.dialNumber('+18885551212');
         */
        dialNumber : (phoneNumber = null) => new Promise((resolve, reject) => {
            try {

                let agent = _getAgent();

                if (agent.getContacts() && agent.getContacts().length <= 1) {
                    let endpoint = connect.Address.byPhoneNumber(phoneNumber);

                    if (agent.getContacts(connect.ContactType.VOICE).length === 0) {
                        agent.connect(endpoint, {
                            success: (data) => {
                                resolve(ac.Utils.Common.buildResolve(data));
                            },
                            failure: (data) => {
                                reject(ac.Utils.Common.buildReject(data));
                            }
                        });
                    } else {
                        agent.getContacts(connect.ContactType.VOICE)[0].addConnection(endpoint, {
                            success: (data) => {
                                resolve(ac.Utils.Common.buildResolve(data));
                            },
                            failure: (data) => {
                                reject(ac.Utils.Common.buildReject('dialNumber error', data));
                            }
                        });
                    }
                }
                else {
                    ac.Utils.Log.warn('Could not dial number.  Simultaneous contacts exceed.');
                }
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('dialNumber error', err));
            }
        }),

        dialQuickConnect : (name) => new Promise((resolve, reject) => {
            try {
                let agent = _getAgent();

                let quickConnect = ac.Utils.Agent.getQuickConnectionList().filter(qc)

                if (agent.getContacts() && agent.getContacts().length <= 1) {
                    if (agent.getContacts(connect.ContactType.VOICE).length === 0) {
                        agent.connect(endpoint, {
                            success: (data) => {
                                resolve(ac.Utils.Common.buildResolve(data));
                            },
                            failure: (data) => {
                                reject(ac.Utils.Common.buildReject(data));
                            }
                        });
                    } else {
                        agent.getContacts(connect.ContactType.VOICE)[0].addConnection(endpoint, {
                            success: (data) => {
                                resolve(ac.Utils.Common.buildResolve(data));
                            },
                            failure: (data) => {
                                reject(ac.Utils.Common.buildReject('dialNumber error', data));
                            }
                        });
                    }
                }
                else {
                    ac.Utils.Log.warn('Could not dial number.  Simultaneous contacts exceed.');
                }
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('dialNumber error', err));
            }
        }),

        /**
         * Mutes the agent.
         *
         * @static
         *
         * @throws {Error}
         *
         * @example
         * ac.Utils.Agent.mute();
         */
        mute : () => {
            try {
                let agent = _getAgent();

                if (agent) {
                    agent.mute();
                }
            }
            catch (err) {
                throw(err);
            }
        },

        /**
         * Unmutes the agent
         *
         * @static
         *
         * @throws {Error}
         *
         * @example
         * ac.Utils.Agent.unmute();
         */
        unmute : () => {
            try {
                let agent = _getAgent();

                if (agent) {
                    agent.unmute();
                }
            }
            catch (err) {
                throw err;
            }
        },

        /**
         * Returns the current agent state.
         *
         * @static
         *
         * @returns {ConnectAgentState}
         *
         * @throws {Error}
         *
         * @example
         * let currentState = ac.Utils.Agent.getAgentState();
         */
        getAgentState : () => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw ac.Utils.Common.buildError('getAgentState agent cannot be null');
                }

                return agent.getState();
            }
            catch (err) {
                throw ac.Utils.Common.buildError('getAgentState error: ' + err.message);
            }
        },

        /**
         * Sets the agent state.
         *
         * @static
         * @async
         *
         * @param agentState - The requested agent state
         *
         * @returns {Promise<Object|Error>}
         */
        setAgentState : (agentState) => new Promise((resolve, reject) => {
            try {
                let agent = _getAgent();

                agentState && agent && agent.setState(agentState, {
                    success: (data) => {
                        resolve(ac.Utils.Common.buildResolve(data));
                    },
                    failure: (data) => {
                        reject(ac.Utils.Common.buildReject('setAgentState error', data));
                    }
                });
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('setAgentState error', err));
            }
        }),

        /**
         * Sets the agent state to Available.
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @example
         * ac.Utils.Agent.setAgentAvailable();
         */
        setAgentAvailable : () => new Promise( (resolve, reject) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    reject(ac.Utils.Common.buildReject('Agent cannot be undefined', null));
                }
                const agentState = agent.getAgentStates().find(item => item.name === 'Available');
                agent && agent.setState(agentState, {
                    success: async (data) => {
                        await ac.Utils.Agent.setAgentState(agentState);
                        resolve(ac.Utils.Common.buildResolve(data));
                    },
                    failure: (data) => {
                        reject(ac.Utils.Common.buildReject('setAgentAvailable error', data));
                    }
                });
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('setAgentAvailable error', err));
            }
        }),

        /**
         * Gets all of the available agent states including custom states.
         *
         * @static
         * @async
         *
         * @returns {Promise<Array|Error>}
         *
         * @example
         * let availableStates = await ac.Utils.Agent.getAvailableStates();
         */
        getAvailableAgentStates : () => new Promise((resolve, reject) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    reject(ac.Utils.Common.buildReject('Agent cannot be undefined', null));
                }

                let states = agent.getAgentStates().map((state) => {
                    return {
                        key: state.name,
                        value: state
                    };
                });

                resolve(ac.Utils.Common.buildResolve(Object.assign({}, ...states.map(s => ({[s.key]: s.value})))));
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('getAvaialbleAgentStates error', err));
            }
        }),

        /**
         * Gets the agent's user friendly display name for the agent.
         *
         * @static
         *
         * @returns {String}
         *
         * @example
         * let agentName = ac.Utils.Agent.getName();
         */
        getName : () => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw new Error('Agent cannot be undefined');
                }

                return agent.getConfiguration();
            }
            catch (err) {
                throw err;
            }
        },

        /**
         * Gets the agent's phone number from the AgentConfiguration object for the agent. This is the phone number
         * that is dialed by Amazon Connect to connect calls to the agent for incoming and outgoing calls if softphone
         * is not enabled.
         *
         * @static
         *
         * @returns {String}
         *
         * @example
         * let agentExtension = ac.Utils.Agent.getExtension();
         */
        getExtension : () => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw new Error('Agent cannot be undefined');
                }

                return agent.getExtension();
            }
            catch (err) {
                throw err;
            }
        },

        /**
         * Gets the current agent's configuration
         *
         * @static
         *
         * @returns {ConnectAgentConfiguration}
         *
         * @example
         * let agentConfig = ac.Utils.Agent.getConfiguration();
         */
        getConfiguration : () => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw new Error('Agent cannot be undefined');
                }

                return agent.getConfiguration();
            }
            catch (err) {
                throw err;
            }
        },

        /**
         * Sets the current agent's configuration
         *
         * @static
         * @async
         *
         * @param newConfig - The requested (new) agent configuration
         *
         * @returns {Promise<unknown>}
         */
        setConfiguration : (newConfig) => new Promise((resolve, reject) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    reject(ac.Utils.Common.buildReject('Agent cannot be undefined', null));
                }

                agent.setConfiguration(newConfig, {
                    success: function (data) {
                        resolve(data);
                    },
                    failure: function (data) {
                        reject(ac.Utils.Common.buildReject('Failed to set configuration', null));
                    }
                });
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('setConfiguration error', err));
            }
        }),

        /**
         * Gets the current agent's configured desktop phone number
         *
         * @static
         *
         * @returns {String}
         *
         * @throws {Error}
         *
         * @example
         * let phoneNumber = ac.Utils.Agent.getAgentDeskphoneNumber();
         */
        getAgentDeskphoneNumber : () => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw ac.Utils.Common.buildError('Agent cannot be undefined');
                }
                const agentConfig = agent.getConfiguration();
                const extension = agentConfig && agentConfig.extension;

                return extension;
            }
            catch (err) {
                throw ac.Utils.Common.buildError('getAgentDeskphoneNumber error: ' + err.message);
            }
        },

        /**
         * Returns whether or not the current agent is softphone mode enabled.
         *
         * @static
         *
         * @returns {Boolean}
         *
         * @throws {Error}
         *
         * @example
         * let isSoftphoneEnabled = ac.Utils.Agent.isAgentSoftphoneEnabled();
         */
        isAgentSoftphoneEnabled : () => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw ac.Utils.Common.buildError('Agent cannot be undefined');
                }
                const agentConfig = agent.getConfiguration();
                const softphoneEnabled = agentConfig && agentConfig.softphoneEnabled;

                return softphoneEnabled;
            }
            catch (err) {
               throw ac.Utils.Common.buildError('isAgentSoftphoneEnabled error');
            }
        },

        /**
         * Changes the current agent to softphone mode.
         *
         * @static
         * @async
         *
         * @returns {Promise<Object|Error>}
         *
         * @example
         * ac.Utils.Agent.changeToSoftPhone();
         *
         * @example
         * await ac.Utils.Agent.changeToSoftPhone();
         */
        changeToSoftPhone : () => new Promise((resolve, reject) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw ac.Utils.Common.buildError('Agent cannot be undefined');
                }

                let newConfig = agent && agent.getConfiguration();
                newConfig.softphoneEnabled = true;
                agent.setConfiguration(newConfig, {
                    success: function (data) {
                        resolve(data);
                    },
                    failure: function (data) {
                        reject(ac.Utils.Common.buildReject('Failed to change to softphone', null));
                    }
                });
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('changeToSoftphone error', err));
            }
        }),

        /**
         * Changes the current agent to desktop phone mode with the specified phone number.
         *
         * @static
         * @async
         *
         * @param phoneNumber - THe phone number to use in desk phone mode
         *
         * @throws {Error}
         *
         * @example
         * ac.Utils.Agent.changeToDeskphone();
         *
         * @example
         * await ac.Utils.Agent.changeToDeskphone();
         */
        changeToDeskphone : (phoneNumber = null) => new Promise((resolve, reject) =>  {
            try {
                let agent = _getAgent();

                if (!phoneNumber) {
                    reject(ac.Utils.Common.buildReject('Phone number cannot be undefined', null));
                }
                if (!agent) {
                    reject(ac.Utils.Common.buildReject('Agent cannot be undefined', null));
                }

                let newConfig = agent.getConfiguration();
                newConfig.softphoneEnabled = false;

                if (phoneNumber) {
                    newConfig.extension = phoneNumber;
                }

                agent.setConfiguration(newConfig, {
                    success: function (data) {
                        resolve(data);
                    },
                    failure: function (data) {
                        reject(ac.Utils.Common.buildReject('Failed to change to deskphone', data));
                    }
                });
            }
            catch (err) {
                reject(ac.Utils.Common.buildReject('changeToDeskphone error',  err));
            }
        }),

        /**
         * Gets the list of dialable countries for the current agent.
         *
         * @static
         *
         * @returns {Array<String>}
         *
         * @throws {Error}
         *
         * @example
         * let countries = ac.Utils.Agent.getDialableCountries();
         */
        getDialableCountries : () => {
            try {
                const agent = _getAgent();

                if (!agent) {
                    throw ac.Utils.Common.buildError('Agent cannot be undefined');
                }

                const agentConfig = agent.getConfiguration();

                return agentConfig && agentConfig.dialableCountries;
            } catch (err) {
                throw ac.Utils.Common.buildError('getDialableCountries error: ' + err.message);
            }
        },

        /**
         * Gets all of the current contacts of the specified type.
         *
         * @static
         *
         * @param {String} type - The type of contact to filter upon (VOICE, CHAT)
         *
         * @returns {Array<ConnectContact>}
         *
         * @example
         * let voiceContacts = ac.Utils.Agent.getContacts('VOICE');
         *
         * @example
         * let chatContacts = ac.Utils.Agent.getcontacts('CHAT');
         */
        getContacts : (type) => {
            try {
                let agent = _getAgent();

                if (!agent) {
                    throw ac.Utils.Common.buildError('Agent cannot be undefined');
                }

                return agent.getContacts(type);
            }
            catch (err) {
                throw ac.Utils.Common.buildError('getContacts error: ' + err.message);
            }
        },

        /**
         * Gets the current agent
         *
         * @static
         *
         * @returns {ConnectAgent}
         *
         * @example
         * let agent = ac.Utils.Agent.getAgent();
         */
        getAgent : () => {
            return _getAgent();
        }
    };

    /**
     * @private
     *
     * @returns {Agent}
     */
    const _getAgent = () => {
        try {
            return new connect.Agent();
        }
        catch (err) {
            throw err;
        }
    };
})(this);
