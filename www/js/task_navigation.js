/* Custom Task Tab Navigation Handler
   Solves Bootstrap version conflicts by manually handling tab switching
*/

document.addEventListener('DOMContentLoaded', function () {
    // Event delegation for static and dynamically created tabs
    document.body.addEventListener('click', function (e) {
        // Check if clicked element is a task nav link or inside one
        const link = e.target.closest('.task-nav-link');

        if (link) {
            e.preventDefault(); // Prevent default anchor behavior

            // 1. Get identifiers
            const targetSelector = link.getAttribute('data-task-target');
            if (!targetSelector) return;

            // 2. Find the specific container for the header tabs
            const tabsContainer = link.closest('.task-tabs-container');

            // 3. Find target pane and its container
            // We search globally because IDs are unique and structure might vary (not always siblings)
            const targetPane = document.querySelector(targetSelector);

            if (!targetPane) {
                console.warn("Task Navigation: Target pane not found:", targetSelector);
                return;
            }

            // The content container is the parent of the pane
            const contentContainer = targetPane.closest('.tab-content');

            if (!tabsContainer || !contentContainer) {
                console.error("Task Navigation: Could not find containers");
                return;
            }

            // 4. Deactivate all siblings in THIS header group
            const allLinks = tabsContainer.querySelectorAll('.task-nav-link');
            allLinks.forEach(el => {
                el.classList.remove('active');
                el.setAttribute('aria-selected', 'false');
                // Also handle li parent if present
                if (el.parentElement.tagName === 'LI') {
                    el.parentElement.classList.remove('active');
                }
            });

            // 5. Activate clicked tab
            link.classList.add('active');
            link.setAttribute('aria-selected', 'true');
            if (link.parentElement.tagName === 'LI') {
                link.parentElement.classList.add('active');
            }

            // 6. Hide all panes in THIS content container
            const allPanes = contentContainer.querySelectorAll('.tab-pane');
            allPanes.forEach(pane => {
                pane.classList.remove('active');
                pane.classList.remove('show'); // BS5 fade support
                pane.style.display = 'none'; // Force hide
            });

            // 7. Show target pane
            targetPane.classList.add('active');
            targetPane.classList.add('show');
            targetPane.style.display = 'block'; // Force show
        }
    });
});
