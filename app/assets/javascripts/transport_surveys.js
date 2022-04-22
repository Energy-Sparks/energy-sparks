"use strict"

$(document).ready(function() {

	var fieldset_count = 1;

	setProgressBar(fieldset_count);

	function setProgressBar(step){
		var percent = parseFloat(100 / $("fieldset").length) * step;
		percent = percent.toFixed();
		$(".progress-bar").css("width",percent+"%").html(percent+"%");
	}

	$('.card').click(function() {
		var panel = $(this).closest('.panel');

		// remove highlight from other cards
		panel.find('.card').removeClass('bg-primary');
		panel.find('.card').addClass('bg-light');

		// highlight current card
		$(this).removeClass('bg-light');
		$(this).addClass('bg-primary');
		var selected_value = $(this).find('input[type="hidden"].option').val();

		// change the value in the hidden field
		panel.find('input[type="hidden"].selected').val(selected_value);
	});

	$(".start").click(function() {
		$('#weather').hide();
		$('#survey').show();
	});

	$(".next").click(function(){
		var fieldset = $(this).closest('fieldset');
		fieldset.next().show();
		fieldset.hide();
		setProgressBar(++fieldset_count);
	});

	$(".previous").click(function(){
		var fieldset = $(this).closest('fieldset');
		fieldset.prev().show();
		fieldset.hide();
		setProgressBar(--fieldset_count);
	});

  // Handle form submit
	$( "#transport_survey" ).submit(function(event) {
		var error_message = '';

		// Display error if any else submit form
		if(error_message) {
			$('.alert-success').removeClass('hide').html(error_message);
			return false;
		} else {
			alert("ok");
			return true;
		}
  });
});
