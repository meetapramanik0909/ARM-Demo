body {
    background-color: #F2F2F2;
    border: none;
    margin: 0px;
    padding: 0px;
}

iframe {
    border-style: none;
}

.wave {
    display: block;
    position: relative;
    user-select: none;
    height: 80px;
    overflow: auto hidden;
}

.waveControls {
    margin-top: 10px;
    display: flex;
    justify-content: center;
}

.waveControls .btn {
    margin: 10px;
}


.flex-container {
    display: -ms-flexbox;
    display: -webkit-flex;
    display: flex;
    -webkit-flex-direction: column;
    -ms-flex-direction: column;
    flex-direction: column;
    -webkit-flex-wrap: nowrap;
    -ms-flex-wrap: nowrap;
    flex-wrap: nowrap;
    -webkit-justify-content: center;
    -ms-flex-pack: center;
    justify-content: center;
    -webkit-align-content: center;
    -ms-flex-line-pack: center;
    align-content: center;
    -webkit-align-items: center;
    -ms-flex-align: center;
    align-items: center;
}

#loginPanel {
    margin-top: 250px
}

#ccpPanel {
    -webkit-order: 1;
    -ms-flex-order: 1;
    order: 1;
    -webkit-flex: 1 1 auto;
    -ms-flex: 1 1 auto;
    flex: 1 1 auto;
    -webkit-align-self: stretch;
    -ms-flex-item-align: stretch;
    align-self: stretch;
}

#bottomPanel {
    -webkit-order: 2;
    -ms-flex-order: 2;
    order: 2;
    -webkit-flex: 0 1 auto;
    -ms-flex: 0 1 auto;
    flex: 0 1 auto;
    -webkit-align-self: stretch;
    -ms-flex-item-align: stretch;
    align-self: stretch;
}

.container {
    height: 200px;
    position: relative;
    border: 3px solid green;
}

.vertical-center {
    margin: 0;
    position: absolute;
    top: 50%;
    -ms-transform: translateY(-50%);
    transform: translateY(-50%);
}

#outerWrapper {
    justify-content: center;
    text-align: center;
    vertical-align: middle;
    align-items: center;
    margin: 0 auto;
    border: none;
    padding: 0;
}

#ccpContainer {
    width: 1px;
    height: 1px;
    justify-content: center;
    align-items: center;
    border: none;
}

#helperPanel {
    top: 52px;
    left: 280px;
    position: absolute;
    cursor: pointer;
    display: flex;
}

#attributesPopover, #linksPopover {
    top: 72px;
    left: 6px;
    position: absolute;
    width: 95%;
    min-width: initial;
    max-height: 170px;
    display: flex;
    flex-direction: column;
}

.slds-scope .slds-table td,
.slds-scope .slds-table th {
    padding: 0px;
}

.hidden {
    display: none;
}

.popover-content {
    overflow-y: auto;
    overflow-x: hidden;
    flex: 1;
}
