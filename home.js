(() => {
  "use strict";

  const body = document.body;
  const showcase = document.querySelector(".showcase");
  const mediaStage = document.querySelector(".media-stage");
  const mediaLayers = [...document.querySelectorAll("[data-project-media]")];
  const copyLayers = [...document.querySelectorAll("[data-project-copy]")];
  const triggers = [...document.querySelectorAll("[data-project-trigger]")];
  const currentNumber = document.querySelector("[data-current-number]");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const coarsePointer = window.matchMedia("(hover: none), (pointer: coarse)");

  if (!showcase || mediaLayers.length === 0 || triggers.length === 0) {
    body.classList.remove("is-loading");
    return;
  }

  let activeIndex = 0;
  let wheelLocked = false;
  let touchStartY = null;
  let touchStartX = null;

  const normalizeIndex = (index) =>
    (index + triggers.length) % triggers.length;

  const playActiveVideo = (index) => {
    mediaLayers.forEach((layer, layerIndex) => {
      const video = layer.querySelector("video");
      if (!video) return;

      if (layerIndex === index) {
        if (video.readyState === 0) video.load();
        video.play().catch(() => {});
      } else {
        video.pause();
      }
    });
  };

  const setActiveProject = (nextIndex) => {
    const index = normalizeIndex(nextIndex);
    if (index === activeIndex) return;

    mediaLayers[activeIndex]?.classList.remove("is-active");
    copyLayers[activeIndex]?.classList.remove("is-active");
    copyLayers[activeIndex]?.setAttribute("aria-hidden", "true");
    triggers[activeIndex]?.classList.remove("is-active");
    triggers[activeIndex]?.removeAttribute("aria-current");

    activeIndex = index;

    mediaLayers[activeIndex]?.classList.add("is-active");
    copyLayers[activeIndex]?.classList.add("is-active");
    copyLayers[activeIndex]?.removeAttribute("aria-hidden");
    triggers[activeIndex]?.classList.add("is-active");
    triggers[activeIndex]?.setAttribute("aria-current", "true");

    const accent = triggers[activeIndex]?.dataset.accent;
    if (accent) document.documentElement.style.setProperty("--signal", accent);
    if (currentNumber) {
      currentNumber.textContent = String(activeIndex + 1).padStart(2, "0");
    }

    playActiveVideo(activeIndex);
  };

  triggers.forEach((trigger, index) => {
    trigger.addEventListener("mouseenter", () => {
      if (!coarsePointer.matches) setActiveProject(index);
    });

    trigger.addEventListener("focus", () => {
      setActiveProject(index);
    });

    trigger.addEventListener("click", (event) => {
      event.preventDefault();
      setActiveProject(index);
      copyLayers[index]?.querySelector(".enter-link")?.focus({
        preventScroll: true,
      });
    });
  });

  showcase.addEventListener(
    "wheel",
    (event) => {
      if (reducedMotion.matches || Math.abs(event.deltaY) < 22 || wheelLocked) {
        return;
      }

      const direction = Math.sign(event.deltaY);
      const canMoveForward = direction > 0 && activeIndex < triggers.length - 1;
      const canMoveBackward = direction < 0 && activeIndex > 0;

      if (!canMoveForward && !canMoveBackward) return;

      event.preventDefault();
      wheelLocked = true;
      setActiveProject(activeIndex + direction);
      window.setTimeout(() => {
        wheelLocked = false;
      }, 620);
    },
    { passive: false },
  );

  document.addEventListener("keydown", (event) => {
    const rect = showcase.getBoundingClientRect();
    const showcaseIsVisible = rect.bottom > 0 && rect.top < window.innerHeight;
    if (!showcaseIsVisible) return;

    if (["ArrowRight", "ArrowDown"].includes(event.key)) {
      event.preventDefault();
      setActiveProject(activeIndex + 1);
    }

    if (["ArrowLeft", "ArrowUp"].includes(event.key)) {
      event.preventDefault();
      setActiveProject(activeIndex - 1);
    }
  });

  showcase.addEventListener(
    "touchstart",
    (event) => {
      const touch = event.changedTouches[0];
      touchStartY = touch.clientY;
      touchStartX = touch.clientX;
    },
    { passive: true },
  );

  showcase.addEventListener(
    "touchend",
    (event) => {
      if (touchStartY === null || touchStartX === null) return;

      const touch = event.changedTouches[0];
      const deltaY = touchStartY - touch.clientY;
      const deltaX = touchStartX - touch.clientX;
      touchStartY = null;
      touchStartX = null;

      if (Math.abs(deltaY) < 52 || Math.abs(deltaY) < Math.abs(deltaX)) return;
      if (deltaY > 0 && activeIndex < triggers.length - 1) {
        setActiveProject(activeIndex + 1);
      } else if (deltaY < 0 && activeIndex > 0) {
        setActiveProject(activeIndex - 1);
      }
    },
    { passive: true },
  );

  if (mediaStage && !coarsePointer.matches && !reducedMotion.matches) {
    let pointerX = window.innerWidth / 2;
    let pointerY = window.innerHeight / 2;
    let currentX = pointerX;
    let currentY = pointerY;

    mediaStage.addEventListener("pointermove", (event) => {
      const rect = mediaStage.getBoundingClientRect();
      pointerX = event.clientX - rect.left;
      pointerY = event.clientY - rect.top;
    });

    const updatePointer = () => {
      currentX += (pointerX - currentX) * 0.12;
      currentY += (pointerY - currentY) * 0.12;
      mediaStage.style.setProperty("--pointer-x", `${currentX}px`);
      mediaStage.style.setProperty("--pointer-y", `${currentY}px`);
      window.requestAnimationFrame(updatePointer);
    };

    updatePointer();
  }

  const finishLoading = () => {
    if (!body.classList.contains("is-loading")) return;
    body.classList.remove("is-loading");
  };

  const firstVideo = mediaLayers[0]?.querySelector("video");
  if (firstVideo) {
    if (firstVideo.readyState >= 3) {
      finishLoading();
    } else {
      firstVideo.addEventListener("canplay", finishLoading, { once: true });
      firstVideo.load();
    }
  } else {
    finishLoading();
  }

  window.setTimeout(finishLoading, 2200);
  playActiveVideo(activeIndex);
})();
