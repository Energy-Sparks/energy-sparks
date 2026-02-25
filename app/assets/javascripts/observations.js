"use strict"

$(document).ready(function() {
  $('form.intervention').each(function(){
    var form = $(this);
    var notes = form.find('.form-group.observation_description');

    function attachNotes(){
      var checked = form.find('input[name="observation[intervention_type_id]"]:checked');
      notes.detach();
      if(checked.length){
        notes.appendTo(checked.parent());
      }
    }

    form.find('input[name="observation[intervention_type_id]"]').change(function(){
      attachNotes();
    });

    attachNotes();

  });

  function setConfirmation(){
    $('#intervention_date_confirmation').html($('#observation_at').val());
    $('#intervention_type_confirmation').html($('input[name="observation[intervention_type_id]"]:checked').next('label').html());
  }

  $('form.intervention input').on('change', setConfirmation);

});
