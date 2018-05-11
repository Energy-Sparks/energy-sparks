$(document).on('turbolinks:load', () =>
  $("body").on("change", ".user-update", function(ev) {
    $(this.form).submit();
  })
);
