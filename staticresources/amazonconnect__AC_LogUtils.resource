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
     * @class ac.Utils.Log
     * @memberOf ac.Utils
     *
     * @description
     * The ac.Utils.Log class provides helper methods for logging.
     *
     * @see https://github.com/aws/amazon-connect-streams/blob/master/Documentation.md#streams-logger
     */
    ac.Utils.Log = {
        /**
         * Initializes the ac.Utils.Log utility
         *
         * @private
         *
         * @param {Object} props
         */
        init : (props) => {
            _props = props;
        },

        /**
         * Logs a debug message using the Connect Streams logger
         *
         * @example
         * ac.Utils.Log.debug('This is a debug message.');
         *
         * @example
         * ac.Utils.Log.debug('This is a debug message.', error);
         *
         * @param {String} message - Message to log
         * @param {Object} exception - Exception to log
         */
        debug : (message = undefined, exception = undefined) => {
            _log('debug', message, exception);
        },

        /**
         * Logs an info message using the Connect Streams logger
         *
         * @example
         * ac.Utils.Log.info('This is an info message.');
         *
         * @example
         * ac.Utils.Log.info('This is an info message.', error);
         *
         * @param {String} message - Message to log
         * @param {Object} exception - Exception to log
         */
        info : (message = undefined, exception = undefined) => {
            _log('info', message, exception);
        },

        /**
         * Logs a warn message using the Connect Streams logger
         *
         * @example
         * ac.Utils.Log.info('This is a warn message.');
         *
         * @example
         * ac.Utils.Log.info('This is a warn message.', error);
         *
         * @param {String} message - Message to log
         * @param {Object} exception - Exception to log
         */
        warn : (message = undefined, exception = undefined) => {
            _log('warn', message, exception);
        },

        /**
         * Logs an error message using the Connect Streams logger
         *
         * @example
         * ac.Utils.Log.info('This is an error message.');
         *
         * @example
         * ac.Utils.Log.info('This is an error message.', error);
         *
         * @param {String} message - Message to log
         * @param {Object} exception - Exception to log
         */
        error : (message = undefined, exception = undefined) => {
            _log('error', message, exception);
        }
    };

    /**
     * Logs a message using the Connect Streams logger
     *
     * @private
     *
     * @param level - Logging level (debug, info, warn, error)
     * @param {String} message - Message to log
     * @param {Object} exception - Exception to log
     */
    const _log = (level = 'info', message = undefined, exception = undefined) => {
        if (message && exception) {
            connect.getLog()[level](message).withException(exception);
        } else if (message && !exception) {
            connect.getLog()[level](message);
        } else if (!message && exception) {
            connect.getLog()[level]('').withException(exception);
        } else {
            connect.getLog()[level]('invalid log method call');
        }
    };
})(this);
