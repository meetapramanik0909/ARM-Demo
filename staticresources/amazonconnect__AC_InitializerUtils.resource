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
     * @type {boolean}
     */
    let _isInitialized = false;

    /**
     *
     * @private
     *
     * @type {Window}
     */
    let _loginWindow = null;

    /**
     *
     * @private
     *
     * @class ac.Utils.Initializer
     * @memberOf ac.Utils
     *
     * @namespace ac.Utils.Initializer
     */
    ac.Utils.Initializer = {
        /**
         *
         * @private
         *
         * @param props
         * @param callback
         *
         * @returns {Promise|Error}
         */
        init : async (props, callback) => {
            const _props = props;

            const _callCenterSettings = await ac.Utils.Salesforce.getCallCenterSettings();
            const _ctiAdapter = await ac.Utils.Salesforce.getCtiAdapter(_callCenterSettings['/reqGeneralInfo/reqInternalName']);

            const _baseUrl = `https://${ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'Instance__c')}.awsapps.com/connect`;
            const _ssoUrl = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'SsoUrl__c', '');
            const _ssoRelayState = he.decode(ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'SsoRelayState__c', ''));
            const _bottomPanel = he.decode(ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'BottomPanel__c', ''));
            const _softphonePopoutEnabled = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'SoftphonePopoutEnabled__c', true);
            const _presenceSyncEnabled = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'PresenceSyncEnabled__c', false);
            const _ctiScripts = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'Scripts__r', []);
            const _ctiAttributes = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'Attributes__r', []);
            const _ctiPresenceSyncRules = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'PresenceSyncRules__r', []);

            ac.Utils.Common.setProperty('ctiAdapter', _ctiAdapter);

            let container = $('#ccpPanel');

            // ToDo: Calculate based upon call center definition height & width and topPanel & bottomPanel heights
            container.height('520px');
            container.width('325px');

            const loginUrl = !_ssoUrl ? `${_baseUrl}/login` : _ssoUrl + '?' + _ssoRelayState;

            const ccpUrl = `${_baseUrl}/ccp-v2`;

            const medialess = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'Medialess__c', false);

            const ccpConfig = {
                ccpUrl: ccpUrl,
                loginPopup: false,
                softphone: {
                    allowFramedSoftphone: !medialess
                }
            };

            let customRingtone = ac.Utils.Salesforce.getValueWithNamespace(_ctiAdapter, 'CustomRingtone__c', '');

            if (customRingtone && customRingtone.startsWith("https://")) {
                ccpConfig.softphone.ringtoneUrl = customRingtone;
            }

            if (!_isInitialized) {
                setTimeout(function () {
                    if (!_isInitialized) {
                        $('#loginButton').click();
                    }
                }, 5000);
            }

            connect.core.initCCP(container.get(0), ccpConfig);

            $('#loginButton').click((event) => {
                if (!_loginWindow || (_loginWindow && _loginWindow.closed)) {
                    _loginWindow = undefined;

                    const width = 500;
                    const height = 600;
                    const left = (screen.width / 2) - (width / 2);
                    const top = (screen.height / 2) - (height / 2);

                    _loginWindow = window.open(loginUrl, "_blank", "width=" + width +
                        ",height=" + height + ",menubar=no,status=no,toolbar=no,left=" + left + ",top=" + top);
                }
                else {
                    _loginWindow.focus();
                }
            });

            connect.core.getEventBus().subscribe(connect.EventType.TERMINATED, async (e) => {
                window.location.reload();
            });

            connect.agent(async (agent) => {
                _isInitialized = true;

                _loginWindow && _loginWindow.close();
                _loginWindow = undefined;

                await ac.Utils.Salesforce.setSoftphonePopoutEnabled(_softphonePopoutEnabled);
                _showSoftphone();

                ac.Utils.Common.delay(2000).then(() => callback(_bottomPanel, _presenceSyncEnabled, _ctiScripts, _ctiAttributes, _ctiPresenceSyncRules));
            });
        }
    };

    /**
     *
     * @private
     */
    const _showSoftphone = () => {
        $('#softphoneContainer').removeClass('slds-hide');
        $('#loginContainer').addClass('slds-hide');
    };

    /**
     *
     * @private
     */
    const _showLogin = function () {
        $('#softphoneContainer').addClass('slds-hide');
        $('#loginContainer').removeClass('slds-hide');
    };
})(this);
