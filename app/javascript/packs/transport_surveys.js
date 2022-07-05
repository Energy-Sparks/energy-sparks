"use strict"

import { storage } from './transport_surveys/storage';
import { carbon } from './transport_surveys/carbon';
import { notifier } from './transport_surveys/notifier';
import { pluralise, nice_date } from './transport_surveys/helpers';
import * as handlebarsHelpers from './transport_surveys/handlebars_helpers';

$(document).ready(function() {

  const config = {
    transport_fields: ['run_identifier', 'journey_minutes', 'passengers', 'transport_type_id', 'weather'],
    storage_key: 'es_ts_responses',
    run_on: $("#run_on").val(),
    base_url: $('#transport_survey').attr('action'),
    transport_types: loadTransportTypes('/transport_types.json'),
    passenger_symbol: $("#passenger_symbol").val(),
    rates: $('#rates').data()
  }

  carbon.init(config.rates);

  if (storage.init({key: config.storage_key, base_url: config.base_url})) {
    setupSurvey();

    /* onclick bindings */
    $('.start').on('click', start);
    $('.next').on('click', next);
    $('.previous').on('click', previous);
    $('.transport').on('click', transport);
    $('.previous-transport').on('click', previousTransport);
    $('.confirm').on('click', confirm);
    $('.store').on('click', store);
    $('.next-pupil').on('click', nextSurveyRun);
    $('#save-results').on('click', finishAndSave);

  } else {
    fatalError("Your browser does not support a feature required by our survey tool. Either upgrade your browser, use an alternative or enable 'localStorage'.");
  }

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

  // Move back two panels & clear previous cards
  function previousTransport() {
    let transport_type = config.transport_types[$('#transport_type_id').val()];
    if(transport_type.can_share == true) {
      previousPanel(this);
    } else {
      let panel = $(this).closest('.panel').prev();
      clearCards(panel);
      previousPanel(this, 2);
    }
  }

  function transport() {
    selectCard(this);
    let transport_type = config.transport_types[$('#transport_type_id').val()];

    if(transport_type.can_share == true) {
      $('#transport_type_name').text(transport_type.image + " " + transport_type.name);
      nextPanel(this);
    } else {
      // skip sharing panel if cannot share selected transport type
      let panel = $(this).closest('.panel').next();
      clearCards(panel);
      displaySelection();
      nextPanel(this, 2);
    }
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
    enableFinishAndSaveButton();
  }

  // Reset survey for next pupil
  function nextSurveyRun() {
    resetSurveyFields();
    resetSurveyCards();
    resetSurveyPanels();
    setProgressBar(window.step = 1);
    disableFinishAndSaveButton();
  }

  // Save responses and redirect to results page
  function finishAndSave() {
    storage.syncResponses(config.run_on, notifier.app).done( function() {
      let button = $("[data-date='" + config.run_on + "']");
      button.closest('.alert').hide();
      setResponsesCount(0);
      window.location.href = config.base_url + "/" + config.run_on;
    });
  }

  // Save responses for a specific date to server
  function saveResponses() {
    let button = $(this);
    let date = button.attr('data-date');
    let count = storage.getResponsesCount(date);
    if (window.confirm(`Are you sure you want to save ${count} unsaved ${pluralise("response", count)} from ${nice_date(date)}?`)) {
      storage.syncResponses(date, notifier.page).done( function() {
        button.closest('.alert').hide();
        if (date == config.run_on) {
          fullSurveyReset();
          $("#survey_nav").show();
        }
      });
    }
  }

  // Remove survey data from localstorage for given date
  function deleteResponses() {
    let button = $(this);
    let date = button.attr('data-date');
    let count = storage.getResponsesCount(date);
    if (window.confirm(`Are you sure you want to remove ${count} unsaved ${pluralise("response", count)} from ${nice_date(date)}?`)) {
      storage.removeResponses(date);
      notifier.page('success', 'Unsaved responses removed!');
      button.closest('.alert').hide();
      if (date == config.run_on) fullSurveyReset();
    }
  }

  /* end of onclick handlers */

  function fatalError(message) {
    notifier.page('danger', message, false)
    hideAppButton();
  }

  function hideAppButton() {
    $('.jsonly').hide();
  }

  function fullSurveyReset() {
    setResponsesCount(0);
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
      fatalError("Error loading data from server! Please reload the page and try again.");
    });
    return transport_types;
  }

  function readResponse() {
    let response = {};
    for (const element of config.transport_fields) {
      response[element] = $("#" + element).val();
    }
    response['passengers'] ||= 1;
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

  function resetSurveyPanels() {
    $("fieldset").not(":first").hide();
    $("fieldset:first").show();
  }

  function disableFinishAndSaveButton() {
    $('#save-results').prop("disabled", true);
    let badge = $('#unsaved-responses-count');
    badge.removeClass("badge-primary");
    badge.addClass("badge-light");
  }

  function enableFinishAndSaveButton() {
    $('#save-results').prop("disabled", false);
    let badge = $('#unsaved-responses-count');
    badge.removeClass("badge-light");
    badge.addClass("badge-primary");
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

  function clearCards(panel) {
    resetCards(panel.find('.card'));
    panel.find('input[type="hidden"].selected').val("");
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

  function nextPanel(current, increment = 1) {
    let fieldset = $(current).closest('fieldset');
    fieldset.nextAll().eq(increment-1).show();
    fieldset.hide();
    setProgressBar(window.step+=increment);
  }

  function previousPanel(current, decrement = 1) {
    let fieldset = $(current).closest('fieldset');
    fieldset.prevAll().eq(decrement-1).show();
    fieldset.hide();
    setProgressBar(window.step-=decrement);
  }

  function displaySelection() {
    let response = readResponse();
    let transport_type = config.transport_types[response['transport_type_id']];

    $('#confirm-time div.option-content').text(response['journey_minutes']);
    $('#confirm-transport div.option-content').text(transport_type.image);
    $('#confirm-transport div.option-label').text(transport_type.name);

    if (transport_type.can_share) {
      $('#confirm-passengers div.option-content').text(config.passenger_symbol.repeat(response['passengers']));
      $('#confirm-passengers div.option-label').text((response['passengers'] > 1 ? response['passengers'] + " pupils" : "Just me"));
      $('#confirm-passengers').show();
    } else {
      $('#confirm-passengers').hide();
    }
  }

  function displayCarbon() {
    let response = readResponse();
    let transport_type = config.transport_types[response['transport_type_id']];

    let co2 = carbon.calc(transport_type, response['journey_minutes'], response['passengers']);
    let nice_carbon = co2 === 0 ? '0' : co2.toFixed(3)

    $('#display-time').text(response['journey_minutes']);
    $('#display-transport').text(transport_type.image + " " + transport_type.name);
    $('#display-passengers').text(response['passengers'] + " " + pluralise("pupil", response['passengers']));
    $('#display-carbon').text(nice_carbon + "kg");
    $('#display-carbon-equivalent').text(carbon.equivalence(co2));
  }

});
