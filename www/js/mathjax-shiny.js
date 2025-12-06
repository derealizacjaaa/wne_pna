// ============================================
// MATHJAX INTEGRATION FOR SHINY
// ============================================
// Triggers MathJax typesetting when content changes

$(document).on('shiny:value', function(event) {
  // When any output is updated, check if MathJax is loaded
  if (window.MathJax && window.MathJax.typesetPromise) {
    // Small delay to ensure DOM is fully updated
    setTimeout(function() {
      // Typeset the entire main content area
      MathJax.typesetPromise([document.querySelector('.main-content')])
        .catch(function(err) {
          console.log('MathJax typeset error:', err);
        });
    }, 100);
  }
});

// Also trigger on page load
$(document).ready(function() {
  if (window.MathJax && window.MathJax.typesetPromise) {
    setTimeout(function() {
      MathJax.typesetPromise()
        .catch(function(err) {
          console.log('MathJax initial typeset error:', err);
        });
    }, 500);
  }
});

// Alternative: Use MutationObserver to watch for content changes
$(document).ready(function() {
  // Wait for MathJax to load
  var checkMathJax = setInterval(function() {
    if (window.MathJax && window.MathJax.typesetPromise) {
      clearInterval(checkMathJax);

      // Set up observer for main content area
      var targetNode = document.querySelector('.content-wrapper-dual');
      if (targetNode) {
        var observer = new MutationObserver(function(mutations) {
          // Debounce: only typeset after changes stop for 200ms
          clearTimeout(observer.timeout);
          observer.timeout = setTimeout(function() {
            MathJax.typesetPromise()
              .catch(function(err) {
                console.log('MathJax observer typeset error:', err);
              });
          }, 200);
        });

        observer.observe(targetNode, {
          childList: true,
          subtree: true
        });
      }
    }
  }, 100);

  // Stop checking after 10 seconds
  setTimeout(function() {
    clearInterval(checkMathJax);
  }, 10000);
});
