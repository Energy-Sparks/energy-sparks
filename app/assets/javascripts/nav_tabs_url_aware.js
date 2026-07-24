// Loads the correct tab given a url with a hash to the tab
// Changes the url hash when a new tab is selected
// Give a class of url-aware to nav-tabs container for this to work
// BS5 version

const tabSelector = '.url-aware a[data-bs-toggle="tab"]';

function findTabLink(hash) {
  if (!hash) return null;
  return document.querySelector(`.url-aware a[href="${hash}"]`);
}

function showTabFromHash(hash) {
  const tabLink = findTabLink(hash);
  if (tabLink) {
    bootstrap.Tab.getOrCreateInstance(tabLink).show();
  }
}

// Prevent automatic scrolling to the tab content on page load when there's a hash
window.addEventListener("load", function () {
  if (location.hash && document.querySelector(`.url-aware a[href="${location.hash}"]`)) {
    window.scrollTo(0, 0);
  }
});

document.addEventListener("DOMContentLoaded", function () {
  // If there's a hash in the URL, activate that tab
  if (location.hash) {
    showTabFromHash(location.hash);
  }

  // When tab changes, update URL
  document.addEventListener("shown.bs.tab", function (event) {
    const link = event.target.closest(tabSelector);
    const target = link.getAttribute("href");
    history.replaceState(null, "", target);
  });
});

// Back / forward buttons
window.addEventListener("popstate", function () {
  const anchor = location.hash || document.querySelector(tabSelector)?.getAttribute("href");
  showTabFromHash(anchor);
});
