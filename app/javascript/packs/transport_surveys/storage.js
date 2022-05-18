"use strict"

export const storage = ( function() {

  var local = {
    key: '',
    base_url: ''
  }

  // private methods
  function init(cfg) {
    local = cfg;
    return checkLocalStorage();
  }

  function checkLocalStorage() {
    try {
      return !!localStorage.getItem;
    } catch(e) {
      return false;
    }
  }

  function getAllResponses() {
    let responses = JSON.parse(localStorage.getItem(local.key)) || {};
    return responses;
  }

  function getResponses(date) {
    let responses = getAllResponses();
    responses[date] ||= []
    return responses[date];
  }

  function removeResponses(date) {
    let responses = getAllResponses();
    delete responses[date];
    localStorage.setItem(local.key, JSON.stringify( responses ));
  }

  function addResponse(date, response) {
    let responses = getAllResponses();
    responses[date] ||= [];
    responses[date].push(response);
    localStorage.setItem(local.key, JSON.stringify( responses ));
  }

  function syncResponses(date, notifier, location, redirect = false) {
    let responses = getResponses(date);
    if (responses.length > 0) {
      let url = local.base_url + "/" + date;
      let data = { transport_survey: { run_on: date, responses: responses }};
      $.ajax({
        url: url,
        type: 'PUT',
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: "text" })
      .done(function(data) {
        removeResponses(date);
        notifier(location, 'success', 'Responses saved!');
        if (redirect == true) {
          window.location.href = url;
        }
      })
      .fail(function() { notifier(location, 'danger', 'Error saving responses - please make sure you have a wifi connection before saving! '); });
    } else {
      notifier(location, 'warning', 'Nothing to save - please collect some survey responses first!');
    }
  }

  function getResponsesCount(date) {
    return getResponses(date).length;
  }

  // public methods
  return {
    init: init,
    removeResponses: removeResponses,
    getAllResponses: getAllResponses,
    getResponses: getResponses,
    addResponse: addResponse,
    syncResponses: syncResponses,
    getResponsesCount: getResponsesCount
  }

}());
