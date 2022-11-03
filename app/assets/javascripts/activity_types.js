"use strict"

$(document).ready(function() {
  $("form#activity_type_form .file").change(function(event){
    if (this.files) {
      var reader = new FileReader();
      reader.onload = function(e){
        $(".upload-preview img").attr("width", '300px');
        $(".upload-preview img").attr("src", e.target.result);
      };
      reader.readAsDataURL(this.files[0]);
    }
  });
});
