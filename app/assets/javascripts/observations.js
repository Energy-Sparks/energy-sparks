"use strict"

$(document).ready(function() {
 $('input.temperature').each(function() {
    $(this).on('change', function() {
      var temperatureValue = $(this).val();
      $(this).next('.temperature-tooltip').remove();

      if (temperatureValue.length) {
        if (temperatureValue < 18) {
          var tooltipClass = 'invalid-tooltip bg-primary';
          var tooltipContent = "This may be a little chilly. Could your school add more roof and wall insulation to help keep the school warmer without using more energy?";
        } else if (temperatureValue >= 18 && temperatureValue < 19) {
          var tooltipClass = 'valid-tooltip';
          var tooltipContent = "This is a good temperature for energy efficient schools. Well done!";
        } else if (temperatureValue >= 19) {
          var tooltipClass = 'invalid-tooltip';
          var tooltipContent = "Energy Sparks recommends classroom temperatures are no higher than 18C. Try turning down your heating to save energy and money.";
        }

        $(this).after('<div class="' + tooltipClass + ' temperature-tooltip">' + tooltipContent + '</div>');

        $('.invalid-tooltip').show();
        $('.valid-tooltip').show();
      }
    });
  });

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

});
