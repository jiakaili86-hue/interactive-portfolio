const http = require("http");
const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");

const host = "127.0.0.1";
const port = 4173;
const root = __dirname;
const url = `http://${host}:${port}/`;
const shouldOpenBrowser = process.env.PORTFOLIO_NO_OPEN !== "1";

const mimeTypes = {
  ".css": "text/css; charset=utf-8",
  ".glb": "model/gltf-binary",
  ".html": "text/html; charset=utf-8",
  ".ico": "image/x-icon",
  ".jpeg": "image/jpeg",
  ".jpg": "image/jpeg",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".m4a": "audio/mp4",
  ".mp3": "audio/mpeg",
  ".mp4": "video/mp4",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".wasm": "application/wasm",
  ".webp": "image/webp",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
};

function openBrowser() {
  if (!shouldOpenBrowser) return;
  exec(`start "" "${url}"`, { windowsHide: true });
}

function sendError(response, statusCode, message) {
  response.writeHead(statusCode, {
    "Content-Type": "text/plain; charset=utf-8",
    "Cache-Control": "no-store",
  });
  response.end(message);
}

function resolveRequestPath(requestUrl) {
  const pathname = decodeURIComponent(new URL(requestUrl, url).pathname);
  const relativePath = pathname.replace(/^[/\\]+/, "");
  const resolvedPath = path.resolve(root, relativePath || "index.html");

  if (resolvedPath !== root && !resolvedPath.startsWith(`${root}${path.sep}`)) {
    return null;
  }

  return resolvedPath;
}

function streamFile(request, response, filePath, stats) {
  const contentType =
    mimeTypes[path.extname(filePath).toLowerCase()] || "application/octet-stream";
  const range = request.headers.range;

  if (range) {
    const match = /^bytes=(\d*)-(\d*)$/.exec(range);
    if (!match) {
      response.writeHead(416, { "Content-Range": `bytes */${stats.size}` });
      response.end();
      return;
    }

    const start = match[1] ? Number(match[1]) : 0;
    const end = match[2] ? Number(match[2]) : stats.size - 1;

    if (start > end || end >= stats.size) {
      response.writeHead(416, { "Content-Range": `bytes */${stats.size}` });
      response.end();
      return;
    }

    response.writeHead(206, {
      "Accept-Ranges": "bytes",
      "Cache-Control": "no-store",
      "Content-Length": end - start + 1,
      "Content-Range": `bytes ${start}-${end}/${stats.size}`,
      "Content-Type": contentType,
    });

    if (request.method === "HEAD") {
      response.end();
      return;
    }

    fs.createReadStream(filePath, { start, end }).pipe(response);
    return;
  }

  response.writeHead(200, {
    "Accept-Ranges": "bytes",
    "Cache-Control": "no-store",
    "Content-Length": stats.size,
    "Content-Type": contentType,
  });

  if (request.method === "HEAD") {
    response.end();
    return;
  }

  fs.createReadStream(filePath).pipe(response);
}

const server = http.createServer((request, response) => {
  if (request.method !== "GET" && request.method !== "HEAD") {
    sendError(response, 405, "Method Not Allowed");
    return;
  }

  let filePath;
  try {
    filePath = resolveRequestPath(request.url);
  } catch {
    sendError(response, 400, "Bad Request");
    return;
  }

  if (!filePath) {
    sendError(response, 403, "Forbidden");
    return;
  }

  fs.stat(filePath, (error, stats) => {
    if (error) {
      sendError(response, 404, "Not Found");
      return;
    }

    if (stats.isDirectory()) {
      const indexPath = path.join(filePath, "index.html");
      fs.stat(indexPath, (indexError, indexStats) => {
        if (indexError || !indexStats.isFile()) {
          sendError(response, 404, "Not Found");
          return;
        }
        streamFile(request, response, indexPath, indexStats);
      });
      return;
    }

    streamFile(request, response, filePath, stats);
  });
});

server.on("error", (error) => {
  if (error.code === "EADDRINUSE") {
    console.log(`作品集服务已经在运行：${url}`);
    openBrowser();
    process.exit(0);
  }

  console.error("作品集启动失败：", error.message);
  process.exit(1);
});

server.listen(port, host, () => {
  console.log(`作品集已打开：${url}`);
  console.log("请保持此窗口开启；关闭窗口即可停止作品集服务。");
  openBrowser();
});
