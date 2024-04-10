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

$(document).ready(initializeCookieBanner);
