"use strict"

import { storage } from './transport_surveys/storage';
import { carbonCalc, carbonExamples, funWeight } from './transport_surveys/carbon'

$(document).ready(function() {

	const config = {
		transport_fields: ['run_identifier', 'journey_minutes', 'passengers', 'transport_type_id', 'weather'],
		storage_key: 'es_ts_responses',
		run_on: $("#run_on").val(),
		base_url: $('#transport_survey').attr('action'),
		transport_types: loadTransportTypes('/transport_types.json')
	}

	storage.init({key: config.storage_key, base_url: config.base_url});

	setupSurvey();

	/* onclick bindings */

  $('.start').on('click', start);
  $('.next').on('click', next);
  $('.sharing').on('click', sharing);
  $('.previous').on('click', previous);
  $('.confirm').on('click', confirm);
	$('.store').on('click', store);
  $('.next-pupil').on('click', nextSurveyRun);
  $('#reset').on('click', fullReset);

  $('#save-results').on('click', function(e) { $('#transport_survey').submit(); });
  $('#transport_survey').on('submit', function(e) { submit(e); });

  $('.responses-save').on('click', saveResponses);
  $('.responses-remove').on('click', deleteResponses);

	/* onclick handlers */

  // Select weather card, hide weather panel and begin surveying
	function start() {
		selectCard(this);
		showSurvey();
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
	function nextSurveyRun() {
		resetSurveyFields();
		resetSurveyCards();
		resetSurveyPanels();
		setProgressBar(window.step = 1);
	}

  function submit(event) {
		event.preventDefault(); // disable form submitting

		storage.syncResponses(config.run_on, true);
	}

	function dismissAlert(current) {
		$(current).closest('.alert').hide;
	}

	// Save responses for a specific date to server
	function saveResponses() {
		let date = $(this).attr('data-date');
		storage.syncResponses(date, false);

		if (date == config.run_on) {
			setResponsesCount(0);
		}
	}

	// Remove survey data from localstorage for given date
	function deleteResponses() {
		let date = $(this).attr('data-date');
		if (window.confirm('Are you sure you want to remove ' + storage.getResponsesCount(date) + ' unsaved result(s) from ' + date + '?')) {
			storage.removeResponses(date);
			dismissAlert(this);

			if (date == config.run_on) {
				fullSurveyReset();
			}
		}
	}

	// Remove survey data for current date and reset survey form
  function fullReset() {
		if (window.confirm('Are you sure you want to reset and remove ' + storage.getResponsesCount(config.run_on) + ' unsaved result(s) from ' + config.run_on + '?')) {
			storage.removeResponses(config.run_on);
			fullSurveyReset();
		}
  }

	/* end of onclick handlers */

  function fullSurveyReset() {
		updateResponsesCounts();
		resetSetupFields();
		resetSetupCards();
		nextSurveyRun();
		showSetup();
  }

	function setupSurvey() {
		setProgressBar(window.step = 1)
		updateResponsesCounts();
	}

	function showSetup() {
		$('#setup').show();
		$('#survey').hide();
	}

	function showSurvey() {
		$('#setup').hide();
		$('#survey').show();
	}

	function setResponsesCount(value) {
		$('#unsaved-responses-count').text(value);
	}

	function setUnsavedResponses() {
		let html = HandlebarsTemplates['transport_surveys']({responses: storage.getAllResponses()});
		$('#unsaved-responses').html(html);
	  $('.responses-save').on('click', saveResponses);
	  $('.responses-remove').on('click', deleteResponses);
	}

	function updateResponsesCounts() {
		setResponsesCount(storage.getResponsesCount(config.run_on));
    setUnsavedResponses();
	}

	function storeResponse() {
		storage.addResponse(config.run_on, readResponse());
		updateResponsesCounts();
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

	function readResponse() {
		let response = {};
		for (const element of config.transport_fields) {
			response[element] = $("#" + element).val();
		}
		response['surveyed_at'] = new Date().toISOString();
		return response;
	}

	function resetSetupFields() {
		$('#transport_survey #setup').find('input[type="hidden"].selected').val("");
	}

	function resetSetupCards() {
		let cards = $('#transport_survey #setup').find('.card');
		resetCards(cards);
	}

	function resetSurveyFields() {
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

	function resetSurveyCards() {
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

	function resetSurveyPanels() {
		$("fieldset").not(":first").hide();
		$("fieldset:first").show();
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

});
