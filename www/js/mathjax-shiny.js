// ============================================
// MATHJAX INTEGRATION FOR SHINY
// ============================================
// Ensures MathJax typesets content after Shiny updates

console.log('[MathJax-Shiny] Script loaded');

// Track initialization state
var mathJaxFullyReady = false;
var initializationAttempts = 0;
var MAX_INIT_ATTEMPTS = 100; // 10 seconds max
var typesetTimeout = null;

// Initialize MathJax - wait for it to be fully ready
function initializeMathJax() {
  initializationAttempts++;

  console.log('[MathJax-Shiny] Initialization attempt', initializationAttempts);

  if (typeof MathJax !== 'undefined' &&
      MathJax.startup &&
      MathJax.startup.promise &&
      typeof MathJax.typesetPromise === 'function') {

    console.log('[MathJax-Shiny] MathJax object found, waiting for startup...');

    MathJax.startup.promise
      .then(function() {
        mathJaxFullyReady = true;
        console.log('[MathJax-Shiny] ✓ MathJax is ready!');
        // Initial typeset
        scheduleTypeset(500); // Wait a bit longer for initial content
      })
      .catch(function(err) {
        console.error('[MathJax-Shiny] ✗ Startup error:', err);
      });

  } else if (initializationAttempts < MAX_INIT_ATTEMPTS) {
    // Not ready yet, try again
    setTimeout(initializeMathJax, 100);
  } else {
    console.error('[MathJax-Shiny] ✗ Failed to initialize after', MAX_INIT_ATTEMPTS, 'attempts');
  }
}

// Schedule a typeset (debounced to avoid race conditions)
function scheduleTypeset(delay) {
  delay = delay || 300; // Default 300ms delay

  // Clear any pending typeset
  if (typesetTimeout) {
    clearTimeout(typesetTimeout);
  }

  // Schedule new typeset
  typesetTimeout = setTimeout(function() {
    typesetTimeout = null;
    typesetPage();
  }, delay);
}

// Typeset the page
function typesetPage() {
  if (!mathJaxFullyReady) {
    console.log('[MathJax-Shiny] Typeset called but MathJax not ready yet, ignoring');
    return;
  }

  if (typeof MathJax === 'undefined' || !MathJax.typesetPromise) {
    console.error('[MathJax-Shiny] MathJax.typesetPromise not available');
    return;
  }

  console.log('[MathJax-Shiny] Typesetting page...');

  // Clear any existing MathJax output first
  try {
    if (MathJax.typesetClear) {
      MathJax.typesetClear();
      console.log('[MathJax-Shiny] Cleared previous typesetting');
    }
  } catch (e) {
    console.log('[MathJax-Shiny] Could not clear typesetting:', e);
  }

  // Typeset the page
  MathJax.typesetPromise()
    .then(function() {
      console.log('[MathJax-Shiny] ✓ Typeset complete');
    })
    .catch(function(err) {
      console.error('[MathJax-Shiny] ✗ Typeset error:', err);
      // Try to recover by clearing and retrying once
      if (MathJax.typesetClear) {
        console.log('[MathJax-Shiny] Attempting recovery...');
        MathJax.typesetClear();
        setTimeout(function() {
          MathJax.typesetPromise().catch(function(err2) {
            console.error('[MathJax-Shiny] ✗ Recovery failed:', err2);
          });
        }, 100);
      }
    });
}

// Start initialization when DOM is ready
$(document).ready(function() {
  console.log('[MathJax-Shiny] DOM ready, starting MathJax initialization');
  initializeMathJax();
});

// Typeset when Shiny updates outputs (debounced)
$(document).on('shiny:value', function(event) {
  console.log('[MathJax-Shiny] Shiny value updated:', event.name);

  if (mathJaxFullyReady) {
    scheduleTypeset(300);
  } else {
    console.log('[MathJax-Shiny] Skipping typeset - MathJax not ready yet');
  }
});

// Typeset when main content changes (debounced)
$(document).on('shiny:outputinvalidated', function(event) {
  if (event.name === 'main_content') {
    console.log('[MathJax-Shiny] Main content invalidated');
    if (mathJaxFullyReady) {
      scheduleTypeset(300);
    }
  }
});

// Also listen for when outputs are bound (content fully rendered)
$(document).on('shiny:bound', function(event) {
  console.log('[MathJax-Shiny] Shiny output bound:', event.name);
  if (mathJaxFullyReady) {
    scheduleTypeset(400);
  }
});
