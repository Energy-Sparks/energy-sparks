/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('Hello World from Webpacker')

require("trix")
require("@rails/actiontext")

import 'bootstrap/dist/js/bootstrap';

global.moment = require('moment');
//require("popper");
require('tempusdominus-bootstrap-4');

$(function () {
  console.log('Hello Jquery from Webpacker');
});
//require("babel-loader")
require("chart.js")
require("highcharts")

import Highcharts from 'highcharts';

require("chartkick")

//require("chartkick").use(require("highcharts"))

import '../src/activities.js';
import '../src/data_explorer.js';
import '../src/schools.js';
import '../src/users.js';
import '../src/calendar_year_view.js';
import '../src/common_chart_options.js';
import '../src/analysis.js';
import '../src/simulator.js';
import '../src/alert_reports.js';

import '../src/content.js';

import '../src/aggregated_meter_collection.js';
import '../src/date_pickers.js';



//= require highcharts
//= require highcharts-modules/exporting
//= require highcharts-modules/offline-exporting
//= require chartkick

// This is used (handlebars) but slight overkill I think
//= require handlebars

//= require activities
//= require data_explorer
//= require schools
//= require users

// from https://github.com/neivars/bootstrap-year-calendar
//= require bootstrap-year-calendar
//= require calendar_year_view

//= require common_chart_options
//= require analysis
//= require simulator

//= require moment
//= require tempusdominus-bootstrap-4.js

//= require alert_reports
//= require content

//= require aggregated_meter_collection
//= require date_pickers


