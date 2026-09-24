function showModal(id) {
  const el = document.getElementById(id);

  if (window.bootstrap?.Modal) {
    // Bootstrap 5
    bootstrap.Modal.getOrCreateInstance(el).show();
  } else if (window.jQuery?.fn?.modal) {
    // Bootstrap 4
    $(el).modal('show');
  }
}
