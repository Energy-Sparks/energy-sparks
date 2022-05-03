"use strict"

$(document).ready(function() {

	//* setup *//
	const config = {
		transport_fields: ['run_identifier', 'journey_minutes', 'passengers', 'transport_type_id', 'weather'],
		storage_key: 'es_ts_responses',
		run_on: $("#run_on").val(),
		url: $('#transport_survey').attr('action'),
		transport_types: loadTransportTypes('/transport_types.json')
	}

	setupSurvey();

  $('.start').on('click', start);
  $('.next').on('click', next);
  $('.sharing').on('click', sharing);
  $('.previous').on('click', previous);
  $('.confirm').on('click', confirm);
	$('.store').on('click', store);
  $('.next-pupil').on('click', nextPupil);

  $('#save-results').on('click', function(e) { $('#transport_survey').submit(); });
  $('#transport_survey').on('submit', function(e) { submit(e); });

  $('.responses-save').on('click', saveResponses);
  $('.responses-remove').on('click', removeResponses);

	//* methods *//

	/* onclick handlers */

  function resetSurvey() {

  }

  // Select weather card, hide weather panel and begin surveying
	function start() {
		selectCard(this);
		$('#setup').hide();
		$('#survey').show();
	}

	// Generic select card for current panel and move to next panel
	function next() {
		selectCard(this);
		nextPanel(this);
	}

	// Generic move to previous panel
	function previous() {
		previousPanel(this);
	}

	// Select card, set confirmation details for display on confirmation page and show confirmation panel
	function confirm() {
		selectCard(this);
		displaySelection();
		nextPanel(this);
	}

	// Show the carbon calculation, store confirmed results to localstorage and show carbon calculation panel
	function store() {
		displayCarbon();
		storeResponse();
		nextPanel(this);
	}

	// Reset survey for next pupil
	function nextPupil() {
		resetAllFields();
		resetAllCards();
		resetPanels();
		resetProgressBar();
	}

	// Save responses for a specific date to server
	function saveResponses() {
		let date = $(this).attr('data-date');
		syncResponses(config.url, date, false);
	}

	// Remove survey data from localstorage for given date
	function removeResponses() {
		let date = $(this).attr('data-date');
		removeStoredResponses(date);
	}

	/* end of onclick handlers */

	function setupSurvey() {
		resetProgressBar();
		setResponsesCount(getStoredResponses(config.run_on).length);
		setUnsavedResponses();
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
    addResponse(config.run_on, readResponse());
    setResponsesCount(getStoredResponses(config.run_on).length);
    setUnsavedResponses();
	}

	function getStoredResponses(date) {
		let responses = JSON.parse(localStorage.getItem(config.storage_key)) || {};
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
    localStorage.setItem(config.storage_key, JSON.stringify( responses ));
	}

	function addResponse(date, response) {
		let responses = getStoredResponses();
    responses[date] ||= [];
    responses[date].push(response);
    localStorage.setItem(config.storage_key, JSON.stringify( responses ));
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

  function loadTransportTypes(path) {
		let transport_types = {};
		$.ajax({
			url: path,
			type: 'GET',
			dataType: 'json',
			async: false,
		})
		.done(function(data) {
			transport_types = data;
		})
		.fail(function(err) {
			alert("Error loading data from server! " + err);
		});
		return transport_types;
	}

  function submit(event) {
		event.preventDefault(); // disable form submitting
		syncResponses(config.url, config.run_on, true);
  }

	function readResponse() {
		let response = {};
		for (const element of config.transport_fields) {
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

	function sharing() {
		let transport_type = config.transport_types[$("#transport_type_id").val()];
		if (transport_type.can_share) {
			$("fieldset#sharing .card").show();
		} else {
			$("fieldset#sharing .card").not(":first").hide();
			$("fieldset#sharing .card:first").show();
		}
	}

	function resetPanels() {
		$("fieldset").not(":first").hide();
		$("fieldset:first").show();
	}

	function resetProgressBar() {
		setProgressBar(window.step = 1);
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
		let transport_type = config.transport_types[response['transport_type_id']];

		$('#confirm-time div.option-content').text(response['journey_minutes']);
		$('#confirm-transport div.option-content').text(transport_type.image);
		$('#confirm-transport div.option-label').text(transport_type.name);
		$('#confirm-passengers div.option-content').text("🧍".repeat(response['passengers']));
	}

	function displayCarbon() {
		let response = readResponse();
		let transport_type = config.transport_types[response['transport_type_id']];

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
