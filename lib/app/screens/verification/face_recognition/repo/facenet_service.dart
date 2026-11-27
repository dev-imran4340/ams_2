import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

/// FaceNet MobileFaceNet Service
/// Generates 192-dimensional embeddings via TFLite and matches using Euclidean distance.
class FaceNetService {
  static final FaceNetService _instance = FaceNetService._internal();

  factory FaceNetService() {
    return _instance;
  }

  FaceNetService._internal() {
    threshold = 0.85; // Strict MobileFaceNet Euclidean distance threshold to prevent false positives
  }

  static const String modelAssetPath = 'assets/models/mobilefacenet.tflite';

  late double threshold;
  double? lastDistance;
  Interpreter? _interpreter;
  List<double>? _predictedData;
  List<double>? _referenceEmbedding;
  Future<void>? _loadingFuture;
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;
  bool get hasReferenceEmbedding =>
      _referenceEmbedding != null && _referenceEmbedding!.isNotEmpty;
  List<double>? get predictedData => _predictedData;
  List<double>? get referenceEmbedding => _referenceEmbedding;

  void setThreshold(double value) {
    threshold = value;
  }

  void setReferenceEmbedding(List<double> data) {
    _referenceEmbedding = List<double>.from(data);
  }

  Future<void> loadModel() async {
    if (_isModelLoaded && _interpreter != null) return;

    if (_loadingFuture != null) {
      await _loadingFuture;
      return;
    }

    _loadingFuture = _loadModelInternal();
    await _loadingFuture!.whenComplete(() => _loadingFuture = null);
  }

  Future<void> _loadModelInternal() async {
    try {
      if (await _tryLoadInterpreter(useGpu: Platform.isAndroid)) {
        debugPrint('>>> [AI FaceNet] MobileFaceNet model loaded successfully');
        return;
      }
      debugPrint('>>> [AI FaceNet] GPU load skipped/failed — falling back to CPU');
      if (await _tryLoadInterpreter(useGpu: false)) {
        return;
      }
      _isModelLoaded = false;
    } catch (e) {
      _isModelLoaded = false;
      debugPrint('>>> [AI FaceNet] Failed to load MobileFaceNet model: $e');
    }
  }

  Future<bool> _tryLoadInterpreter({required bool useGpu}) async {
    try {
      final options = InterpreterOptions()..threads = 1;
      if (useGpu && Platform.isAndroid) {
        try {
          options.addDelegate(GpuDelegateV2(options: GpuDelegateOptionsV2()));
        } catch (_) {}
      }

      _interpreter?.close();
      _interpreter = await Interpreter.fromAsset(
        modelAssetPath,
        options: options,
      );
      _isModelLoaded = true;
      return true;
    } catch (e) {
      debugPrint('>>> [AI FaceNet] Interpreter.fromAsset failed (gpu=$useGpu): $e');
      _isModelLoaded = false;
      return false;
    }
  }

  void _runInterpreter(List input, List output) {
    final interpreter = _interpreter;
    if (interpreter == null || !_isModelLoaded) {
      throw StateError('FaceNet interpreter is not loaded');
    }
    interpreter.run(input, output);
  }

  /// Extracts 192-dimensional MobileFaceNet embedding from raw image bytes and detected Face
  List<double> extractEmbeddingFromUint8List(
    Uint8List imageBytes,
    Face face, {
    bool flipHorizontal = false,
  }) {
    if (!_isModelLoaded || _interpreter == null) {
      throw Exception('FaceNet model is not loaded');
    }

    List input = _preProcessUint8(
      imageBytes,
      face,
      flipHorizontal: flipHorizontal,
    );
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List<double>.filled(192, 0.0));
    _runInterpreter(input, output);
    output = output.reshape([192]);
    return List<double>.from(output);
  }

  /// Alias matching smart_attendance setCurrentPredictionFromUint8List
  List<double> setCurrentPredictionFromUint8List(
    Uint8List imageBytes,
    Face face, {
    bool flipHorizontal = false,
  }) =>
      extractEmbeddingFromUint8List(
        imageBytes,
        face,
        flipHorizontal: flipHorizontal,
      );

  /// Pre-processes Uint8List image: orient upright, square crop centered on face, resize to 112x112, normalize
  List _preProcessUint8(
    Uint8List imageBytes,
    Face faceDetected, {
    bool flipHorizontal = false,
  }) {
    imglib.Image croppedImage = _cropUint8Face(imageBytes, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, size: 112);

    if (flipHorizontal) {
      img = imglib.copyFlip(img, direction: imglib.FlipDirection.horizontal);
    }

    return imageToByteListFloat32(img);
  }

  /// Crops the face from Uint8List image with +10px margins, exactly as smart_attendance
  imglib.Image _cropUint8Face(Uint8List image, Face faceDetected) {
    final imglib.Image? decoded = imglib.decodeImage(image);
    if (decoded == null) {
      throw Exception('Could not decode profile image for FaceNet');
    }
    imglib.Image convertedImage = imglib.bakeOrientation(decoded);

    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 20.0; // +10 left and right
    double h = faceDetected.boundingBox.height + 20.0;

    int cropX = x.clamp(0, convertedImage.width - 1).round();
    int cropY = y.clamp(0, convertedImage.height - 1).round();
    int cropW = w.clamp(0, convertedImage.width - cropX).round();
    int cropH = h.clamp(0, convertedImage.height - cropY).round();

    return imglib.copyCrop(
      convertedImage,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );
  }

  /// Converts a live stream CameraImage to an imglib Image buffer
  imglib.Image? convertCameraImageRaw(CameraImage image) => _convertCameraImage(image);

  imglib.Image? _convertCameraImage(CameraImage image) {
    try {
      if (Platform.isIOS) {
        if (image.planes.isNotEmpty) {
          final bytes = image.planes[0].bytes;
          final img = imglib.Image.fromBytes(
            width: image.width,
            height: image.height,
            bytes: bytes.buffer,
            order: imglib.ChannelOrder.bgra,
          );
          return img;
        }
      } else {
        // Android: Supports NV21 (1 or 2 planes) and YUV420 (3 planes)
        final int width = image.width;
        final int height = image.height;
        final img = imglib.Image(width: width, height: height);

        if (image.planes.length == 1) {
          // NV21 single plane: Y of size width*height, followed by interleaved VU
          final bytes = image.planes[0].bytes;
          final int ySize = width * height;
          for (int y = 0; y < height; y++) {
            final int yRow = y * width;
            final int uvRow = ySize + (y ~/ 2) * width;
            for (int x = 0; x < width; x++) {
              final int yIndex = yRow + x;
              final int uvIndex = uvRow + (x & ~1);
              if (yIndex >= bytes.length || uvIndex + 1 >= bytes.length) continue;

              final int yp = bytes[yIndex];
              final int vp = bytes[uvIndex];
              final int up = bytes[uvIndex + 1];

              final int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
              final int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
                  .round()
                  .clamp(0, 255);
              final int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

              img.setPixelRgb(x, y, r, g, b);
            }
          }
          return imglib.copyRotate(img, angle: -90);
        } else if (image.planes.length == 2) {
          // NV21 2 planes: Plane 0 is Y, Plane 1 is interleaved VU
          final yBytes = image.planes[0].bytes;
          final uvBytes = image.planes[1].bytes;
          final int uvRowStride = image.planes[1].bytesPerRow;
          final int uvPixelStride = image.planes[1].bytesPerPixel ?? 2;

          for (int y = 0; y < height; y++) {
            final int yRow = y * width;
            final int uvRow = (y ~/ 2) * uvRowStride;
            for (int x = 0; x < width; x++) {
              final int yIndex = yRow + x;
              final int uvIndex = uvRow + (x ~/ 2) * uvPixelStride;
              if (yIndex >= yBytes.length || uvIndex + 1 >= uvBytes.length) continue;

              final int yp = yBytes[yIndex];
              final int vp = uvBytes[uvIndex];
              final int up = uvBytes[uvIndex + 1];

              final int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
              final int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
                  .round()
                  .clamp(0, 255);
              final int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

              img.setPixelRgb(x, y, r, g, b);
            }
          }
          return imglib.copyRotate(img, angle: -90);
        } else if (image.planes.length >= 3) {
          // YUV420 3 planes
          final int uvRowStride = image.planes[1].bytesPerRow;
          final int? uvPixelStride = image.planes[1].bytesPerPixel;

          if (uvPixelStride != null) {
            for (int y = 0; y < height; y++) {
              final int yRow = y * width;
              final int uvRow = uvRowStride * (y ~/ 2);
              for (int x = 0; x < width; x++) {
                final int uvIndex = uvPixelStride * (x ~/ 2) + uvRow;
                final int index = yRow + x;

                if (index >= image.planes[0].bytes.length ||
                    uvIndex >= image.planes[1].bytes.length ||
                    uvIndex >= image.planes[2].bytes.length) {
                  continue;
                }

                final int yp = image.planes[0].bytes[index];
                final int up = image.planes[1].bytes[uvIndex];
                final int vp = image.planes[2].bytes[uvIndex];

                final int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
                final int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
                    .round()
                    .clamp(0, 255);
                final int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

                img.setPixelRgb(x, y, r, g, b);
              }
            }
            return imglib.copyRotate(img, angle: -90);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('>>> [AI FaceNet] _convertCameraImage error: $e');
      return null;
    }
  }

  /// Converts 112x112 image to normalized Float32List following MobileFaceNet convention: (x - 127.5) / 128.0
  Float32List imageToByteListFloat32(imglib.Image image) {
    final convertedBytes = Float32List(1 * 112 * 112 * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        final pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }

    return convertedBytes.buffer.asFloat32List();
  }

  /// Matches live predicted vector against reference vector using Euclidean distance
  bool predict({List<double>? liveVector, List<double>? referenceVector}) {
    final live = liveVector ?? _predictedData;
    final ref = referenceVector ?? _referenceEmbedding;

    if (live == null || live.isEmpty || ref == null || ref.isEmpty) {
      debugPrint('>>> [AI FaceNet] Cannot match: live or reference vector is empty');
      return false;
    }

    final double dist = euclideanDistance(ref, live);
    lastDistance = dist;
    debugPrint('>>> [AI FaceNet] Euclidean Distance: $dist (Threshold: $threshold)');

    final bool isMatch = dist <= threshold;
    debugPrint('>>> [AI FaceNet] Verdict: ${isMatch ? "MATCHED" : "MISMATCH"}');
    return isMatch;
  }

  /// Euclidean distance calculation
  double euclideanDistance(List<double> e1, List<double> e2) {
    if (e1.length != e2.length) return 999.0;
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}
