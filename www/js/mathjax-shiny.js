// ============================================
// MATHJAX INTEGRATION FOR SHINY
// ============================================
// Triggers MathJax typesetting when Shiny updates content

// Function to typeset math
function typesetMath() {
  if (typeof MathJax !== 'undefined' && MathJax.typesetPromise) {
    MathJax.typesetPromise().catch(function(err) {
      console.log('MathJax typeset error:', err);
    });
  }
}

// Trigger on Shiny output updates
$(document).on('shiny:value', function(event) {
  setTimeout(typesetMath, 100);
});

// Trigger on initial load
$(document).ready(function() {
  setTimeout(typesetMath, 1000);
});

// Also trigger when specific outputs update
$(document).on('shiny:outputinvalidated', function(event) {
  if (event.name === 'main_content') {
    setTimeout(typesetMath, 200);
  }
});
