// Loads the correct tab given a url with a hash to the tab
// Changes the url hash when a new tab is selected
// Give a class of url-aware to nav-tabs container for this to work

document.addEventListener("DOMContentLoaded", function () {
  // If there's a hash in the URL, activate that tab
  if (location.hash) {
    const tabLink = document.querySelector(`.url-aware a[href="${location.hash}"]`);
    if (tabLink) tabLink.click();
  }

  // When a tab is clicked, update the URL hash
  document.body.addEventListener("click", function (event) {
    const link = event.target.closest('.url-aware a[data-toggle="tab"]');
    if (link) {
      event.preventDefault();
      const target = link.getAttribute("href");

      // Show the tab manually
      link.click();

      // Update hash in URL
      history.pushState(null, "", target);
    }
  });
});

// When using back/forward buttons, show correct tab
window.addEventListener("popstate", function () {
  const anchor =
    location.hash ||
    document.querySelector('.url-aware a[data-toggle="tab"]')?.getAttribute("href");

  const tabLink = document.querySelector(`.url-aware a[href="${anchor}"]`);
  if (tabLink) tabLink.click();
});
