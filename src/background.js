chrome.runtime.onInstalled.addListener(() => {
  chrome.declarativeNetRequest.updateDynamicRules({
    removeRuleIds: [10],
    addRules: [{
      "id": 10,
      "priority": 1,
      "action": {
        "type": "modifyHeaders",
        "requestHeaders": [{ "header": "user-agent", "operation": "set", "value": "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" }]
      },
      "condition": { "urlFilter": "specific-paywall-site.com", "resourceTypes": ["main_frame"] }
    }]
  });
});
