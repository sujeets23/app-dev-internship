// Browser webcam (getUserMedia) + MediaPipe FaceLandmarker helper for Date2 Demo Mode.
// Processes frames strictly in volatile browser memory; never uploads or saves raw selfies.

const LOCAL_BUNDLE_URL = './mediapipe/vision_bundle.mjs';
const LOCAL_WASM_DIR = './mediapipe/wasm';
const LOCAL_MODEL_URL = './mediapipe/face_landmarker.task';

const CDN_BUNDLE_URL =
  'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.18/vision_bundle.mjs';
const CDN_WASM_DIR =
  'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.18/wasm';
const CDN_MODEL_URL =
  'https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task';

const KEY_LANDMARK_INDICES = [
  { idx: 1, label: 'noseTip' },
  { idx: 10, label: 'forehead' },
  { idx: 152, label: 'chin' },
  { idx: 33, label: 'leftEyeOuter' },
  { idx: 133, label: 'leftEyeInner' },
  { idx: 159, label: 'leftEyeTop' },
  { idx: 145, label: 'leftEyeBottom' },
  { idx: 263, label: 'rightEyeOuter' },
  { idx: 362, label: 'rightEyeInner' },
  { idx: 386, label: 'rightEyeTop' },
  { idx: 374, label: 'rightEyeBottom' },
  { idx: 61, label: 'mouthLeft' },
  { idx: 291, label: 'mouthRight' },
  { idx: 234, label: 'rightCheek' },
  { idx: 454, label: 'leftCheek' },
];

class Date2WebFaceScannerEngine {
  constructor() {
    this._containers = new Map();
    this._activeStream = null;
    this._activeVideo = null;
    this._landmarker = null;
    this._landmarkerPromise = null;
    this._rafId = null;
    this._sessionToken = 0;
    this._lastProcessMs = 0;
    this._lastVideoTimeMs = -1;

    this._lumaCanvas = document.createElement('canvas');
    this._lumaCanvas.width = 64;
    this._lumaCanvas.height = 48;
    this._lumaCtx = this._lumaCanvas.getContext('2d', {
      willReadFrequently: true,
    });
  }

  createViewElement(containerId) {
    const wrapper = document.createElement('div');
    wrapper.id = containerId;
    wrapper.style.width = '100%';
    wrapper.style.height = '100%';
    wrapper.style.position = 'relative';
    wrapper.style.overflow = 'hidden';
    wrapper.style.backgroundColor = '#0E1018';
    wrapper.style.pointerEvents = 'none';

    const video = document.createElement('video');
    video.autoplay = true;
    video.playsInline = true;
    video.muted = true;
    video.setAttribute('autoplay', '');
    video.setAttribute('playsinline', '');
    video.setAttribute('muted', '');
    video.style.width = '100%';
    video.style.height = '100%';
    video.style.objectFit = 'cover';
    video.style.transform = 'scaleX(-1)';
    video.style.display = 'block';
    video.style.pointerEvents = 'none';

    wrapper.appendChild(video);
    this._containers.set(containerId, { wrapper, video });
    return wrapper;
  }

  async _ensureLandmarker() {
    if (this._landmarker) return this._landmarker;
    if (this._landmarkerPromise) return this._landmarkerPromise;

    this._landmarkerPromise = (async () => {
      let visionPkg;
      let wasmBase = LOCAL_WASM_DIR;
      let modelPath = LOCAL_MODEL_URL;

      try {
        visionPkg = await import(LOCAL_BUNDLE_URL);
      } catch (_) {
        visionPkg = await import(CDN_BUNDLE_URL);
        wasmBase = CDN_WASM_DIR;
        modelPath = CDN_MODEL_URL;
      }

      const { FilesetResolver, FaceLandmarker } = visionPkg;
      let fileset;
      try {
        fileset = await FilesetResolver.forVisionTasks(wasmBase);
      } catch (_) {
        fileset = await FilesetResolver.forVisionTasks(CDN_WASM_DIR);
        modelPath = CDN_MODEL_URL;
      }

      const baseConfig = {
        runningMode: 'VIDEO',
        numFaces: 2,
        outputFaceBlendshapes: true,
        outputFacialTransformationMatrixes: true,
        minFaceDetectionConfidence: 0.5,
        minFacePresenceConfidence: 0.5,
        minTrackingConfidence: 0.5,
      };

      for (const delegate of ['GPU', 'CPU']) {
        try {
          const instance = await FaceLandmarker.createFromOptions(fileset, {
            ...baseConfig,
            baseOptions: { modelAssetPath: modelPath, delegate },
          });
          this._landmarker = instance;
          return instance;
        } catch (err) {
          if (delegate === 'CPU') {
            if (modelPath !== CDN_MODEL_URL) {
              const cdnInstance = await FaceLandmarker.createFromOptions(
                fileset,
                {
                  ...baseConfig,
                  baseOptions: {
                    modelAssetPath: CDN_MODEL_URL,
                    delegate: 'CPU',
                  },
                }
              );
              this._landmarker = cdnInstance;
              return cdnInstance;
            }
            throw err;
          }
        }
      }
      throw new Error('Failed to create MediaPipe FaceLandmarker.');
    })();

    try {
      return await this._landmarkerPromise;
    } catch (err) {
      this._landmarkerPromise = null;
      throw err;
    }
  }

  async start(containerId, onFrameJson, onStatus) {
    await this.stop();
    const myToken = ++this._sessionToken;

    const emitStatus = (code, message) => {
      if (myToken !== this._sessionToken) return;
      if (typeof onStatus === 'function') {
        onStatus(String(code), String(message || ''));
      }
    };

    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      emitStatus(
        'unavailable',
        'Browser camera API (getUserMedia) is unavailable here. Use Chrome on http://localhost or https://.'
      );
      return;
    }

    emitStatus('requesting_permission', 'Requesting webcam permission in Chrome...');

    let stream = null;
    try {
      stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'user',
          width: { ideal: 640 },
          height: { ideal: 480 },
        },
        audio: false,
      });
    } catch (err) {
      if (err && err.name === 'OverconstrainedError') {
        try {
          stream = await navigator.mediaDevices.getUserMedia({
            video: true,
            audio: false,
          });
        } catch (fallbackErr) {
          this._handleGetUserMediaError(fallbackErr, emitStatus);
          return;
        }
      } else {
        this._handleGetUserMediaError(err, emitStatus);
        return;
      }
    }

    if (myToken !== this._sessionToken) {
      this._stopMediaStream(stream);
      return;
    }

    const entry = await this._waitForContainer(containerId, myToken);
    if (!entry || myToken !== this._sessionToken) {
      this._stopMediaStream(stream);
      return;
    }

    this._activeStream = stream;
    this._activeVideo = entry.video;
    entry.video.srcObject = stream;

    for (const track of stream.getTracks()) {
      track.addEventListener('ended', () => {
        if (myToken === this._sessionToken) {
          emitStatus(
            'interrupted',
            'Webcam stream ended or was disconnected. Tap Retry to resume.'
          );
          this.stop();
        }
      });
    }

    try {
      await entry.video.play();
    } catch (_) {
      // Wait for metadata if play resolved lazily
    }

    if (myToken !== this._sessionToken) {
      await this.stop();
      return;
    }

    emitStatus('loading_model', 'Loading MediaPipe Face Landmarker (Demo Mode)...');

    try {
      await this._ensureLandmarker();
    } catch (err) {
      emitStatus(
        'model_error',
        `Could not initialize browser MediaPipe Face Landmarker: ${err?.message || err}`
      );
      await this.stop();
      return;
    }

    if (myToken !== this._sessionToken) {
      await this.stop();
      return;
    }

    emitStatus('ready', 'Webcam & MediaPipe Face Landmarker active (Demo Mode).');
    this._lastProcessMs = 0;
    this._lastVideoTimeMs = -1;
    this._scheduleLoop(myToken, onFrameJson);
  }

  _handleGetUserMediaError(err, emitStatus) {
    const name = err?.name || '';
    if (
      name === 'NotAllowedError' ||
      name === 'PermissionDeniedError' ||
      name === 'SecurityError'
    ) {
      emitStatus(
        'permission_denied',
        'Camera permission was denied in Chrome. Allow webcam access in the address bar or retry.'
      );
    } else if (
      name === 'NotFoundError' ||
      name === 'DevicesNotFoundError'
    ) {
      emitStatus(
        'unavailable',
        'No webcam device found on this laptop/computer.'
      );
    } else if (
      name === 'NotReadableError' ||
      name === 'TrackStartError' ||
      name === 'AbortError'
    ) {
      emitStatus(
        'unavailable',
        'Webcam could not be opened (it may be in use by another application).'
      );
    } else {
      emitStatus(
        'unavailable',
        `Unable to access webcam (${name || 'Error'}): ${err?.message || 'Unknown error'}`
      );
    }
  }

  async _waitForContainer(containerId, token) {
    for (let i = 0; i < 30; i++) {
      if (token !== this._sessionToken) return null;
      const found = this._containers.get(containerId);
      if (found) return found;
      await new Promise((r) => setTimeout(r, 50));
    }
    return this._containers.get(containerId) || null;
  }

  _scheduleLoop(token, onFrameJson) {
    const tick = () => {
      if (token !== this._sessionToken) return;
      const video = this._activeVideo;
      const landmarker = this._landmarker;

      const nowMs = performance.now();
      if (
        video &&
        landmarker &&
        video.readyState >= 2 &&
        video.videoWidth > 0 &&
        !video.paused &&
        nowMs - this._lastProcessMs >= 95
      ) {
        this._lastProcessMs = nowMs;
        try {
          const payload = this._analyzeVideoFrame(video, landmarker, nowMs);
          if (payload && typeof onFrameJson === 'function') {
            onFrameJson(JSON.stringify(payload));
          }
        } catch (_) {
          // Drop transient single-frame detection errors safely
        }
      }

      if (token === this._sessionToken) {
        this._rafId = window.requestAnimationFrame(tick);
      }
    };

    this._rafId = window.requestAnimationFrame(tick);
  }

  _estimateAmbientLuma(video) {
    if (!this._lumaCtx || video.videoWidth <= 0 || video.videoHeight <= 0) {
      return 128.0;
    }
    this._lumaCtx.drawImage(video, 0, 0, 64, 48);
    const imgData = this._lumaCtx.getImageData(0, 0, 64, 48);
    const pixels = imgData.data;
    let sum = 0;
    let count = 0;
    for (let i = 0; i + 2 < pixels.length; i += 8) {
      sum += 0.299 * pixels[i] + 0.587 * pixels[i + 1] + 0.114 * pixels[i + 2];
      count++;
    }
    return count === 0 ? 0.0 : sum / count;
  }

  _dist2d(a, b) {
    const dx = (a.x || 0) - (b.x || 0);
    const dy = (a.y || 0) - (b.y || 0);
    return Math.hypot(dx, dy);
  }

  _clamp(v, minV, maxV) {
    return Math.max(minV, Math.min(maxV, v));
  }

  _extractBlendshape(categories, name) {
    if (!Array.isArray(categories)) return null;
    for (let i = 0; i < categories.length; i++) {
      if (categories[i].categoryName === name) {
        return categories[i].score;
      }
    }
    return null;
  }

  _analyzeVideoFrame(video, landmarker, nowMs) {
    const meanLuma = this._estimateAmbientLuma(video);
    const tsMs = Math.max(this._lastVideoTimeMs + 1, Math.round(nowMs));
    this._lastVideoTimeMs = tsMs;

    const results = landmarker.detectForVideo(video, tsMs);
    const faces = results?.faceLandmarks || [];
    const faceCount = faces.length;

    if (faceCount === 0) {
      return {
        hasFace: false,
        faceCount: 0,
        meanLuma,
        widthRatio: 0.0,
        centerX: 0.5,
        centerY: 0.5,
        headYawDeg: 0.0,
        leftEyeOpen: 1.0,
        rightEyeOpen: 1.0,
        landmarks: [],
      };
    }

    if (faceCount > 1) {
      return {
        hasFace: true,
        faceCount,
        meanLuma,
        widthRatio: 0.0,
        centerX: 0.5,
        centerY: 0.5,
        headYawDeg: 0.0,
        leftEyeOpen: 1.0,
        rightEyeOpen: 1.0,
        landmarks: [],
      };
    }

    const lm = faces[0];
    let minX = 1.0;
    let maxX = 0.0;
    let minY = 1.0;
    let maxY = 0.0;

    for (let i = 0; i < lm.length; i++) {
      const pt = lm[i];
      if (pt.x < minX) minX = pt.x;
      if (pt.x > maxX) maxX = pt.x;
      if (pt.y < minY) minY = pt.y;
      if (pt.y > maxY) maxY = pt.y;
    }

    const widthRatio = Math.max(0.0, maxX - minX);
    const centerX = (minX + maxX) / 2.0;
    const centerY = (minY + maxY) / 2.0;

    // Eye openness computed directly from MediaPipe eye landmarks + eye blink blendshapes
    const leftVert =
      (this._dist2d(lm[159], lm[145]) + this._dist2d(lm[158], lm[153])) / 2.0;
    const leftHoriz = Math.max(1e-4, this._dist2d(lm[33], lm[133]));
    const earLeft = leftVert / leftHoriz;

    const rightVert =
      (this._dist2d(lm[386], lm[374]) + this._dist2d(lm[385], lm[380])) / 2.0;
    const rightHoriz = Math.max(1e-4, this._dist2d(lm[362], lm[263]));
    const earRight = rightVert / rightHoriz;

    const earLeftOpen = this._clamp((earLeft - 0.14) / 0.14, 0.0, 1.0);
    const earRightOpen = this._clamp((earRight - 0.14) / 0.14, 0.0, 1.0);

    const cats = results?.faceBlendshapes?.[0]?.categories;
    const blinkL = this._extractBlendshape(cats, 'eyeBlinkLeft');
    const blinkR = this._extractBlendshape(cats, 'eyeBlinkRight');

    const leftEyeOpen =
      blinkL !== null
        ? this._clamp(
            0.55 * (1.0 - blinkL * 1.2) + 0.45 * earLeftOpen,
            0.0,
            1.0
          )
        : earLeftOpen;
    const rightEyeOpen =
      blinkR !== null
        ? this._clamp(
            0.55 * (1.0 - blinkR * 1.2) + 0.45 * earRightOpen,
            0.0,
            1.0
          )
        : earRightOpen;

    // Head yaw degrees: combine MediaPipe transformation matrix magnitude with
    // nose-vs-cheek landmark asymmetry so +yaw reliably tracks user turning left
    // and -yaw reliably tracks user turning right in the mirrored webcam preview.
    const cheekMidX = (lm[234].x + lm[454].x) / 2.0;
    const halfFaceW = Math.max(0.04, Math.abs(lm[454].x - lm[234].x) / 2.0);
    const noseOffsetNorm = (lm[1].x - cheekMidX) / halfFaceW;
    const landmarkYawDeg = this._clamp(noseOffsetNorm * 45.0, -55.0, 55.0);

    let headYawDeg = landmarkYawDeg;
    const matrixData = results?.facialTransformationMatrixes?.[0]?.data;
    if (matrixData && matrixData.length >= 16) {
      // Column-major 4x4 transformation matrix: m[8] = r02, m[10] = r22
      const matrixYawRad = Math.atan2(matrixData[8], matrixData[10]);
      const matrixYawAbsDeg = Math.abs((matrixYawRad * 180.0) / Math.PI);
      const sign =
        Math.abs(noseOffsetNorm) >= 0.03
          ? Math.sign(noseOffsetNorm)
          : Math.sign(-matrixYawRad || 1);
      headYawDeg = sign * Math.max(matrixYawAbsDeg, Math.abs(landmarkYawDeg));
    }

    const displayLandmarks = [];
    for (let i = 0; i < KEY_LANDMARK_INDICES.length; i++) {
      const item = KEY_LANDMARK_INDICES[i];
      const pt = lm[item.idx];
      if (pt) {
        displayLandmarks.push({
          x: this._clamp(pt.x, 0.0, 1.0),
          y: this._clamp(pt.y, 0.0, 1.0),
          label: item.label,
        });
      }
    }

    return {
      hasFace: true,
      faceCount: 1,
      meanLuma,
      widthRatio,
      centerX,
      centerY,
      headYawDeg,
      leftEyeOpen,
      rightEyeOpen,
      landmarks: displayLandmarks,
    };
  }

  captureSnapshotBytes() {
    const video = this._activeVideo;
    if (!video || video.readyState < 2 || video.videoWidth <= 0) {
      return null;
    }
    const w = Math.min(640, video.videoWidth);
    const h = Math.round((w / video.videoWidth) * video.videoHeight) || 480;
    const capCanvas = document.createElement('canvas');
    capCanvas.width = w;
    capCanvas.height = h;
    const ctx = capCanvas.getContext('2d');
    if (!ctx) return null;

    ctx.drawImage(video, 0, 0, w, h);
    const dataUrl = capCanvas.toDataURL('image/jpeg', 0.85);
    ctx.clearRect(0, 0, w, h);
    capCanvas.width = 0;
    capCanvas.height = 0;

    const commaIdx = dataUrl.indexOf(',');
    if (commaIdx < 0) return null;
    const raw = window.atob(dataUrl.slice(commaIdx + 1));
    const bytes = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) {
      bytes[i] = raw.charCodeAt(i);
    }
    return bytes;
  }

  _stopMediaStream(stream) {
    if (!stream) return;
    for (const track of stream.getTracks()) {
      try {
        track.stop();
      } catch (_) {}
    }
  }

  async stop() {
    this._sessionToken++;
    if (this._rafId !== null) {
      window.cancelAnimationFrame(this._rafId);
      this._rafId = null;
    }
    if (this._activeStream) {
      this._stopMediaStream(this._activeStream);
      this._activeStream = null;
    }
    if (this._activeVideo) {
      try {
        this._activeVideo.pause();
        this._activeVideo.srcObject = null;
      } catch (_) {}
      this._activeVideo = null;
    }
    if (this._lumaCtx) {
      this._lumaCtx.clearRect(0, 0, this._lumaCanvas.width, this._lumaCanvas.height);
    }
  }

  disposeContainer(containerId) {
    this._containers.delete(containerId);
  }
}

window.Date2WebFaceScanner = new Date2WebFaceScannerEngine();
