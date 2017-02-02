/**
 * Created by ldodds on 02/02/17.
 */
jQuery(function() {
    var activity_types;
    $('#activity_activity_type_id').parent().hide();
    activity_types = $('#activity_activity_type_id').html();
    console.log(activity_types);
    return $('#activity_activity_category_id').change(function() {
        var category, escaped_category, options;
        category = $('#activity_activity_category_id :selected').text();
        escaped_category = category.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
        options = $(activity_types).filter("optgroup[label=" + escaped_category + "]").html();
        console.log(options);
        if (options) {
            $('#activity_activity_type_id').html(options);
            return $('#activity_activity_type_id').parent().show();
        } else {
            $('#activity_activity_type_id').empty();
            return $('#activity_activity_type_id').parent().hide();
        }
    });
});
