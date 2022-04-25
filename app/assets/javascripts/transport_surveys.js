"use strict"

$(document).ready(function() {

	//* setup *//

	var transport_types;
	loadTransportTypes();

	var fieldset_count = 1;
	setProgressBar(fieldset_count);

  $('.start').on('click', start);
  $('.next').on('click', next);
  $('.previous').on('click', previous);
  $('.last').on('click', last);

  $('#transport_survey').on('submit', submit);

	//* methods *//

	function start() {
		selectCard(this);
		$('#setup').hide();
		$('#survey').show();
	}

	function next() {
		selectCard(this);
		nextPanel(this);
	}

	function previous() {
		previousPanel(this);
	}

	function last() {
		selectCard(this);
		nextPanel(this);
		displayCarbon();
	}

  function loadTransportTypes() {
		$.getJSON( "/transport_types.json", function( data ) {
			transport_types = data;
		}); // this needs to be more robust
	}

	function setProgressBar(step){
		let percent = parseFloat(100 / $("fieldset").length) * step;
		percent = percent.toFixed();
		$(".progress-bar").css("width",percent+"%").html(percent+"%");
	}

	function selectCard(current) {
		let panel = $(current).closest('.panel');

		// remove highlight from other cards in panel
		panel.find('.card').removeClass('bg-primary');
		panel.find('.card').addClass('bg-light');

		// highlight current card
		let card = $(current).closest('div.card');
		card.removeClass('bg-light');
		card.addClass('bg-primary');

		let selected_value = card.find('input[type="hidden"].option').val();

		// change the value in the hidden field
		panel.find('input[type="hidden"].selected').val(selected_value);
	}

	function nextPanel(current) {
		let fieldset = $(current).closest('fieldset');
		fieldset.next().show();
		fieldset.hide();
		setProgressBar(++fieldset_count);
	}

	function previousPanel(current) {
		let fieldset = $(current).closest('fieldset');
		fieldset.prev().show();
		fieldset.hide();
		setProgressBar(--fieldset_count);
	}

	function displayCarbon() {
		var journey_minutes = $('#journey_minutes').val();
		var passengers = $('#passengers').val();
		var transport_type_id = $('#transport_type_id').val();
		var weather = $('#weather').val();

		carbon = carbonCalc(transport_types[transport_type_id], journey_minutes, passengers);

		niceCarbon = carbon === 0 ? '0' : carbon.toFixed(3)
		fun_weight = funWeight(carbon);

		$('#display-time').text(journey_minutes);
		$('#display-transport').text(transport_types[transport_type_id].image + " " + transport_types[transport_type_id].name);
		$('#display-passengers').text(passengers);

		$('#display-carbon').text(niceCarbon + "kg");
		$('#display-carbon-equivalent').text(funWeight(carbon));

	}

  function submit() {
		let error_message = '';

		// Display error if any else submit form
		if(error_message) {
			$('.alert-success').removeClass('hide').html(error_message);
			return false;
		} else {
			alert("submitting");
			return true;
		}
  }

	// logic mostly lifted from the old app.

  function parkAndStrideTimeMins(timeMins) {
		// take 15 mins off a park and stride journey
		return (timeMins > 15 ? timeMins - 15 : 0);
  }

	function carbonCalc(transport, timeMins, passengers) {
		if (transport) {
			timeMins = transport.image === '🚶🚘' ? parkAndStrideTimeMins : timeMins; // need a better way of identifying park and stride!
			return (((transport.speed_km_per_hour * timeMins) / 60) * transport.kg_co2e_per_km) / passengers ;
		} else {
			return 0;
		}
	}

	const carbonExamples = [
		{
			name: 'Tree',
	    emoji: '🌳',
	    equivalentStatement: function(carbonKgs) {
	      const treeAbsorbsionKgPerDay = 0.06;
	      let days = Math.round(carbonKgs / treeAbsorbsionKgPerDay);
				return `1 tree would absorb this amount of CO2 in ${days} day(s) 🌳!`;
			}
	  }, {
			name: 'TV',
	    emoji: '📺',
	    equivalentStatement: function(carbonKgs) {
	      const tvKgPerHour = 0.008;
	      let hours = Math.round(carbonKgs / tvKgPerHour);
	      return `That's the same as ${hours} hour${hours === 1 ? '' : 's'} of TV 📺!`;
			},
		}, {
	    name: 'Gaming',
	    emoji: '🎮',
	    equivalentStatement: function(carbonKgs) {
	      const gamingKgPerHour = 0.008;
	      let hours = Math.round(carbonKgs / gamingKgPerHour);
	      return `That's the same as playing ${hours} hour${hours === 1 ? '' : 's'} of computer games 🎮!`;
			},
		}, {
	    name: 'Meat dinners',
	    emoji: '🍲',
	    equivalentStatement: function(carbonKgs) {
	      const kgPerMeatDinner = 1;
	      let meatDinners = Math.round(carbonKgs / kgPerMeatDinner);
	      return `That's the same as ${meatDinners} meat dinner${meatDinners === 1 ? '' : 's'} 🍲!`;
			},
	  }, {
	    name: 'Veggie dinners',
	    emoji: '🥗',
	    equivalentStatement: function(carbonKgs) {
	      const kgPerVeggieDinner = 0.5;
	      let veggieDinners = Math.round(carbonKgs / kgPerVeggieDinner);
	      return `That's the same as ${veggieDinners} veggie dinner${veggieDinners === 1 ? '' : 's'} 🥗!`;
			},
	  },
	 ];

	const funWeight = function(carbonKgs) {
	  if (carbonKgs === 0) {
	    return "That's Carbon Neutral 🌳!";
	  } else {
	    let randomEquivalent = carbonExamples[Math.floor(Math.random() * carbonExamples.length)];
	    return randomEquivalent.equivalentStatement(carbonKgs);
	  }
	};
});
