// NB: Not using cocooned inbuilt reindexing as couldn't get it working with Sortable

document.addEventListener('DOMContentLoaded', function () {
  function reindex(list) {
    let idx = 0;

    list.querySelectorAll('.cocooned-item').forEach((item) => {
      const destroyField = item.querySelector('input[type="hidden"][name$="[_destroy]"]');
      const positionField = item.querySelector('input.position');

      if (!destroyField || destroyField.value !== 'true') {
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
      onEnd: function () {
        reindex(list); // Update positions after sorting
      },
      onMove: function (evt) {
        return !evt.related.classList.contains('links'); // Prevent dragging "links" elements
      }
    });
    list.addEventListener('cocooned:after-remove', function () {
      reindex(list);
    });
  });
});
