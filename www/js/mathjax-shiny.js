// ============================================
// MATHJAX INTEGRATION FOR SHINY
// ============================================
// Ensures MathJax typesets content after Shiny updates

console.log('[MathJax-Shiny] Script loaded');

// Track initialization state
var mathJaxFullyReady = false;
var initializationAttempts = 0;
var MAX_INIT_ATTEMPTS = 100; // 10 seconds max

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
        // Typeset any existing content
        typesetPage();
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

// Typeset the entire page
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

  MathJax.typesetPromise()
    .then(function() {
      console.log('[MathJax-Shiny] ✓ Typeset complete');
    })
    .catch(function(err) {
      console.error('[MathJax-Shiny] ✗ Typeset error:', err);
    });
}

// Start initialization when DOM is ready
$(document).ready(function() {
  console.log('[MathJax-Shiny] DOM ready, starting MathJax initialization');
  initializeMathJax();
});

// Typeset when Shiny updates outputs
$(document).on('shiny:value', function(event) {
  console.log('[MathJax-Shiny] Shiny value updated:', event.name);

  if (mathJaxFullyReady) {
    setTimeout(typesetPage, 150);
  } else {
    console.log('[MathJax-Shiny] Skipping typeset - MathJax not ready yet');
  }
});

// Typeset when main content changes
$(document).on('shiny:outputinvalidated', function(event) {
  if (event.name === 'main_content') {
    console.log('[MathJax-Shiny] Main content invalidated');
    if (mathJaxFullyReady) {
      setTimeout(typesetPage, 100);
    }
  }
});
