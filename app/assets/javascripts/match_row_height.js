/**
 * This ensures that all elements with the class `match-row-height` inside the same
 * `.row` container have the same height as the tallest element.
 *
 * The function is automatically triggered on the `load` and `resize` events of the window.
*/

function matchHeightsInRows() {
  document.querySelectorAll('.row').forEach(row => {
    const items = row.querySelectorAll('.match-row-height');
    if (items.length === 0) return;

    let maxHeight = 0;

    // Reset and measure
    items.forEach(el => {
      el.style.height = 'auto';
      maxHeight = Math.max(maxHeight, el.offsetHeight);
    });

    // Apply tallest height
    items.forEach(el => el.style.height = maxHeight + 'px');
  });
}

window.addEventListener('load', matchHeightsInRows);
window.addEventListener('resize', matchHeightsInRows);
