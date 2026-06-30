(() => {
  const body = document.body;
  const revealItems = Array.from(document.querySelectorAll("[data-reveal]"));
  const sections = Array.from(document.querySelectorAll("[data-section]"));
  const navLinks = Array.from(document.querySelectorAll("[data-nav-link]"));
  const railLinks = Array.from(document.querySelectorAll("[data-rail-link]"));
  const progressBar = document.querySelector("[data-progress-bar]");
  const spotlightTargets = Array.from(
    document.querySelectorAll(".case-hero, .spread-image, .sticker-item"),
  );
  const stickerItems = Array.from(document.querySelectorAll(".sticker-item"));

  const setLoaded = () => {
    body.classList.remove("is-loading");
  };

  window.addEventListener("load", setLoaded, { once: true });
  window.setTimeout(setLoaded, 900);

  const updateProgress = () => {
    if (!progressBar) return;

    const maxScroll =
      document.documentElement.scrollHeight - window.innerHeight;
    const progress = maxScroll > 0 ? window.scrollY / maxScroll : 0;
    progressBar.style.transform = `scaleX(${Math.min(Math.max(progress, 0), 1)})`;
  };

  const setActiveSection = (sectionId) => {
    body.dataset.scene = sectionId;

    [...navLinks, ...railLinks].forEach((link) => {
      const isActive = link.getAttribute("href") === `#${sectionId}`;
      link.classList.toggle("is-active", isActive);
      if (isActive) {
        link.setAttribute("aria-current", "true");
      } else {
        link.removeAttribute("aria-current");
      }
    });
  };

  const syncActiveSection = () => {
    const marker = window.innerHeight * 0.5;
    const activeSection =
      sections.find((section) => {
        const rect = section.getBoundingClientRect();
        return rect.top <= marker && rect.bottom >= marker;
      }) || sections[sections.length - 1];

    if (activeSection) {
      setActiveSection(activeSection.id);
    }
  };

  let activeFrame = 0;
  const requestActiveSync = () => {
    if (activeFrame) return;

    activeFrame = window.requestAnimationFrame(() => {
      activeFrame = 0;
      syncActiveSection();
    });
  };

  window.addEventListener(
    "scroll",
    () => {
      updateProgress();
      requestActiveSync();
    },
    { passive: true },
  );
  window.addEventListener("resize", () => {
    updateProgress();
    requestActiveSync();
  });
  updateProgress();
  syncActiveSection();

  [...navLinks, ...railLinks].forEach((link) => {
    link.addEventListener("click", () => {
      const sectionId = link.getAttribute("href")?.replace("#", "");
      if (sectionId) {
        setActiveSection(sectionId);
        window.setTimeout(syncActiveSection, 520);
      }
    });
  });

  spotlightTargets.forEach((target) => {
    target.addEventListener("pointermove", (event) => {
      const rect = target.getBoundingClientRect();
      const x = ((event.clientX - rect.left) / rect.width) * 100;
      const y = ((event.clientY - rect.top) / rect.height) * 100;
      target.style.setProperty("--mx", `${x.toFixed(1)}%`);
      target.style.setProperty("--my", `${y.toFixed(1)}%`);
    });
  });

  stickerItems.forEach((item) => {
    item.addEventListener("click", () => {
      stickerItems.forEach((sticker) =>
        sticker.classList.toggle("is-selected", sticker === item),
      );
    });
  });

  if (!("IntersectionObserver" in window)) {
    revealItems.forEach((item) => item.classList.add("is-visible"));
    return;
  }

  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { rootMargin: "0px 0px -10% 0px", threshold: 0.12 },
  );

  revealItems.forEach((item) => revealObserver.observe(item));
})();
