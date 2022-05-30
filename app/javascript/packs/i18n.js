"use strict"

console.log('Hello World from i18n')

import { I18n } from "i18n-js";
import translations from "../locales.json";

const i18n = new I18n(translations);

$(document).ready(function() {

  i18n.locale = "cy";
  console.log(i18n.t("more_information"))
  console.log(i18n.t("home.enrol_your_school"))

});
