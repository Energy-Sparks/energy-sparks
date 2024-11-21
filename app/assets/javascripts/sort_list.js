document.addEventListener('DOMContentLoaded', function () {

  function reindex(list) {
    let idx = 0; // Start the index at 0 for visible elements

    list.querySelectorAll('input.position').forEach((input) => {

      // Find the hidden _destroy field for the current item
      const destroyField = input.closest('.cocooned-item').querySelector('input[type="hidden"][name$="[_destroy]"]');

      // Skip items marked for deletion (_destroy is set to "true")
      if (destroyField && destroyField.value === 'true') {
        return;
      }
      input.value = idx;
      idx++;
     });
  }

  document.querySelectorAll('.sort-list').forEach((list) => {
    // Initialize Sortable
    new Sortable(list, {
      animation: 150,
      selectedClass: 'bg-light',
      handle: '.handle',
      ghostClass: 'bg-light',
      filter: '.links',
      preventOnFilter: true,
      onEnd: function () {
        console.log('OnEnd triggered');
        reindex(list); // Update positions after sorting
      },
      onMove: function (evt) {
        return !evt.related.classList.contains('links'); // Prevent dragging "links" elements
      }
    });

    list.addEventListener('cocooned:after-remove', function () {
      requestAnimationFrame(() => {
        reindex(list);
      });
    });
  });
});
