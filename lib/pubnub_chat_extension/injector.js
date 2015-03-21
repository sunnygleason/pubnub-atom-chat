var j = document.createElement('script');
// TODO: add "script.js" to web_accessible_resources in manifest.json
j.src = chrome.extension.getURL('underscore.js');
j.onload = function() {
  this.parentNode.removeChild(this);
};
(document.head||document.documentElement).appendChild(j);