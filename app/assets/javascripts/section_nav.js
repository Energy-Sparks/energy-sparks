function initializeSectionNav() {
  const sectionNav = document.querySelector('div#section-navigation');

  if (sectionNav !== null) {
    const sections = document.querySelectorAll('section.cms-page-section');

    const options = {
      threshold: 0.5
    };

    const observer = new IntersectionObserver(function(entries, observer) {
      entries.forEach(entry => {
        if (!entry.isIntersecting) {
          return;
        }
        const navLinks = document.querySelectorAll('a.section-link');
        navLinks.forEach(navLink => {
          if (navLink.getAttribute("href") == '#'.concat(entry.target.id)) {
            navLink.classList.add('current');
          } else {
            navLink.classList.remove('current');
          }
        });
      })
    }, options);

    sections.forEach(section => {
      observer.observe(section);
    })
  }
}

$(document).ready(initializeSectionNav);
