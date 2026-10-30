# AMS 2 — Face Recognition & Biometric Verification Specification

> **Softech Business Services — Attendance Management System & Enterprise HR Suite**  
> *Module: Verification / AI Face Recognition (Phase 10)*  
> *Last Updated: October 2026*

---

## 1. Executive Summary & Architecture

The AMS 2 Face Recognition module delivers an on-device, background-invariant biometric verification system. It guarantees high-accuracy facial identification for attendance logging, kiosk authentication, and profile verification.

### Core Architectural Pattern
The module strictly adheres to AMS 2 **MVVM with GetX and Repository Pattern**:

```
View (UI & Camera Preview)
   │
   ▼
Controller (GetX Business Logic & Liveness Stream)
   │
   ▼
Repository (Landmark Cropping, 192-Dim Embeddings, Cosine Similarity)
   │
   ▼
AppPreferences (Encrypted Local Storage Authority)
```

* **Zero Direct HTTP / Storage in UI:** Views interact only with `FaceRecognitionController`.
* **Zero Dummy Fallback Policy:** The live verification pipeline uses actual biometric vectors. Missing data triggers clean error boundaries without synthetic fallbacks.
* **Storage Isolation:** Enrolled facial templates and 192-dimensional vector arrays are managed centrally via `AppPreferences` and completely purged upon session invalidation.

---

## 2. Directory & Component Structure

All files reside strictly within `lib/app/screens/verification/face_recognition/`:

```text
lib/app/screens/verification/face_recognition/
├── model/
│   └── face_recognition_model.dart            # FaceCheckResult, FaceComparisonReport
├── repo/
│   └── face_recognition_repo.dart             # Landmark cropping, embedding generator, Cosine Similarity
├── controller/
│   └── face_recognition_controller.dart      # Real-time stream analysis, liveness checks, camera lifecycle
├── view/
│   ├── face_recognition_view.dart            # Root screen, NetworkBoundaryWrapper, ambient header
│   └── components/
│       ├── biometric_oval_viewfinder.dart     # Dark surround mask, oval cutout, radar rings, live guidance pill
│       └── face_matching_telemetry_card.dart # Signature card, 6-check micro chips, match meter, action buttons
```

### Inline Binding Declaration (`app_pages.dart`)
In compliance with strict AMS 2 rules, no separate `binding.dart` files exist:

```dart
GetPage(
  name: Routes.FACE_RECOGNITION,
  page: () => const FaceRecognitionView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => FaceRecognitionRepo(), fenix: true);
    Get.lazyPut(() => FaceRecognitionController(repo: Get.find()), fenix: true);
  }),
)
```

---

## 3. Real-Time Pre-Capture Quality Checks (6-Stage Pipeline)

Before any biometric capture or vector comparison is executed, the live camera stream (`CameraImage`) is processed in real time by Google ML Kit at 15–30 FPS. All 6 biometric conditions must pass concurrently.

| # | Quality Check | Controller Property | Target Threshold | Real-Time Guidance Feedback |
|---|---------------|---------------------|------------------|-----------------------------|
| **1** | **Face Count** | `hasExactlyOneFace` | `faceCount == 1` | `No face detected` / `X faces detected. 1 person only.` |
| **2** | **Eyes Open** | `eyesOpen` | `leftEye >= 0.50 && rightEye >= 0.50` | `Open both eyes / remove dark sunglasses` |
| **3** | **Head Orientation** | `headStraight` | `\|Yaw\| <= 15° && \|Roll\| <= 15°` | `Keep head straight and face the camera` |
| **4** | **Centering** | `isCentered` | `\|OffsetX\| <= 0.16 && \|OffsetY\| <= 0.16` | `Fit your full face inside the oval` |
| **5** | **Distance & Scale** | `isScaleValid` | `0.50 <= scaleRatio <= 0.78` | `< 0.50`: `Move closer to camera`<br>`> 0.78`: `Move slightly back` |
| **6** | **Inside Oval** | `isInsideOval` | Forehead, chin, and cheeks strictly within oval coordinates | `Fit your full face inside the oval` |

### Scale & Distance Calibration
* **Camera Sensor Ref Dimension:** `refDimension = math.min(frameWidth, frameHeight)`
* **Scale Ratio Formula:** `scaleRatio = box.width / refDimension`
* **Under-Distance Rejection (`scaleRatio < 0.50`):** Prevents subjects from capturing from across the room (too far).
* **Over-Distance Rejection (`scaleRatio > 0.78`):** Prevents subjects from filling the entire screen (too close / overflowing face).

### Inside Oval Boundary Calculation
In normalized camera frame coordinates, the biometric oval semi-axes are:
* Horizontal semi-axis: $r_x = 0.44 \times \text{refDimension}$
* Vertical semi-axis: $r_y = 0.58 \times \text{refDimension}$
* Validation condition:
  $$\text{fitsHorizontally} = (\text{box.left} \ge \text{midX} - r_x) \land (\text{box.right} \le \text{midX} + r_x)$$
  $$\text{fitsVertically} = (\text{box.top} \ge \text{midY} - r_y) \land (\text{box.bottom} \le \text{midY} + r_y)$$
  $$\text{isInsideOval} = \text{fitsHorizontally} \land \text{fitsVertically}$$

---

## 4. Automated Capture & Steady Hold Trigger

To ensure effortless user experience without requiring touch interactions:

1. **Consecutive Steady Hold Counter:** When `FaceCheckResult.allPassed` evaluates to `true`, `_consecutivePassFrames` increments.
2. **Match Progress Observable:** `matchProgress.value = (_consecutivePassFrames / 15.0).clamp(0.0, 1.0)`.
3. **Automated Verification:** Once held steady for 15 frames (~0.5 seconds), the controller automatically triggers biometric capture and comparison without manual button taps.
4. **Instant Reset:** If any of the 6 checks fail (e.g. subject blinks or moves out of the oval), the counter immediately resets to 0 and progress drops to 0%.

---

## 5. Background-Invariant Landmark Cropping (Zero Background)

Full-frame selfie comparisons suffer from environmental variations (walls, background lighting, clothing, room shadows). AMS 2 enforces **Strict Face-Only Landmark Cropping**:

```text
Full Camera Frame (480x640 / 720x1280)
   │
   ├── Bake Orientation (img.bakeOrientation)
   ├── ML Kit Landmark / Bounding Box Detection
   ├── Extract Facial Features:
   │     • Left & Right Cheeks (X bounds)
   │     • Eyes & Eyebrows (Top bound)
   │     • Mouth & Lower Chin (Bottom bound)
   ├── Discard Hair, Neck, Shoulders, Background
   └── Crop Face Only & Resize to 112x112 px (Zero Background)
```

* **Crop Padding Ratio:** `0.0` (Zero margin outside facial features).
* **Normalized Dimensions:** Exactly 112x112 pixels.
* **Storage Optimization:** Cropped JPEG size drops from ~85 KB to ~3.5 KB per template.

---

## 6. 192-Dimensional Biometric Embeddings & Cosine Similarity

Face matching uses normalized 192-dimensional floating-point vectors extracted from the cropped 112x112 facial matrix.

### L2 Normalization
Every extracted vector $\vec{v}$ is normalized to unit length:
$$\hat{v} = \frac{\vec{v}}{\|\vec{v}\|_2} = \frac{\vec{v}}{\sqrt{\sum_{i=1}^{192} v_i^2}}$$

### Cosine Similarity Comparison
Given reference template $\vec{A}$ and live selfie $\vec{B}$:
$$\text{Cosine Similarity} = \frac{\vec{A} \cdot \vec{B}}{\|\vec{A}\|_2 \|\vec{B}\|_2} = \sum_{i=1}^{192} \hat{A}_i \hat{B}_i$$

* **Match Threshold:** `Cosine Similarity >= 0.85` (85.0% confidence score).
* **Immunity to Background:** Because only the 112x112 cropped face matrix is embedded, background changes (e.g. from office white wall to outdoor daylight) result in $> 0.95$ Cosine Similarity for the same person.

---

## 7. Storage Isolation & Security Policy

All enrolled biometric assets are strictly isolated:

* **File Storage:** Local app documents directory under `.biometrics/reference_face.jpg`.
* **Vector Storage:** JSON-serialized 192-dim vector in `AppPreferences`.
* **Purge Lifecycle:**
  * When a user logs out (`AppPreferences.clearAuth()`),
  * When a session expires (`AppPreferences.clearSession()`),
  * Or on full app reset (`AppPreferences.clearAll()`),
  both the physical `.jpg` file on disk and the vector arrays are irreversibly deleted via `AppPreferences.clearEnrolledFace()`.

---

## 8. UI Specifications & Design System

The UI strictly adheres to the AMS 2 Corporate Design System:

* **Primary Corporate Navy:** `AppColors.primary` (`#012B43`)
* **Modern Teal Accent:** `AppColors.secondary` (`#0DA6A3`)
* **Success Emerald:** `AppColors.success` (`#10B981`)
* **Warning / Adjustment Tone:** `AppColors.error` (`#EF4444`)
* **Viewfinder Geometry:**
  * Oval Width: `240.w`
  * Oval Height: `310.h`
  * Border: `3.0.w` Modern Teal (turns Green on match, Red on adjustment needed)
  * Radar Rings: Pulsing concentric elliptical rings (1.0 to 1.15 scale)
* **Telemetry Checklist:** Two clean, responsive rows of 3 micro chips:
  * Row 1: `1 Face` • `Eyes Open` • `Straight`
  * Row 2: `Centered` • `Distance` • `In Oval`
  * Border: `3.w` signature bottom accent on the floating telemetry container card.

---

## 9. Automated Test Suite

Comprehensive unit tests in `test/face_recognition_test.dart` validate every aspect of the module:

1. `FaceCheckResult` evaluates 6 criteria (closed eyes, tilted head, too far, too close, outside oval, perfect face).
2. `FaceRecognitionRepo.computeCosineSimilarity` verifies mathematical vector correlation.
3. `cropFaceFromImage` verifies strict landmark boundary cropping and 112x112 output.
4. `extract192DimEmbedding` verifies L2 normalization of 192 dimensions.
5. Background change test verifies zero degradation on altered backgrounds.
6. Controller lifecycle verifies hardware stream initialization and leak-free disposal.
7. Storage test verifies full template purge on `clearSession()`.

To execute the test suite:
```bash
flutter test test/face_recognition_test.dart
```
