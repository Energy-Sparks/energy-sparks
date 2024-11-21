// Configures how sorting is used and works with cocoon to update position field
// after sorting

document.addEventListener('DOMContentLoaded', function () {
  function reindex(list) {
    let idx = 0;

    list.querySelectorAll('.nested-fields').forEach((item) => {
      const destroyField = item.querySelector('input[type="hidden"][name$="[_destroy]"]');
      const positionField = item.querySelector('input.position');

      if (!destroyField || destroyField.value !== '1') {
        positionField.value = idx++;
      }
    });
  }

  document.querySelectorAll('.sort-list').forEach((list) => {
    new Sortable(list, {
      animation: 150,
      selectedClass: 'bg-light',
      ghostClass: 'bg-light',
      handle: '.handle',
      filter: '.links',
      preventOnFilter: true,
      onMove: function (evt) {
        return !evt.related.classList.contains('links'); // Prevent dragging "links" elements
      }
    });

    // Update positions on initial load
    reindex(list);

    const observer = new MutationObserver(() => {
      reindex(list);
    });

    // Observe changes in the child list
    observer.observe(list, {
      childList: true,
      subtree: true,
      attributes: true
    });
  });
});