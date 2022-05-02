"use strict"

$(document).ready(function() {

	//* setup *//

	const transport_fields = ['run_identifier', 'journey_minutes', 'passengers', 'transport_type_id', 'weather'];
	const storage_key = 'es_ts_responses';
	const run_on = $("#run_on").val();
	const run_identifier = $("#run_identifier").val();
	const action = $('#transport_survey').attr('action');

	var transport_types;
	loadTransportTypes();

	resetProgressBar();
  setResponsesCount(getStoredResponses(run_on).length);
  setUnsavedResponses();

  $('.start').on('click', start);
  $('.next').on('click', next);
  $('.previous').on('click', previous);
  $('.confirm').on('click', confirm);
	$('.store').on('click', store);
  $('.next-pupil').on('click', nextPupil);

  $('#save-results').on('click', function(e) { $('#transport_survey').submit(); });
  $('#transport_survey').on('submit', function(e) { submit(e); });

  $('.responses-save').on('click', saveResponses);
  $('.responses-remove').on('click', removeResponses);

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

	function confirm() {
		selectCard(this);
		displaySelection();
		nextPanel(this);
	}

	function store() {
		displayCarbon();
		storeResponse();
		nextPanel(this);
	}

	function nextPupil() {
		resetAllFields();
		resetAllCards();
		resetPanels();
		resetProgressBar();
	}

	function saveResponses() {
		let date = $(this).attr('data-date');
		syncResponses(action, date, false);
	}

	function removeResponses() {
		let date = $(this).attr('data-date');
		removeStoredResponses(date);
	}

	function setResponsesCount(value) {
		$('#unsaved-responses-count').text(value);
	}

	function setUnsavedResponses() {
		let responses = getStoredResponses();
		let html = HandlebarsTemplates['transport_surveys']({responses: responses});
		$('#unsaved-responses').html(html);
	}

	function storeResponse() {
    addResponse(run_on, readResponse());
    setResponsesCount(getStoredResponses(run_on).length);
    setUnsavedResponses();
	}

	function getStoredResponses(date) {
		let responses = JSON.parse(localStorage.getItem(storage_key)) || {};
		if (date) {
			responses[date] ||= []
			return responses[date];
		} else {
			return responses;
		}
	}

	function removeStoredResponses(date) {
		let responses = getStoredResponses();
		delete responses[date];
    localStorage.setItem(storage_key, JSON.stringify( responses ));
	}

	function addResponse(date, response) {
		let responses = getStoredResponses();
    responses[date] ||= [];
    responses[date].push(response);
    localStorage.setItem(storage_key, JSON.stringify( responses ));
	}

	function syncResponses(baseurl, date, redirect = true) {
		let responses = getStoredResponses(date);
		if (responses) {
			let url = baseurl + "/" + date;
			let data = { transport_survey: { run_on: date, responses: responses }};
			$.ajax({
        url: url,
        type: 'PUT',
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: "text" })
			.done(function(data) {
				removeStoredResponses(date);
				if (redirect) {
					window.location.href = url;
				}	else {
					alert("Responses saved!");
				}
			})
			.fail(function(err) { alert("Error saving responses, please try again! " + err); });
		} else {
			alert("Nothing to save - please collect some survey responses first!");
		}
	}

  function submit(event) {
		event.preventDefault(); // disable form submitting
		syncResponses(action, run_on, true);
  }

	function readResponse() {
		let response = {};
		for (const element of transport_fields) {
			response[element] = $("#" + element).val();
		}
		response['surveyed_at'] = new Date().toISOString();
		return response;
	}

	function resetAllFields() {
		$('#transport_survey #survey').find('input[type="hidden"].selected').val("");
	}

	function resetCards(cards) {
		cards.removeClass('bg-primary');
		cards.addClass('bg-light');
	}

	function highlightCard(card) {
		card.removeClass('bg-light');
		card.addClass('bg-primary');
	}

	function resetAllCards() {
		let cards = $('#transport_survey .panel').find('.card');
		resetCards(cards);
	}

	function resetPanels() {
		$("fieldset").not(":first").hide();
		$("fieldset:first").show();
	}

  function loadTransportTypes() {
		$.getJSON( "/transport_types.json", function( data ) {
			transport_types = data;
		}); // this needs to be more robust
	}

	function resetProgressBar() {
		window.step = 1
		setProgressBar(window.step);
	}

	function setProgressBar(step){
		let percent = parseFloat(100 / $("fieldset").length) * step;
		percent = percent.toFixed();
		$(".progress-bar").css("width",percent+"%").html(percent+"%");
		setTab(step);
	}

	function setTab(step) {
		let tabs = $("#survey a.nav-link");
		tabs.removeClass('active');
		$(tabs[step-1]).addClass('active');
	}

	function selectCard(current) {
		let panel = $(current).closest('.panel');
		resetCards(panel.find('.card'));

		let card = $(current).closest('div.card');
		highlightCard(card);

		let selected_value = card.find('input[type="hidden"].option').val();

		// change the value in the hidden field
		panel.find('input[type="hidden"].selected').val(selected_value);
	}

	function nextPanel(current) {
		let fieldset = $(current).closest('fieldset');
		fieldset.next().show();
		fieldset.hide();
		setProgressBar(++window.step);
	}

	function previousPanel(current) {
		let fieldset = $(current).closest('fieldset');
		fieldset.prev().show();
		fieldset.hide();
		setProgressBar(--window.step);
	}

	function displaySelection() {
		let response = readResponse();
		let transport_type = transport_types[response['transport_type_id']];

		$('#confirm-time div.option-content').text(response['journey_minutes']);
		$('#confirm-transport div.option-content').text(transport_type.image);
		$('#confirm-transport div.option-label').text(transport_type.name);
		$('#confirm-passengers div.option-content').text("🧍".repeat(response['passengers']));
	}

	function displayCarbon() {
		let response = readResponse();
		let transport_type = transport_types[response['transport_type_id']];

		let carbon = carbonCalc(transport_type, response['journey_minutes'], response['passengers']);
		let nice_carbon = carbon === 0 ? '0' : carbon.toFixed(3)
		let fun_weight = funWeight(carbon);

		$('#display-time').text(response['journey_minutes']);
		$('#display-transport').text(transport_type.image + " " + transport_type.name);
		$('#display-passengers').text(response['passengers']);
		$('#display-carbon').text(nice_carbon + "kg");
		$('#display-carbon-equivalent').text(funWeight(carbon));
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
