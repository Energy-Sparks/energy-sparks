"use strict"

export const storage = ( function() {

  var local = {
    key: '',
    baseUrl: '',
    notifications: ''
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

  function ajaxCall(url, data) {
    return $.ajax({
      url: url,
      type: 'PUT',
      data: JSON.stringify(data),
      contentType: "application/json; charset=utf-8",
      dataType: "text" });
  }

  function syncResponses(date, notifier) {
    let responses = getResponses(date);
    if (responses.length > 0) {
      let url = local.baseUrl + "/" + date;
      let data = { transport_survey: { run_on: date, responses: responses }};
      return ajaxCall(url, data)
      .done(function() {
        removeResponses(date);
        notifier('success', local.notifications.responses_saved);
      })
      .fail(function() {
        notifier('danger', local.notifications.no_connection);
      });
    } else {
      return { done: function() { notifier('warning', local.notifications.no_responses); } };
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
