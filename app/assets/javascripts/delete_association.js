document.addEventListener('DOMContentLoaded', function() {
  const deleteButtons = document.querySelectorAll('.delete-association-button');

  deleteButtons.forEach(function(button) {
    button.addEventListener('click', function(event) {
      event.preventDefault();
      const fields = button.closest('.nested-fields'); //
      if (fields) {
        const removeAssociationField = fields.querySelector('input[name$="[_delete]"]');

        if (removeAssociationField) {
          removeAssociationField.value = '1';
        }
        fields.style.display = 'none';
      }
    });
  });
});
