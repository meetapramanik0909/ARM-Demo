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
     * @type {Array}
     */
    let _ctiAttributes = [];

    /**
     *
     * @private
     *
     * @enum
     * @type {{LINKS_INDICATOR: string, LINKS_POPOVER: string, LINKS_TABLE: string,
     * ATTRIBUTES_INDICATOR: string, ATTRIBUTES_POPOVER: string, ATTRIBUTES_TABLE: string}}
     */
    const DOM_ELEMENTS = {
        ATTRIBUTES_INDICATOR: '#attributesIndicator',
        ATTRIBUTES_POPOVER: '#attributesPopover',
        ATTRIBUTES_TABLE: '#attributesTable',
        LINKS_INDICATOR: '#linksIndicator',
        LINKS_POPOVER: '#linksPopover',
        LINKS_TABLE: '#linksTable'
    };

    /**
     *
     * @private
     *
     * @type {{HYPERLINK: string, TEXT: string}}
     */
    const ATTRIBUTE_TYPES = {
        TEXT: 'text',
        HYPERLINK: 'hyperlink'
    };

    /**
     *
     * @private
     *
     * @type {{VALUE: string, KEY_VALUE: string, KEY: string}}
     */
    const ATTRIBUTE_DISPLAYS = {
        KEY_VALUE: 'key-value',
        KEY: 'key',
        VALUE: 'value'
    };

    /**
     *
     * @private
     *
     * @type {number}
     */
    const MAX_WIDTH_CONSOLE = 120;

    /**
     * @class ac.Utils.CtiAttributes
     *
     * @description
     * The ac.Utils.CtiAttributes class provides helper methods for controlling cti attribute display.
     */
    ac.Utils.CtiAttributes = {
        /**
         * Initializes the ac.Utils.CtiAttibutes utility
         *
         * @private
         *
         * @param {Object} props
         * @param {Array} ctiAttributes
         */
        init : (props, ctiAttributes) => {
            _props = props;
            _ctiAttributes = ctiAttributes;

            $(DOM_ELEMENTS.ATTRIBUTES_INDICATOR).click((event) => {
                _toggleAttributesPopover();
            });

            $(DOM_ELEMENTS.LINKS_INDICATOR).click((event) => {
                _toggleLinksPopover();
            });

            let clipboard = new ClipboardJS('.copyToClipboard');
        },

        /**
         * Show the links indicator
         *
         * @example
         * ac.Utils.CtiAttributes.showLinksIndicator();
         */
        showLinksIndicator : () => {
            $(DOM_ELEMENTS.LINKS_INDICATOR).removeClass('slds-hide');
        },

        /**
         * Hide the links indicator
         *
         * @example
         * ac.Utils.CtiAttributes.hideLinksIndicator();
         */
        hideLinksIndicator : () => {
            $(DOM_ELEMENTS.LINKS_INDICATOR).addClass('slds-hide');
            $(DOM_ELEMENTS.LINKS_POPOVER).addClass('slds-hide');
        },

        /**
         * Show the attributes indicator
         *
         * @example
         * ac.Utils.CtiAttributes.showAttributesIndicator();
         */
        showAttributesIndicator : () => {
            $(DOM_ELEMENTS.ATTRIBUTES_INDICATOR).removeClass('slds-hide');
        },

        /**
         * Hide the attributes indicator
         *
         * @example
         * ac.Utils.CtiAttributes.hideAttributesIndicator();
         */
        hideAttributesIndicator : () => {
            $(DOM_ELEMENTS.ATTRIBUTES_INDICATOR).addClass('slds-hide');
            $(DOM_ELEMENTS.ATTRIBUTES_POPOVER).addClass('slds-hide');
        },

        /**
         * Populate the attributes and links tables with cti data
         *
         * @private
         *
         * @param contact
         */
        populate : (contact) => {
            _populate(contact);
        },

        /**
         * Clear the attributes and links tables
         *
         * @private
         */
        depopulate : () => {
            _depopulate();
        }
    };

    /**
     *
     * @private
     */
    const _toggleAttributesPopover = () => {
        $(DOM_ELEMENTS.LINKS_POPOVER).addClass('slds-hide');
        $(DOM_ELEMENTS.ATTRIBUTES_POPOVER).toggleClass('slds-hide');
    };

    /**
     *
     * @private
     */
    const _toggleLinksPopover = () => {
        $(DOM_ELEMENTS.ATTRIBUTES_POPOVER).addClass('slds-hide');
        $(DOM_ELEMENTS.LINKS_POPOVER).toggleClass('slds-hide');
    };

    /**
     *
     * @private
     */
    const _depopulate = () => {
        $('#attributesTable > tbody').empty();
        $('#linksTable > tbody').empty();
    };

    /**
     *
     * @private
     *
     * @param contact
     */
    const _populate = (contact) => {
        if (!contact.isInbound()) {
             return;
        }

        _depopulate();

        const addNewRow = (item) => {
            let table;

            let type = ac.Utils.Salesforce.getValueWithNamespace(item, 'Type__c');
            let display = ac.Utils.Salesforce.getValueWithNamespace(item, 'Display__c');
            let style = ac.Utils.Salesforce.getValueWithNamespace(item, 'Style__c');

            if (type.toUpperCase() === ATTRIBUTE_TYPES.TEXT.toUpperCase()) {
                table = $('#attributesTable > tbody');
            }
            else if (type.toUpperCase() === ATTRIBUTE_TYPES.HYPERLINK.toUpperCase()) {
                table = $('#linksTable > tbody');
            }

            let tr = $('<tr>');

            if (style) {
                tr.attr('style', style);
            }

            if (display.toUpperCase() === ATTRIBUTE_DISPLAYS.KEY_VALUE.toUpperCase()) {
                tr.append(createColumn(item, true,false));
                tr.append(createColumn(item,false,false));
                tr.append(createColumn(item,false,true));
            }

            if (display.toUpperCase() === ATTRIBUTE_DISPLAYS.VALUE.toUpperCase() || display.toUpperCase() === ATTRIBUTE_DISPLAYS.KEY.toUpperCase()) {
                let isKey = display.toUpperCase() === ATTRIBUTE_DISPLAYS.KEY.toUpperCase();
                tr.append(createColumn(item, isKey,false));
                tr.append(createColumn(item, isKey,true));
            }

            table && table.append(tr);
        };

        const createColumn = (item, isLabel, isClipboard) => {
            let style = ac.Utils.Salesforce.getValueWithNamespace(item, 'Style__c');
            let label = ac.Utils.Salesforce.getValueWithNamespace(item, 'Label__c');
            let display = ac.Utils.Salesforce.getValueWithNamespace(item, 'Display__c');

            let formattedItem = format(item);

            let td = $('<td>');
            td.attr('style', style);
            td.attr('data-label', isLabel ? label : formattedItem);

            if (display.toUpperCase() !== ATTRIBUTE_DISPLAYS.KEY_VALUE.toUpperCase() && !isClipboard) {
                td.attr('colspan', 2);
            }

            if (!isLabel) {
                if (isClipboard) {
                    td.attr('data-clipboard-text', formattedItem);
                    td.css({ 'max-width': '20px', 'text-align': 'right' });
                    td.html(getClipboardIcon(formattedItem));
                }
                else {
                    td.html(createColumedDiv(item, isLabel));
                    td.css( { 'max-width': MAX_WIDTH_CONSOLE + 'px' })
                }
            }
            else {
                if (isClipboard) {
                    td.attr('data-clipboard-text', formattedItem);
                    td.css({ 'max-width': '20px', 'text-align': 'right' });
                    td.html(getClipboardIcon(formattedItem));
                }
                else {
                    td.html(createColumedDiv(item, isLabel));
                    td.css({ 'max-width': MAX_WIDTH_CONSOLE + 'px' });
                }
            }

            return td;
        };

        const getClipboardIcon = (value) => {
            let template =
                `
                <span 
                    class="slds-icon_container copyToClipboard"
                    data-clipboard-text="${value}">
                    <svg 
                        aria-hidden="true" 
                        class="slds-icon slds-icon_x-small slds-icon-text-default"
                        xmlns="http://www.w3.org/2000/svg"
                        xmlns:xlink="http://www.w3.org/1999/xlink">
                        <use 
                            xlink:href="/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#copy_to_clipboard"></use>
                    </svg>
                    <span class="slds-assistive-text">Copy to clipboard</span>
                </span>
                `;

            return template;
        };

        const createColumedDiv = (item, isLabel) => {
            let label = ac.Utils.Salesforce.getValueWithNamespace(item, 'Label__c');
            let type = ac.Utils.Salesforce.getValueWithNamespace(item, 'Type__c');
            let display = ac.Utils.Salesforce.getValueWithNamespace(item, 'Display__c');

            let formattedItem = format(item);

            let div = $('<div>');
            div.addClass('slds-truncate');
            div.attr('title', isLabel ? label : formattedItem);
            div.css({ 'max-width': MAX_WIDTH_CONSOLE + 'px' });

            if (type.toUpperCase() === ATTRIBUTE_TYPES.TEXT.toUpperCase()) {
                div.text(isLabel ? label : formattedItem);
            }

            if (type.toUpperCase() === ATTRIBUTE_TYPES.HYPERLINK.toUpperCase()){
                let link;
                let linkText;

                if (display.toUpperCase() === ATTRIBUTE_DISPLAYS.KEY_VALUE.toUpperCase()) {
                    if (isLabel) {
                        div.text(label);
                    }
                    else {
                        link = $('<a>');
                        link.text(formattedItem)
                        link.attr('href', formattedItem);
                        link.attr('target', 'new');

                        div.append(link);
                    }
                }
                else {
                    link = $('<a>');
                    link.text(isLabel ? label : formattedItem);
                    link.attr('href', formattedItem);
                    link.attr('target', 'new');

                    div.append(link);
                }
            }

            return div;
        };

        const format = (item) => {
            let format = '';

            try {
                format = ac.Utils.Salesforce.getValueWithNamespace(item, 'Format__c', '');

                Object.keys(attributes).every((key) => {
                    if (format.includes('{{' + key + '}}') && attributes.hasOwnProperty(key)) {
                        format = format.replace('{{' + key + '}}', attributes[key].value);
                        return true;
                    }

                    format = ac.Utils.Salesforce.getValueWithNamespace(item, 'DefaultValue__c', '');
                    return false;
                });
            }
            catch (err) {
                ac.Utils.Log.error('format error');
            }

            return format;
        };

        let attributes = contact.getAttributes();

        _ctiAttributes.forEach((item, index) => {
            let type = ac.Utils.Salesforce.getValueWithNamespace(item, 'Type__c');

            addNewRow(item);
        });
    };
})(this);