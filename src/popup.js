const toggle = document.getElementById('power-toggle');
const statusText = document.getElementById('status');

chrome.storage.local.get(['godModeActive'], (result) => {
  const active = result.godModeActive !== false;
  toggle.checked = active;
  statusText.innerText = active ? "ACTIVE" : "DISABLED";
  statusText.style.color = active ? "#ff3e00" : "#555";
});

toggle.addEventListener('change', () => {
  const isActive = toggle.checked;
  statusText.innerText = isActive ? "ACTIVE" : "DISABLED";
  statusText.style.color = isActive ? "#ff3e00" : "#555";
  chrome.storage.local.set({ godModeActive: isActive });
  
  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    if (tabs[0]) {
      chrome.tabs.sendMessage(tabs[0].id, { action: "toggleGodMode", state: isActive });
    }
  });
});
