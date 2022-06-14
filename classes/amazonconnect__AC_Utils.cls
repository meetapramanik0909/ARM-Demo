/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AC_Utils {
    global AC_Utils() {

    }
    @AuraEnabled
    @RemoteAction
    global static amazonconnect.AC_Utils.RecordingAttachmentWrapper getAttachedCallRecording(Id recordId, String agentLabel, String agentColor, String customerLabel, String customerColor) {
        return null;
    }
    @AuraEnabled
    @RemoteAction
    global static List<amazonconnect.AC_Utils.TranscriptItem> getAttachedTranscript(Id recordId, String name, String speaker, String color) {
        return null;
    }
    @AuraEnabled
    @RemoteAction
    global static List<amazonconnect.AC_Utils.TranscriptItem> getAttachedVoiceTranscript(Id recordId, String agentLabel, String agentColor, String customerLabel, String customerColor) {
        return null;
    }
    global static String getCharAtIndex(String str, Integer index) {
        return null;
    }
    @AuraEnabled
    @RemoteAction
    global static amazonconnect.AC_Utils.AttachmentWrapper getContactChannelAnalyticsAttachment(Id recordId, String name) {
        return null;
    }
    @AuraEnabled
    @RemoteAction
    global static amazonconnect__AC_CtiAdapter__c getCtiAdapter(String name) {
        return null;
    }
    @AuraEnabled
    global static String getNamespaceClassPrefix() {
        return null;
    }
    @AuraEnabled
    global static String getNamespacePagePrefix() {
        return null;
    }
    @AuraEnabled
    @RemoteAction
    global static String getS3Object(String namedCredential, String key, Integer timeout) {
        return null;
    }
    @AuraEnabled
    @RemoteAction
    global static List<amazonconnect.AC_Utils.ServicePresenceStatusWrapper> getServicePresenceStatuses() {
        return null;
    }
    @AuraEnabled
    @RemoteAction
    global static amazonconnect.AC_Utils.WorkHolder getWorkHolder(Id workId) {
        return null;
    }
    @RemoteAction
    global static String newGuid() {
        return null;
    }
global virtual class AttachmentWrapper {
    global AttachmentWrapper() {

    }
}
global class RecordingAttachmentWrapper {
    global RecordingAttachmentWrapper() {

    }
}
global class ServicePresenceStatusWrapper {
}
global class TranscriptItem {
    global TranscriptItem() {

    }
}
global class WorkHolder {
}
}
