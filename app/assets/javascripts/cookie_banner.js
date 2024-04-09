"use strict"

function initializeCookieBanner() {
 let cookieStatus = Cookies.get('cookie_preference');
 if(cookieStatus === undefined) {
   // user has not accepted or refused; or preference cookie expired
   showCookieBanner();
 } else if (cookieStatus == 'Accepted') {
   // preference cookie is current and user has accepted
   setAnalyticsConsent('granted');
 } else {
   // preference cookie is current and user has refused
   setAnalyticsConsent('denied');
 }
}

function showCookieBanner() {
 let cookieBanner = document.getElementById("cookie-banner");
 cookieBanner.style.display = "block";
 window.acceptCookies = acceptCookies;
 window.rejectCookies = rejectCookies;
}

function hideBanner() {
  let cookieBanner = document.getElementById("cookie-banner");
  cookieBanner.style.display = "none";
}

function setPreferenceCookie(status) {
  Cookies.remove('cookie_preference');
  Cookies.set('cookie_preference', status, { expires: 365 });
}

function acceptCookies() {
 setPreferenceCookie('Accepted');
 setAnalyticsConsent('granted');
 hideBanner();
}

function rejectCookies() {
 setPreferenceCookie('Rejected');
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
