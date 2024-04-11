"use strict"

const COOKIE_BANNER_ID = 'cookie-banner';
const COOKIE_PREFERENCE_NAME = 'cookie_preference';
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
 let preferenceButtons = document.getElementById('cookie-preference-buttons');
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
  let accept = document.getElementById('cookie-preference-accept');
  let reject = document.getElementById('cookie-preference-reject');
  let accept_msg = document.getElementById('cookie-preference-accepted-message');
  let reject_msg = document.getElementById('cookie-preference-rejected-message');
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
  let accept = document.getElementById('cookie-preference-accept');
  let reject = document.getElementById('cookie-preference-reject');

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
