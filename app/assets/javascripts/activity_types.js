$(document).on("turbolinks:load", function() {
  if ($(".activity-form").length) {
    var activity_types;
    activity_types = $('#activity_activity_type_id').html();

    function change() {
        var category, escaped_category, options;
        category = $('#activity_activity_category_id :selected').text();
        escaped_category = category.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
        options = $(activity_types).filter("optgroup[label=" + escaped_category + "]").html();
        if (options) {
            $('#activity_activity_type_id').html(options);
            $('#activity_activity_type_id').parent().show();
        } else {
            $('#activity_activity_type_id').empty();
            $('#activity_activity_type_id').parent().hide();
        }
    }

    change();
    $('#activity_activity_category_id').change(change);
  }
});
