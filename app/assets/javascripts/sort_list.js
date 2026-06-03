// Configures how sorting is used and updates position fields before form submission

document.addEventListener('DOMContentLoaded', function () {
  function reindex(list) {
    let idx = 0;
    list.querySelectorAll('.nested-fields').forEach((item) => {
      const destroyField = item.querySelector('input[type="hidden"][name$="[_destroy]"], input[type="hidden"][name$="[_delete]"]');
      const positionField = item.querySelector('input.position');

      if (destroyField.value !== 'true') {
        positionField.value = idx++;
      }
    });
  }

  const sortLists = document.querySelectorAll('.sort-list');
  if (sortLists.length === 0) {
    return;
  }

  // Initialize Sortable for each sort-list within the form
  sortLists.forEach((list) => {
    new Sortable(list, {
      animation: 150,
      ghostClass: 'sortable-hide',
      handle: '.handle',
      filter: '.links',
      preventOnFilter: true,
      onMove: function (evt) {
        return !evt.related.classList.contains('links'); // Prevent dragging "links" elements
      }
    });
  });

  const form = document.querySelector('form');

  form.addEventListener('submit', function(e) {
    // Reindex each sort-list before submitting the form
    form.querySelectorAll('.sort-list').forEach((list) => {
      reindex(list);
    });
  });
});
