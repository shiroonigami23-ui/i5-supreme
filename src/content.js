let isEnabled = true;

// --- INITIALIZE STATE ---
chrome.storage.local.get(['godModeActive'], (res) => {
  isEnabled = res.godModeActive !== false;
  if (isEnabled) runSupremeEngine();
});

// --- MESSAGE LISTENER FROM POPUP ---
chrome.runtime.onMessage.addListener((request) => {
  if (request.action === "toggleGodMode") {
    isEnabled = request.state;
    // Reload to apply or strip changes immediately
    location.reload(); 
  }
});

// Hide the fact that this is an automated/modded browser
Object.defineProperty(navigator, 'webdriver', { get: () => false });

// --- i5 SUPREME: FORM GHOST (Auto-fill junk data) ---
const ghostSigner = () => {
    const emailFields = document.querySelectorAll('input[type="email"], input[name*="email"]');
    emailFields.forEach(field => {
        if (field.value === "") {
            field.value = "bypass_" + Math.floor(Math.random() * 1000) + "@example.com";
            // Trigger input events so the site thinks a human typed it
            field.dispatchEvent(new Event('input', { bubbles: true }));
            
            // Find the nearest button and click it to bypass soft-walls
            const btn = field.closest('form')?.querySelector('button, input[type="submit"]');
            if (btn) btn.click();
        }
    });
};

// --- i5 SUPREME: STEALTH CLOAK (Neutralize Anti-Debugger) ---
const neutralizeAntiMod = () => {
    if (typeof window.check === 'function') {
        window.check = () => true; 
        console.log("🛡️ Supreme Stealth: Neutralized anti-debugger loop.");
    }
};
neutralizeAntiMod();

// --- SUPREME ENGINE CORE ---
const runSupremeEngine = () => {
  if (!isEnabled) return;

  // 1. Surgical Nuker: Kill Paywalls & Overlays
  const supremeNuke = () => {
    const selectors = [
      '[class*="paywall"]', '[id*="paywall"]', '[class*="modal"]', '[class*="overlay"]',
      'div[style*="fixed"][style*="z-index: 2147483647"]',
      '.tp-modal', '.tp-backdrop', '.tp-active', '[class*="gate"]'
    ];

    selectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        const rect = el.getBoundingClientRect();
        // Only nuke elements that are large enough to be obstructive
        if (rect.width > 200 || rect.height > 200) el.remove();
      });
    });

    // Force Scrollability (unlocks page if popup disabled it)
    document.documentElement.style.setProperty('overflow', 'auto', 'important');
    document.body.style.setProperty('overflow', 'auto', 'important');
    document.body.style.setProperty('position', 'static', 'important');
  };

  // 2. Content Liberator: Remove Blurs & Un-hide Text
  const liberateContent = () => {
    document.querySelectorAll('[style*="filter: blur"], [class*="blurred"]').forEach(el => {
      el.style.setProperty('filter', 'none', 'important');
    });

    const hiddenSelectors = ['[class*="paywall-content"]', '[class*="restricted-content"]', '.premium-content'];
    hiddenSelectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        el.style.setProperty('display', 'block', 'important');
        el.style.setProperty('opacity', '1', 'important');
      });
    });
  };

  // 3. Copy-Paste Enforcer (Steal text from protected sites)
  const enforceFreedom = () => {
    window.addEventListener('contextmenu', (e) => e.stopPropagation(), true);
    ['copy', 'cut', 'paste', 'selectstart'].forEach(event => {
      window.addEventListener(event, (e) => e.stopPropagation(), true);
    });
    const style = document.createElement('style');
    style.innerHTML = `* { user-select: text !important; -webkit-user-select: text !important; }`;
    document.documentElement.appendChild(style);
  };

  // EXECUTION LOOPS
  enforceFreedom();
  
  // High-frequency loop for first 5 seconds to catch aggressive popups
  const fastLoop = setInterval(() => { 
      supremeNuke(); 
      liberateContent(); 
      ghostSigner(); 
  }, 300);
  
  setTimeout(() => clearInterval(fastLoop), 5000); 

  // Persistent observer for dynamic page changes
  const observer = new MutationObserver(() => { 
      supremeNuke(); 
      liberateContent(); 
  });
  observer.observe(document.documentElement, { childList: true, subtree: true });
};

// --- SHORTCUTS: VIDEO SPEED (S) & ATOMIC NUKE (Alt+X) ---
window.addEventListener('keydown', (e) => {
  if (!isEnabled) return;
  
  // Hold 'S' for 10x Video Speed
  if (e.key.toLowerCase() === 's') {
    document.querySelectorAll('video').forEach(v => v.playbackRate = 10.0);
  }
  
  // Alt + X: Vaporize the element currently under the mouse
  if (e.altKey && e.key.toLowerCase() === 'x') {
    const hovered = document.querySelectorAll(':hover');
    if (hovered.length) {
      const target = hovered[hovered.length - 1];
      target.style.display = 'none';
      console.log("🔱 God Mode: Element manually vaporized.");
    }
  }
});

// Reset video speed on key release
window.addEventListener('keyup', (e) => {
  if (e.key.toLowerCase() === 's') {
    document.querySelectorAll('video').forEach(v => v.playbackRate = 1.0);
  }
});