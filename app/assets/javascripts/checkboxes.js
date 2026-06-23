"use strict"

$(document).ready(function() {

  $(document).on('click','.check-all',function(){
    $(this).closest('.form-group').find(':checkbox').prop('checked',this.checked);
  });

  $(document).on('click','.must-check',function(){
    $(this).closest('form').find(':submit').prop('disabled', !this.checked);
  });

  if ($("form .must-check").length > 0) {
    $("form .must-check").closest('form').find(':submit').prop('disabled', true);
  }

  $(document).on('click','.disable-attributes',function(){
    $(this).closest('.form-group').find(':checkbox').prop('checked',this.checked);
    $(this).closest('.form-group').find('select').prop('disabled', this.checked);
    $(this).closest('.form-group').find('input').prop('disabled', this.checked);
    $(this).prop('disabled', false);
    $(this).next('.disabled-label').toggle();
  });
});

function updateSubmitState(form) {
  const anyChecked = form.querySelector('input[type="checkbox"]:checked') !== null;

  form.querySelectorAll('input[type="submit"]').forEach(btn => {
    btn.disabled = !anyChecked;
  });
}

document.addEventListener('click', (e) => {
  if (e.target.matches('.check-all-form')) {
    const form = e.target.closest('form');
    if (form) {
      form.querySelectorAll('input[type="checkbox"]').forEach(cb => {
        cb.checked = e.target.checked;
      });
      updateSubmitState(form);
    }
    return;
  }

  if (e.target.matches('input.allow-submit')) {
    const form = e.target.closest('form');
    if (form) updateSubmitState(form);
  }
});

