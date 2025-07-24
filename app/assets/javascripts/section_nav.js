function highlightAnchorOnLoad() {
  const anchorId = window.location.hash?.substring(1); // strips the '#' if present
  if (!anchorId) return;

  const navLinks = document.querySelectorAll('a.section-link');
  navLinks.forEach(navLink => {
    if (navLink.getAttribute("href") === '#' + anchorId) {
      navLink.classList.add('current');
    } else {
      navLink.classList.remove('current');
    }
  });
}

function initializeSectionObserver() {
  const sections = document.querySelectorAll('section.cms-page-section');

  const options = {
    threshold: 0.7
  };

  // choose the most visible section, helps with smaller pages
  const observer = new IntersectionObserver(function(entries) {
    const visibleEntries = entries
      .filter(entry => entry.isIntersecting)
      .sort((a, b) => b.intersectionRatio - a.intersectionRatio);

    if (visibleEntries.length > 0) {
      const activeId = visibleEntries[0].target.id;
      const navLinks = document.querySelectorAll('a.section-link');

      navLinks.forEach(navLink => {
        if (navLink.getAttribute("href") === '#' + activeId) {
          navLink.classList.add('current');
        } else {
          navLink.classList.remove('current');
        }
      });
    }
  }, options);

  sections.forEach(section => {
    observer.observe(section);
  });
}


function initializeSectionNav() {
  const sectionNav = document.querySelector('div#section-navigation');

  if (sectionNav !== null) {
    highlightAnchorOnLoad();

    // Defer observer activation until user first scrolls the page
    // avoids the section highlighting being mismatched with anchor
    // on page load
    let observerStarted = false;
    window.addEventListener('scroll', () => {
      if (!observerStarted) {
        initializeSectionObserver();
        observerStarted = true;
      }
    }, { once: true });
  }
}

$(document).ready(initializeSectionNav);
