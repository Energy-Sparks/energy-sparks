document.addEventListener('DOMContentLoaded', function () {
  function updatePositions(list) {
    list.querySelectorAll('input.position').forEach((input, idx) => {
      input.value = idx;
    });
  }

  document.querySelectorAll('.sort-list').forEach((list) => {
    new Sortable(list, {
      animation: 150,
      multiDrag: true,
      ghostClass: 'bg-light'
    });

    // Update positions on initial load
    updatePositions(list);

    // Use MutationObserver to detect added or removed elements
    const observer = new MutationObserver(() => {
      updatePositions(list);
    });

    // Observe changes in the child list
    observer.observe(list, {
      childList: true,
    });
  });
});
