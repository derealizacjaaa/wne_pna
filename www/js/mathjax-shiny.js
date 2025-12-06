// ============================================
// MATHJAX INTEGRATION FOR SHINY
// ============================================
// Triggers MathJax typesetting when Shiny updates content

// Function to typeset math (only when MathJax is ready)
function typesetMath() {
  // Check if MathJax is fully loaded and ready
  if (typeof MathJax !== 'undefined' &&
      MathJax.typesetPromise &&
      MathJax.startup &&
      MathJax.startup.promise) {

    // Wait for MathJax to finish starting up, then typeset
    MathJax.startup.promise.then(function() {
      MathJax.typesetPromise().catch(function(err) {
        console.log('MathJax typeset error:', err);
      });
    }).catch(function(err) {
      console.log('MathJax startup error:', err);
    });
  } else {
    // MathJax not ready yet, try again in 100ms
    setTimeout(typesetMath, 100);
  }
}

// Trigger on Shiny output updates
$(document).on('shiny:value', function(event) {
  setTimeout(typesetMath, 100);
});

// Trigger on initial load - wait longer for MathJax to load
$(document).ready(function() {
  setTimeout(typesetMath, 1500);
});

// Also trigger when main content updates
$(document).on('shiny:outputinvalidated', function(event) {
  if (event.name === 'main_content') {
    setTimeout(typesetMath, 200);
  }
});
