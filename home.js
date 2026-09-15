(() => {
  "use strict";

  const body = document.body;
  const hero = document.querySelector("[data-orbit-hero]");
  const orbitStage = document.querySelector("[data-orbit-stage]");
  const orbitTiles = [...document.querySelectorAll("[data-orbit-tile]")];
  const orbitLabel = document.querySelector("[data-orbit-label]");
  const orbitType = document.querySelector("[data-orbit-type]");
  const ambientAudio = document.querySelector("[data-ambient-audio]");
  const audioToggle = document.querySelector("[data-audio-toggle]");
  const enterWorks = document.querySelector("[data-enter-works]");
  const showcase = document.querySelector("[data-sticky-showcase]");
  const workVisuals = [...document.querySelectorAll("[data-work-visual]")];
  const workCopies = [...document.querySelectorAll("[data-work-copy]")];
  const workTriggers = [...document.querySelectorAll("[data-work-trigger]")];
  const workNumber = document.querySelector("[data-work-number]");
  const workPrevious = document.querySelector("[data-work-prev]");
  const workNext = document.querySelector("[data-work-next]");
  const categoryTriggers = [...document.querySelectorAll("[data-category-trigger]")];
  const featuredLink = document.querySelector("[data-featured-link]");
  const featuredImage = document.querySelector("[data-featured-image]");
  const featuredType = document.querySelector("[data-featured-type]");
  const featuredTitle = document.querySelector("[data-featured-title]");
  const featuredDescription = document.querySelector("[data-featured-description]");
  const featuredButton = document.querySelector("[data-featured-button]");
  const itemNumber = document.querySelector("[data-item-number]");
  const itemTotal = document.querySelector("[data-item-total]");
  const itemPrevious = document.querySelector("[data-item-prev]");
  const itemNext = document.querySelector("[data-item-next]");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  const clamp = (value, min, max) => Math.min(Math.max(value, min), max);
  const AMBIENT_VOLUME = 0.38;

  let activeWork = 0;
  let activeCategory = 0;
  let activeItem = 0;
  let pointerX = 0;
  let pointerY = 0;
  let currentX = 0;
  let currentY = 0;
  let soundEnabled = false;
  let soundManuallySet = false;
  let audioPrimed = false;
  let lastCardSoundAt = 0;
  let cardAudioContext;
  let ambientFadeFrame;

  const workCatalog = {
    ui: [
      { title: "侠客行", type: "UI / REALTIME INTERACTION", description: "点击画面触发挥砍反馈的第一人称实时交互。", image: "assets/covers/ronin-first-person-cover.jpg", href: "ronin/" },
      { title: "粒子溶解实验", type: "UI / WEBGL INTERACTION", description: "用实时粒子与鼠标输入控制人物形体的聚合和溶解。", image: "assets/covers/dissolve-undissolved-v1.png", href: "dissolve/" },
      { title: "WE ARE 26", type: "UI / PHYSICS INTERACTION", description: "基于网页物理反馈制作的可拖拽吊牌交互。", image: "lanyard/assets/lanyard-natural-thin-cord-v3.png", href: "lanyard/" },
    ],
    ip: [
      { title: "布蜥蜥的一天", type: "IP / CHARACTER DESIGN", description: "原创角色设定、性格表达与系列视觉延展。", image: "buxix-case/assets/06-card-cover.jpg", href: "buxix-case/" },
    ],
    video: [
      { title: "熔岩巨龙对决", type: "VIDEO / GAME BATTLE CG", description: "围绕巨龙对决、技能爆发与环境响应完成的战斗 CG。", image: "assets/covers/game-cg-duel-cover.png", href: "viewer/?work=dragon-duel" },
      { title: "古风江湖叙事", type: "VIDEO / NARRATIVE FILM", description: "以人物关系、江湖氛围与连续镜头组织完成的叙事影像。", image: "assets/covers/costume-narrative-cover.png", href: "viewer/?work=jianghu-story" },
      { title: "生椰拿铁广告", type: "VIDEO / COMMERCIAL FILM", description: "从产品视觉、场景设计到成片节奏独立完成的 AIGC 广告。", image: "assets/covers/coconut-latte-cover.png", href: "viewer/?work=coconut-latte" },
      { title: "游戏 CG 角色展示", type: "VIDEO / CHARACTER CG", description: "围绕角色气质、服装细节与镜头表现制作的游戏 CG。", image: "assets/covers/game-cg-character-cover.png", href: "viewer/?work=game-cg-character" },
      { title: "机器人公司宣传片", type: "VIDEO / BRAND FILM", description: "面向机器人企业形象与产品能力制作的品牌宣传影像。", image: "assets/covers/robot-company-cover.png", href: "viewer/?work=robot-company" },
    ],
    game: [
      { title: "百味守阵", type: "GAME / PLAYABLE DEMO", description: "独立完成概念、美术与玩法落地的浏览器放置策略 Demo。", image: "assets/covers/baiwei-shouzhen-cover-v8-anime-tactician.png", href: "game/" },
    ],
  };

  if (ambientAudio) {
    ambientAudio.volume = 0;
    ambientAudio.muted = true;
  }

  const fadeAmbientVolume = (targetVolume, onComplete) => {
    if (!ambientAudio) return;

    window.cancelAnimationFrame(ambientFadeFrame);
    const startVolume = ambientAudio.volume;
    const startTime = window.performance.now();
    const duration = 900;

    const tick = (time) => {
      const progress = clamp((time - startTime) / duration, 0, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      ambientAudio.volume = startVolume + (targetVolume - startVolume) * eased;

      if (progress < 1) {
        ambientFadeFrame = window.requestAnimationFrame(tick);
      } else {
        onComplete?.();
      }
    };

    ambientFadeFrame = window.requestAnimationFrame(tick);
  };

  const updateAudioToggle = (enabled) => {
    audioToggle?.setAttribute("aria-pressed", String(enabled));
    audioToggle?.classList.toggle("is-active", enabled);
    if (audioToggle) audioToggle.textContent = enabled ? "音乐 · 开" : "音乐 · 关";
  };

  const setSoundState = (enabled) => {
    soundEnabled = enabled;
    updateAudioToggle(enabled);

    if (!ambientAudio) return Promise.resolve(false);

    if (enabled) {
      ambientAudio.muted = false;
      return ambientAudio
        .play()
        .then(() => {
          if (!soundEnabled) return false;
          audioPrimed = true;
          unlockCardAudioContext();
          fadeAmbientVolume(AMBIENT_VOLUME);
          return true;
        })
        .catch(() => {
          soundEnabled = false;
          audioPrimed = false;
          ambientAudio.muted = true;
          updateAudioToggle(false);
          return false;
        });
    }

    audioPrimed = false;
    fadeAmbientVolume(0, () => {
      if (!soundEnabled) {
        ambientAudio.pause();
        ambientAudio.muted = true;
      }
    });
    return Promise.resolve(true);
  };

  const getCardAudioContext = () => {
    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    if (!AudioContextClass) return null;

    cardAudioContext ||= new AudioContextClass();
    return cardAudioContext;
  };

  const unlockCardAudioContext = () => {
    const context = getCardAudioContext();
    if (!context) return;

    context.resume().catch(() => {});
  };

  const primeAudio = (event) => {
    if (event?.target?.closest?.("[data-audio-toggle]")) return;
    if (soundManuallySet || audioPrimed || reducedMotion.matches) return;
    setSoundState(true);
  };

  const playCardSound = async () => {
    if (!soundEnabled) return;

    const now = window.performance.now();
    if (now - lastCardSoundAt < 320) return;
    lastCardSoundAt = now;

    const context = getCardAudioContext();
    if (!context) return;

    if (context.state === "suspended") {
      await context.resume().catch(() => {});
    }

    const start = context.currentTime + 0.012;
    const output = context.createGain();
    const compressor = context.createDynamicsCompressor();
    const flipBuffer = context.createBuffer(1, Math.floor(context.sampleRate * 0.38), context.sampleRate);
    const flipNoise = context.createBufferSource();
    const pageGain = context.createGain();
    const lowShelf = context.createBiquadFilter();
    const lowpass = context.createBiquadFilter();
    const highpass = context.createBiquadFilter();
    const body = context.createOscillator();
    const bodyGain = context.createGain();

    const channel = flipBuffer.getChannelData(0);
    for (let i = 0; i < channel.length; i += 1) {
      const progress = i / Math.max(1, channel.length - 1);
      const swipe = Math.sin(progress * Math.PI);
      const envelope = Math.pow(swipe, 0.55) * Math.pow(1 - progress, 0.18);
      channel[i] = (Math.random() * 2 - 1) * envelope;
    }

    output.gain.setValueAtTime(0.0001, start);
    output.gain.exponentialRampToValueAtTime(0.56, start + 0.016);
    output.gain.exponentialRampToValueAtTime(0.0001, start + 0.5);

    compressor.threshold.setValueAtTime(-26, start);
    compressor.knee.setValueAtTime(18, start);
    compressor.ratio.setValueAtTime(3, start);
    compressor.attack.setValueAtTime(0.008, start);
    compressor.release.setValueAtTime(0.18, start);

    lowShelf.type = "lowshelf";
    lowShelf.frequency.setValueAtTime(180, start);
    lowShelf.gain.setValueAtTime(5.8, start);

    highpass.type = "highpass";
    highpass.frequency.setValueAtTime(48, start);
    highpass.Q.setValueAtTime(0.65, start);

    lowpass.type = "lowpass";
    lowpass.frequency.setValueAtTime(1180, start);
    lowpass.frequency.exponentialRampToValueAtTime(460, start + 0.34);
    lowpass.Q.setValueAtTime(0.82, start);

    pageGain.gain.setValueAtTime(0.0001, start);
    pageGain.gain.exponentialRampToValueAtTime(0.9, start + 0.026);
    pageGain.gain.exponentialRampToValueAtTime(0.0001, start + 0.38);

    body.type = "triangle";
    body.frequency.setValueAtTime(62, start);
    body.frequency.exponentialRampToValueAtTime(46, start + 0.38);
    bodyGain.gain.setValueAtTime(0.0001, start);
    bodyGain.gain.exponentialRampToValueAtTime(0.16, start + 0.018);
    bodyGain.gain.exponentialRampToValueAtTime(0.0001, start + 0.44);

    flipNoise.buffer = flipBuffer;
    flipNoise.playbackRate.setValueAtTime(0.86, start);

    flipNoise.connect(pageGain);
    pageGain.connect(highpass);
    highpass.connect(lowpass);
    lowpass.connect(lowShelf);
    lowShelf.connect(output);
    body.connect(bodyGain);
    bodyGain.connect(output);
    output.connect(compressor);
    compressor.connect(context.destination);

    flipNoise.start(start);
    flipNoise.stop(start + 0.42);
    body.start(start);
    body.stop(start + 0.48);
  };

  const prewarmAmbientAudio = () => {
    if (!ambientAudio || reducedMotion.matches) return;

    ambientAudio.muted = true;
    ambientAudio.volume = 0;
    ambientAudio.play().catch(() => {});
  };

  const playActiveVideo = (index) => {
    workVisuals.forEach((visual, visualIndex) => {
      const video = visual.querySelector("video");
      if (!video) return;

      if (visualIndex === index) {
        video.play().catch(() => {});
      } else {
        video.pause();
      }
    });
  };

  const setActiveWork = (index) => {
    const next = clamp(index, 0, workTriggers.length - 1);
    if (next === activeWork && workCopies[next]?.classList.contains("is-active")) {
      return;
    }

    workVisuals[activeWork]?.classList.remove("is-active");
    workCopies[activeWork]?.classList.remove("is-active");
    workCopies[activeWork]?.setAttribute("aria-hidden", "true");
    workTriggers[activeWork]?.classList.remove("is-active");

    activeWork = next;

    workVisuals[activeWork]?.classList.add("is-active");
    workCopies[activeWork]?.classList.add("is-active");
    workCopies[activeWork]?.removeAttribute("aria-hidden");
    workTriggers[activeWork]?.classList.add("is-active");

    if (workNumber) {
      workNumber.textContent = String(activeWork + 1).padStart(2, "0");
    }

    playActiveVideo(activeWork);
  };

  const renderFeaturedItem = () => {
    const categoryKey = categoryTriggers[activeCategory]?.dataset.categoryTrigger;
    const items = workCatalog[categoryKey] || [];
    if (!items.length) return;
    activeItem = (activeItem + items.length) % items.length;
    const item = items[activeItem];

    if (featuredLink) {
      featuredLink.href = item.href;
      featuredLink.classList.toggle("work-visual--light-object", Boolean(item.lightObject));
    }
    if (featuredImage) {
      featuredImage.src = item.image;
      featuredImage.alt = item.title;
    }
    if (featuredType) featuredType.textContent = item.type;
    if (featuredTitle) featuredTitle.textContent = item.title;
    if (featuredDescription) featuredDescription.textContent = item.description;
    if (featuredButton) featuredButton.href = item.href;
    if (itemNumber) itemNumber.textContent = String(activeItem + 1).padStart(2, "0");
    if (itemTotal) itemTotal.textContent = String(items.length).padStart(2, "0");

    const hasMultiple = items.length > 1;
    if (itemPrevious) itemPrevious.disabled = !hasMultiple;
    if (itemNext) itemNext.disabled = !hasMultiple;
  };

  const setActiveCategory = (index, moveFocus = false) => {
    if (categoryTriggers.length === 0) return;
    activeCategory = (index + categoryTriggers.length) % categoryTriggers.length;
    activeItem = 0;

    categoryTriggers.forEach((trigger, triggerIndex) => {
      const selected = triggerIndex === activeCategory;
      trigger.classList.toggle("is-active", selected);
      trigger.setAttribute("aria-selected", String(selected));
      trigger.tabIndex = selected ? 0 : -1;
    });

    renderFeaturedItem();
    if (moveFocus) categoryTriggers[activeCategory].focus();
  };

  const stepFeaturedItem = (direction) => {
    const categoryKey = categoryTriggers[activeCategory]?.dataset.categoryTrigger;
    const items = workCatalog[categoryKey] || [];
    if (items.length < 2) return;
    activeItem = (activeItem + direction + items.length) % items.length;
    renderFeaturedItem();
  };

  const updateHeroPointer = () => {
    if (!hero || reducedMotion.matches) return;
    currentX += (pointerX - currentX) * 0.075;
    currentY += (pointerY - currentY) * 0.075;
    hero.style.setProperty("--mx", currentX.toFixed(4));
    hero.style.setProperty("--my", currentY.toFixed(4));
    window.requestAnimationFrame(updateHeroPointer);
  };

  const orbitSlots = [
    { x: -555, y: -70, depth: 0.44, rotate: -13 },
    { x: -495, y: 125, depth: 0.75, rotate: 10 },
    { x: -185, y: 270, depth: 0.98, rotate: -3 },
    { x: 235, y: 270, depth: 0.92, rotate: 5 },
    { x: 515, y: 115, depth: 0.74, rotate: -9 },
    { x: 565, y: -70, depth: 0.50, rotate: 12 },
    { x: 505, y: -238, depth: 0.38, rotate: -6 },
    { x: 325, y: -365, depth: 0.30, rotate: -7 },
    { x: -325, y: -365, depth: 0.31, rotate: 9 },
    { x: -505, y: -238, depth: 0.39, rotate: 6 },
  ];

  const positionOrbitTiles = (time = 0, animate = true) => {
    if (!orbitStage || orbitTiles.length === 0) return;
    const rect = orbitStage.getBoundingClientRect();
    const scaleX = rect.width / 1440;
    const scaleY = rect.height / 900;

    orbitTiles.forEach((tile, index) => {
      const slot = orbitSlots[index % orbitSlots.length];
      const floatPhase = time * 0.001 + index * 0.83;
      const depth = slot.depth;
      const floatX = animate ? Math.sin(floatPhase) * 7 : 0;
      const floatY = animate ? Math.cos(floatPhase * 0.86) * 5 : 0;
      const pointerOffsetX = animate ? currentX * 18 : 0;
      const pointerOffsetY = animate ? currentY * 8 : 0;
      const x = slot.x * scaleX + floatX + pointerOffsetX;
      const y = slot.y * scaleY + floatY + pointerOffsetY;
      const scale = 0.56 + depth * 0.47;
      const opacity = 1;
      const tiltY = (0.5 - depth) * 18;
      const lift = (1 - depth) * -70;
      const side = 3 + depth * 6;
      const shadowY = 8 + depth * 18;

      tile.style.zIndex = String(Math.round(depth * 100));
      tile.style.opacity = String(opacity);
      tile.style.filter = `drop-shadow(${side.toFixed(1)}px ${(side * 0.72).toFixed(1)}px 0 rgba(10, 8, 6, 0.34)) drop-shadow(0 ${shadowY.toFixed(1)}px ${(shadowY * 1.8).toFixed(1)}px rgba(0, 0, 0, 0.56))`;
      tile.style.transform = `translate3d(calc(-50% + ${x.toFixed(2)}px), calc(-50% + ${y.toFixed(2)}px), ${lift.toFixed(2)}px) rotateY(${tiltY.toFixed(2)}deg) rotate(${slot.rotate.toFixed(2)}deg) scale(${scale.toFixed(3)})`;
    });
  };

  const updateOrbit = (time) => {
    if (!orbitStage || orbitTiles.length === 0 || reducedMotion.matches) return;

    positionOrbitTiles(time, true);

    window.requestAnimationFrame(updateOrbit);
  };

  const updateShowcaseByScroll = () => {
    if (!showcase || workTriggers.length === 0) return;

    const rect = showcase.getBoundingClientRect();
    const distance = Math.max(1, rect.height - window.innerHeight);
    const progress = clamp(-rect.top / distance, 0, 1);
    const index = clamp(Math.floor(progress * workTriggers.length), 0, workTriggers.length - 1);

    setActiveWork(index);
  };

  hero?.addEventListener("pointermove", (event) => {
    const rect = hero.getBoundingClientRect();
    pointerX = ((event.clientX - rect.left) / rect.width - 0.5) * 2;
    pointerY = ((event.clientY - rect.top) / rect.height - 0.5) * 2;
  });

  hero?.addEventListener("pointerleave", () => {
    pointerX = 0;
    pointerY = 0;
  });

  orbitTiles.forEach((tile) => {
    const setOrbitTileActive = () => {
      if (orbitLabel && tile.dataset.project) {
        orbitLabel.textContent = tile.dataset.project;
      }
      if (orbitType && tile.dataset.medium) {
        orbitType.textContent = tile.dataset.medium;
      }
      playCardSound();
    };

    tile.addEventListener("pointerenter", setOrbitTileActive);
    tile.addEventListener("mouseenter", setOrbitTileActive);
    tile.addEventListener("focus", setOrbitTileActive);
  });

  audioToggle?.addEventListener("click", () => {
    soundManuallySet = true;
    setSoundState(!soundEnabled);
  });

  enterWorks?.addEventListener("click", () => {
    showcase?.scrollIntoView({ behavior: reducedMotion.matches ? "auto" : "smooth" });
  });

  const scrollToWork = (index) => {
    if (!showcase || workTriggers.length === 0) return;
    const wrappedIndex = (index + workTriggers.length) % workTriggers.length;
    setActiveWork(wrappedIndex);
    const targetTop =
      window.scrollY +
      showcase.getBoundingClientRect().top +
      ((showcase.offsetHeight - window.innerHeight) / workTriggers.length) * wrappedIndex +
      4;

    window.scrollTo({
      top: targetTop,
      behavior: reducedMotion.matches ? "auto" : "smooth",
    });
  };

  workTriggers.forEach((trigger, index) => {
    trigger.addEventListener("click", () => {
      scrollToWork(index);
    });
  });

  workPrevious?.addEventListener("click", () => scrollToWork(activeWork - 1));
  workNext?.addEventListener("click", () => scrollToWork(activeWork + 1));

  categoryTriggers.forEach((trigger, index) => {
    trigger.addEventListener("click", () => setActiveCategory(index));
  });
  itemPrevious?.addEventListener("click", () => stepFeaturedItem(-1));
  itemNext?.addEventListener("click", () => stepFeaturedItem(1));

  document.addEventListener("keydown", (event) => {
    primeAudio();

    if (!event.target.closest?.(".work-rail")) return;
    if (event.key === "ArrowRight") {
      event.preventDefault();
      setActiveCategory(activeCategory + 1, true);
    }
    if (event.key === "ArrowLeft") {
      event.preventDefault();
      setActiveCategory(activeCategory - 1, true);
    }
  });

  ["pointerdown", "wheel", "touchstart"].forEach((eventName) => {
    window.addEventListener(eventName, primeAudio, { once: true, passive: true });
  });

  window.addEventListener("resize", () => {
    if (reducedMotion.matches) positionOrbitTiles(0, false);
  });
  window.addEventListener("load", () => {
    body.classList.remove("is-loading");
    prewarmAmbientAudio();
    setActiveCategory(activeCategory);
  });

  window.setTimeout(() => body.classList.remove("is-loading"), 900);

  if (reducedMotion.matches) {
    positionOrbitTiles(0, false);
  } else {
    updateHeroPointer();
    window.requestAnimationFrame(updateOrbit);
  }
})();
