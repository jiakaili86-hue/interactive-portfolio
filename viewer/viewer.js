(() => {
  "use strict";

  const works = {
    "dragon-duel": {
      kind: "video",
      src: "../assets/videos/hero-card-left-01-web.mp4",
      title: "熔岩巨龙对决",
      type: "游戏战斗 CG · 43 SEC",
      description: "火焰能力角色与熔岩巨龙在废墟战场正面对决的游戏战斗 CG。",
    },
    "jianghu-story": {
      kind: "video",
      src: "../assets/videos/hero-card-left-02-web.mp4",
      title: "古风江湖叙事",
      type: "AIGC 叙事影像 · 50 SEC",
      description: "围绕侠客、旧伤与宿命展开的古风江湖叙事短片。",
    },
    "coconut-latte": {
      kind: "video",
      src: "../assets/videos/coconut-latte-ad-web.mp4",
      title: "生椰拿铁广告",
      type: "AIGC 商业广告 · 33 SEC",
      description: "以拟人咖啡豆角色和水上竞速场景展开的生椰拿铁商业广告。",
    },
    "game-cg-character": {
      kind: "video",
      src: "../assets/videos/game-cg-character-showcase-web.mp4",
      title: "游戏 CG 角色展示",
      type: "AIGC 游戏 CG · 66 SEC",
      description: "围绕暗影巨狼与白翼骑士展开的游戏角色 CG 展示。",
    },
    "robot-company": {
      kind: "video",
      src: "../assets/videos/robot-company-film-web.mp4",
      title: "机器人公司宣传片",
      type: "机器人品牌影像 · 105 SEC",
      description: "展示人形机器人与多臂机器人在不同操作任务中的控制能力。",
    },
  };

  const query = new URLSearchParams(window.location.search);
  const work = works[query.get("work")];
  const mediaHost = document.querySelector("[data-media-host]");
  const title = document.querySelector("[data-work-title]");
  const type = document.querySelector("[data-work-type]");
  const description = document.querySelector("[data-work-description]");

  if (!work) {
    document.title = "作品不存在 | KUUP AIGC";
    mediaHost.innerHTML = '<p class="viewer-error">没有找到这个作品，请返回作品集重新选择。</p>';
    title.textContent = "作品不存在";
    type.textContent = "KUUP AIGC";
    description.textContent = "";
    return;
  }

  document.title = `${work.title} | KUUP AIGC`;
  title.textContent = work.title;
  type.textContent = work.type;
  description.textContent = work.description;
  mediaHost.replaceChildren();

  if (work.kind === "video") {
    const video = document.createElement("video");
    video.src = work.src;
    video.controls = true;
    video.autoplay = true;
    video.playsInline = true;
    video.preload = "metadata";
    video.setAttribute("aria-label", `播放${work.title}`);
    mediaHost.append(video);
    return;
  }

  const image = document.createElement("img");
  image.src = work.src;
  image.alt = work.title;
  mediaHost.append(image);
})();
