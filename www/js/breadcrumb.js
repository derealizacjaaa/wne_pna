// Breadcrumb navigation enhancement
(function () {
  'use strict';

  // Helper function to convert list name to Roman numerals
  function getListRomanNumeral(listName) {
    const match = listName.match(/lista([ivxlcdm]+)/i);
    if (!match) return listName;

    const romanMap = {
      'i': 'I', 'ii': 'II', 'iii': 'III', 'iv': 'IV', 'v': 'V',
      'vi': 'VI', 'vii': 'VII', 'viii': 'VIII', 'ix': 'IX', 'x': 'X'
    };

    const roman = match[1].toLowerCase();
    return 'Lista ' + (romanMap[roman] || roman.toUpperCase());
  }

  // Function to update breadcrumb based on current state
  function updateBreadcrumb() {
    // Find the main content header h3 (where we'll replace the text)
    const mainContentHeader = document.querySelector('.main-content-header h3');
    if (!mainContentHeader) return;

    // Get current list name
    // 1. Try secure hidden data attribute (injected by server)
    const listDataEl = document.getElementById('current-list-data');
    let listName = null;

    if (listDataEl && listDataEl.getAttribute('data-name')) {
      listName = listDataEl.getAttribute('data-name').toLowerCase().replace(/\s+/g, '');
    } else {
      // 2. Fallback to sidebar scraping (legacy)
      const activeList = document.querySelector('.list-item.active');
      listName = activeList ? activeList.textContent.trim().split('\n')[0].toLowerCase().replace(/\s+/g, '') : null;
    }

    // Get current task from right sidebar
    const activeTask = document.querySelector('.task-item.active');
    let taskNum = null;
    if (activeTask) {
      const taskNumberEl = activeTask.querySelector('.task-number');
      taskNum = taskNumberEl ? taskNumberEl.textContent.trim() : null;
    }

    // Build breadcrumb HTML
    let breadcrumbHTML = '';
    breadcrumbHTML += '<span class="breadcrumb-item">-wne</span>';
    breadcrumbHTML += '<span class="breadcrumb-separator">/</span>';
    breadcrumbHTML += '<span class="breadcrumb-item">pna</span>';

    if (listName) {
      breadcrumbHTML += '<span class="breadcrumb-separator">/</span>';
      const formattedList = getListRomanNumeral(listName);
      breadcrumbHTML += `<span class="breadcrumb-item">${formattedList}</span>`;
    }

    if (taskNum) {
      breadcrumbHTML += '<span class="breadcrumb-separator">/</span>';
      breadcrumbHTML += `<span class="breadcrumb-item">Zadanie ${taskNum}</span>`;
    }

    // Replace the h3 content with breadcrumb
    mainContentHeader.innerHTML = breadcrumbHTML;
  }

  // Update breadcrumb on page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', updateBreadcrumb);
  } else {
    updateBreadcrumb();
  }

  // Update breadcrumb when Shiny updates the UI
  $(document).on('shiny:value', function (event) {
    setTimeout(updateBreadcrumb, 100);
  });

  // Update breadcrumb when list or task is clicked
  $(document).on('click', '.list-item, .task-item', function () {
    setTimeout(updateBreadcrumb, 200);
  });

})();