// Inspired by https://www.sitepoint.com/quick-tip-persist-checkbox-checked-state-after-page-reload/

$(document).on("turbolinks:load", function() {

    var formValues = JSON.parse(localStorage.getItem('formValues')) || {};
    var $checkboxes = $("#checkbox-container :checkbox");
    var $button = $("#check_all_filters");

    function allChecked() {
        return $checkboxes.length === $checkboxes.filter(":checked").length;
    }

    function updateButtonStatus() {
        $button.text(allChecked() ? "Uncheck all" : "Check all");
    }

    function handleButtonClick() {
        $checkboxes.prop("checked", allChecked() ? false : true)
    }

    function updateStorage() {
        $checkboxes.each(function() {
            formValues[this.id] = this.checked;
        });

        formValues["buttonText"] = $button.text();
        localStorage.setItem("formValues", JSON.stringify(formValues));
    }

    $button.on("click", function() {
        handleButtonClick();
        updateButtonStatus();
        updateStorage();
    });

    $checkboxes.on("change", function() {
        updateButtonStatus();
        updateStorage();
    });

    // On page load
    $.each(formValues, function(key, value) {
        $("#" + key).prop('checked', value);
    });

    $button.text(formValues["buttonText"]);
});