"use strict"

$(document).ready(function() {

  $(document).on('click','.check-all',function(){
    $(this).closest('.form-group').find(':checkbox').prop('checked',this.checked);
  });

});
