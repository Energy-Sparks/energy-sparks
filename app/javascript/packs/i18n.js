"use strict"

import { I18n } from "i18n-js";
import translations from "../locales.json";

const i18n = new I18n(translations);

$(document).ready(function() {
  i18n.fallbacks = true;
  i18n.locale = $('body').data('locale');
  console.log(i18n.t("schools.live_data.normal_consumption", {power: 123}))
  window.i18n = i18n
});
