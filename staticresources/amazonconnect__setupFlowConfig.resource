{
  "data": {
    "CallCenter": {
      "fields": [
        {
          "name": "reqConnectSFCCPOptions/reqConnectURL",
          "type": "string"
        }
      ]
    }
  },
  "ui": {
    "elements": [
      {
        "control": "url",
        "label": "Amazon Connect CCP URL",
        "scope": "CallCenter.reqConnectSFCCPOptions/reqConnectURL",
        "placeholder": "https://your-instance-alias.awsapps.com/connect/ccp",
	      "required": true
      }
    ]
  },
  "cta": [
    {
      "type": "url",
      "name": "Amazon Connect Setup Guide",
      "desc": "Next steps to configure advanced feature of Amazon Connect",
      "path": "https://docs.aws.amazon.com/connect/latest/adminguide/salesforce-integration.html"
    }
  ]
}
