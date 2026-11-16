import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Builds [InputImage] from a live [CameraImage] for ML Kit face detection.
InputImage? inputImageFromCameraImage(
  CameraImage image,
  InputImageRotation rotation,
) {
  if (image.width == 0 || image.height == 0) return null;

  if (Platform.isIOS) {
    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;
    // Copy — camera reuses plane.bytes; ML Kit reads async on a worker thread.
    final bytes = Uint8List.fromList(plane.bytes);
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  if (image.planes.length < 3) return null;

  final nv21 = convertYuv420ToNv21(image);
  if (nv21.isEmpty) return null;

  return InputImage.fromBytes(
    bytes: nv21,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.width,
    ),
  );
}

Uint8List convertYuv420ToNv21(CameraImage image) {
  final width = image.width;
  final height = image.height;

  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final ySize = width * height;
  final uvSize = (width * height) ~/ 4;
  final nv21 = Uint8List(ySize + uvSize * 2);

  var yDstIndex = 0;
  for (var y = 0; y < height; y++) {
    final ySrcRowStart = y * yPlane.bytesPerRow;
    for (var x = 0; x < width && yDstIndex < ySize; x++) {
      final ySrcIndex = ySrcRowStart + x;
      if (ySrcIndex < yPlane.bytes.length) {
        nv21[yDstIndex++] = yPlane.bytes[ySrcIndex];
      }
    }
  }

  var uvDstIndex = ySize;
  final uRowStride = uPlane.bytesPerRow;
  final vRowStride = vPlane.bytesPerRow;
  final uPixelStride = uPlane.bytesPerPixel ?? 1;
  final vPixelStride = vPlane.bytesPerPixel ?? 1;

  for (var y = 0; y < height ~/ 2; y++) {
    for (var x = 0; x < width ~/ 2; x++) {
      final uSrcPos = (y * uRowStride) + (x * uPixelStride);
      final vSrcPos = (y * vRowStride) + (x * vPixelStride);
      if (uSrcPos >= 0 &&
          uSrcPos < uPlane.bytes.length &&
          vSrcPos >= 0 &&
          vSrcPos < vPlane.bytes.length &&
          uvDstIndex < nv21.length - 1) {
        nv21[uvDstIndex++] = vPlane.bytes[vSrcPos];
        nv21[uvDstIndex++] = uPlane.bytes[uSrcPos];
      }
    }
  }

  return nv21;
}
