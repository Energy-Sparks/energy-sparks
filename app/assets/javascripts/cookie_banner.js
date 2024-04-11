"use strict"

const COOKIE_BANNER_ID = 'cookie-banner';
const COOKIE_PREFERENCE_NAME = 'cookie_preference';
const COOKIE_PREFERENCE_BTNS = 'cookie-preference-buttons';
const COOKIE_PREFERENCE_ACCEPT_BTN = 'cookie-preference-accept';
const COOKIE_PREFERENCE_REJECT_BTN = 'cookie-preference-reject';
const COOKIE_PREFERENCE_ACCEPT_MSG = 'cookie-preference-accepted-message';
const COOKIE_PREFERENCE_REJECT_MSG = 'cookie-preference-rejected-message';
const ACCEPTED = 'Accepted';
const REJECTED = 'Rejected';

function initializeCookieBanner() {
 let cookieStatus = Cookies.get(COOKIE_PREFERENCE_NAME);
 if(cookieStatus === undefined) {
   // user has not accepted or refused; or preference cookie expired
   showCookieBanner();
 } else if (cookieStatus == ACCEPTED) {
   // preference cookie is current and user has accepted
   setAnalyticsConsent('granted');
 } else {
   // preference cookie is current and user has refused
   setAnalyticsConsent('denied');
 }
 let preferenceButtons = document.getElementById(COOKIE_PREFERENCE_BTNS);
 if(preferenceButtons != null) {
   setPreferenceButtonState();
 }
}

function showCookieBanner() {
 let cookieBanner = document.getElementById(COOKIE_BANNER_ID);
 cookieBanner.style.display = 'block';
 window.acceptCookies = acceptCookies;
 window.rejectCookies = rejectCookies;
}

function hideBanner() {
  let cookieBanner = document.getElementById(COOKIE_BANNER_ID);
  cookieBanner.style.display = 'none';
}

function setPreferenceCookie(status) {
  Cookies.remove(COOKIE_PREFERENCE_NAME);
  Cookies.set(COOKIE_PREFERENCE_NAME, status, { expires: 365 });
}

function acceptCookies() {
 setPreferenceCookie(ACCEPTED);
 setAnalyticsConsent('granted');
 hideBanner();
}

function rejectCookies() {
 setPreferenceCookie(REJECTED);
 setAnalyticsConsent('denied');
 hideBanner();
}

function setAnalyticsConsent(permission) {
  if (typeof gtag !== 'undefined') {
    gtag('consent', 'update', {
     'analytics_storage': permission
   });
  }
}

function updateCookiePreference(status) {
  hideBanner();
  setPreferenceCookie(status);
  let accept = document.getElementById(COOKIE_PREFERENCE_ACCEPT_BTN);
  let reject = document.getElementById(COOKIE_PREFERENCE_REJECT_BTN);
  let accept_msg = document.getElementById(COOKIE_PREFERENCE_ACCEPT_MSG);
  let reject_msg = document.getElementById(COOKIE_PREFERENCE_REJECT_MSG);
  if(status === 'Accepted') {
    accept.style.display = 'none';
    reject.style.display = 'inline';
    accept_msg.style.display = 'block';
    reject_msg.style.display = 'none';
  } else {
    accept.style.display = 'inline';
    reject.style.display = 'none';
    accept_msg.style.display = 'none';
    reject_msg.style.display = 'block';
  }
}

function setPreferenceButtonState() {
  let cookieStatus = Cookies.get(COOKIE_PREFERENCE_NAME);
  let accept = document.getElementById(COOKIE_PREFERENCE_ACCEPT_BTN);
  let reject = document.getElementById(COOKIE_PREFERENCE_REJECT_BTN);

  if(cookieStatus === undefined) {
    // user has not accepted or refused; or preference cookie expired
    accept.style.display = 'inline';
    reject.style.display = 'inline';
  } else if (cookieStatus == ACCEPTED) {
    // preference cookie is current and user has accepted
    reject.style.display = 'inline';
  } else {
    // preference cookie is current and user has refused
    accept.style.display = 'inline';
  }

  window.updateCookiePreference = updateCookiePreference;
}

$(document).ready(initializeCookieBanner);
