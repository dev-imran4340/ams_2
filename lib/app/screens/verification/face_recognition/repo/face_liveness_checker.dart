import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// How strict liveness is before face capture (Ported from smart_attendance)
enum FaceLivenessProfile {
  verification,
  enrollment,
}

/// Live-face check before capture (Blink check, head micro-movement, anti-spoof)
class FaceLivenessChecker {
  FaceLivenessChecker({this.profile = FaceLivenessProfile.verification});

  final FaceLivenessProfile profile;

  LivenessPhase _phase = LivenessPhase.blink;
  bool _sawEyesClosed = false;
  bool _classificationSeen = false;
  int _framesWithFace = 0;
  bool _streamLivenessPassed = false;

  final List<double> _yawHistory = [];
  static const int _maxYawHistory = 40;

  static const double _eyeClosedMax = 0.35;
  static const double _eyeOpenMin = 0.55;
  static const int _noClassificationFallbackFrames = 36;
  static const double _staticYawRangeMax = 1.2;
  static const int _photoCheckMinFrames = 28;
  static const double _headMovementRangeMin = 8.0;

  void reset() {
    _phase = LivenessPhase.blink;
    _sawEyesClosed = false;
    _classificationSeen = false;
    _framesWithFace = 0;
    _streamLivenessPassed = false;
    _yawHistory.clear();
  }

  void markStreamLivenessPassed() {
    if (_phase == LivenessPhase.ready) {
      _streamLivenessPassed = true;
    }
  }

  LivenessPhase get phase => _phase;
  bool get isReady => _phase == LivenessPhase.ready;
  bool get isLivenessInProgress => _phase != LivenessPhase.ready;

  FaceLivenessResult update(Face face) {
    _framesWithFace++;
    _recordYaw(face.headEulerAngleY);

    if (_phase == LivenessPhase.ready) {
      return _readyResult();
    }

    if (profile == FaceLivenessProfile.verification && _isLikelyPrintedPhoto()) {
      return const FaceLivenessResult(
        phase: LivenessPhase.blink,
        guidance: FaceLivenessMessages.useRealFaceNotPhoto,
        isReady: false,
        suspectedSpoof: true,
      );
    }

    switch (_phase) {
      case LivenessPhase.blink:
        return _updateBlink(face);
      case LivenessPhase.moveHead:
        return _updateMoveHead(face);
      case LivenessPhase.ready:
        return _readyResult();
    }
  }

  bool validateCaptureFace(Face face) {
    if (_streamLivenessPassed) {
      _streamLivenessPassed = false;
      return _basicFaceOk(face);
    }

    if (!_areEyesOpen(face)) {
      return false;
    }
    return _basicFaceOk(face);
  }

  bool _basicFaceOk(Face face) {
    final yaw = face.headEulerAngleY;
    if (yaw != null && yaw.abs() > 45) {
      return false;
    }
    return face.boundingBox.width > 0 && face.boundingBox.height > 0;
  }

  FaceLivenessResult _updateBlink(Face face) {
    if (_eyesClosed(face)) {
      _sawEyesClosed = true;
      return const FaceLivenessResult(
        phase: LivenessPhase.blink,
        guidance: FaceLivenessMessages.blinkNowOpen,
        isReady: false,
      );
    }

    if (_sawEyesClosed && _areEyesOpen(face)) {
      if (profile == FaceLivenessProfile.enrollment) {
        _enterMoveHeadPhase();
        return const FaceLivenessResult(
          phase: LivenessPhase.moveHead,
          guidance: FaceLivenessMessages.moveHeadSideToSide,
          isReady: false,
        );
      }
      _phase = LivenessPhase.ready;
      return _readyResult();
    }

    if (profile == FaceLivenessProfile.verification &&
        !_classificationSeen &&
        _framesWithFace >= _noClassificationFallbackFrames) {
      _phase = LivenessPhase.ready;
      return _readyResult();
    }

    if (profile == FaceLivenessProfile.enrollment &&
        !_classificationSeen &&
        _framesWithFace > 28) {
      _enterMoveHeadPhase();
      return const FaceLivenessResult(
        phase: LivenessPhase.moveHead,
        guidance: FaceLivenessMessages.moveHeadSideToSide,
        isReady: false,
      );
    }

    if (_framesWithFace <= 3) {
      return const FaceLivenessResult(
        phase: LivenessPhase.blink,
        guidance: FaceLivenessMessages.positionFace,
        isReady: false,
      );
    }

    return const FaceLivenessResult(
      phase: LivenessPhase.blink,
      guidance: FaceLivenessMessages.blinkOnce,
      isReady: false,
    );
  }

  void _enterMoveHeadPhase() {
    _phase = LivenessPhase.moveHead;
    _yawHistory.clear();
  }

  FaceLivenessResult _updateMoveHead(Face face) {
    _recordYaw(face.headEulerAngleY);
    final range = _yawRange();
    if (_yawHistory.length >= 6 && range >= _headMovementRangeMin) {
      _phase = LivenessPhase.ready;
      return _readyResult();
    }
    return const FaceLivenessResult(
      phase: LivenessPhase.moveHead,
      guidance: FaceLivenessMessages.moveHeadSideToSide,
      isReady: false,
    );
  }

  FaceLivenessResult _readyResult() {
    return const FaceLivenessResult(
      phase: LivenessPhase.ready,
      guidance: FaceLivenessMessages.holdStillForScan,
      isReady: true,
    );
  }

  bool _eyesClosed(Face face) {
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left == null || right == null) return false;
    _classificationSeen = true;
    return left <= _eyeClosedMax && right <= _eyeClosedMax;
  }

  bool _areEyesOpen(Face face) {
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left == null || right == null) return true;
    _classificationSeen = true;
    return left >= _eyeOpenMin && right >= _eyeOpenMin;
  }

  void _recordYaw(double? yaw) {
    if (yaw == null) return;
    _yawHistory.add(yaw);
    if (_yawHistory.length > _maxYawHistory) {
      _yawHistory.removeAt(0);
    }
  }

  double _yawRange() {
    if (_yawHistory.isEmpty) return 0;
    var minYaw = _yawHistory.first;
    var maxYaw = _yawHistory.first;
    for (final y in _yawHistory) {
      if (y < minYaw) minYaw = y;
      if (y > maxYaw) maxYaw = y;
    }
    return maxYaw - minYaw;
  }

  bool _isLikelyPrintedPhoto() {
    if (!_classificationSeen) return false;
    if (_sawEyesClosed) return false;
    if (_framesWithFace < _photoCheckMinFrames) return false;
    return _yawRange() < _staticYawRangeMax;
  }
}

enum LivenessPhase { blink, moveHead, ready }

class FaceLivenessResult {
  final LivenessPhase phase;
  final String guidance;
  final bool isReady;
  final bool suspectedSpoof;

  const FaceLivenessResult({
    required this.phase,
    required this.guidance,
    required this.isReady,
    this.suspectedSpoof = false,
  });
}

class FaceLivenessMessages {
  static const positionFace = 'Position your face in the oval';
  static const blinkOnce = 'Blink once naturally';
  static const blinkNowOpen = 'Good — open your eyes';
  static const moveHeadSideToSide = 'Slowly turn your head left, then right';
  static const holdStillForScan = 'Hold still — scanning…';
  static const useRealFaceNotPhoto = 'Use your live face, not a photo on another screen';
  static const captureNotLive = 'Live face required — blink once and try again';
  static const faceDidNotMatch =
      'Your face did not match the saved photo. Please try again in good lighting.';
  static const uploadFailed = 'Could not save your face photo. Please try again.';
}
