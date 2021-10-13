"use strict"

$(document).ready(function() {

  if (typeof gtag !== 'undefined') {
    $(".activity-type-download-links a").click(function() {
      gtag('event', 'download-link', {
        'event_label': $(this).text(),
        'event_category': 'activity-type',
        'value': $(this).parents(".activity-type-download-links").data("event-value")
      });
    });

    $(".intervention-type-download-links a").click(function() {
      gtag('event', 'download-link', {
        'event_label': $(this).text(),
        'event_category': 'intervention-type',
        'value': $(this).parents(".intervention-type-download-links").data("event-value")
      });
    });

    $(".programme-type-download-links a").click(function() {
      gtag('event', 'download-link', {
        'event_label': 'Download',
        'event_category': 'programme-type',
        'value': $(this).parents(".programme-type-download-links").data("event-value")
      });
    });

    $(".resource-download-links a").click(function() {
      gtag('event', 'download-link', {
        'event_label': $(this).text(),
        'event_category': 'resource',
        'value': $(this).parents(".resource-download-links").data("event-value")
      });
    });

    $(".case-studies-download-links a").click(function() {
      gtag('event', 'download-link', {
        'event_label': 'Download',
        'event_category': 'case-study',
        'value': $(this).parents(".case-studies-download-links").data("event-value")
      });
    });
  }
});
