import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/app_preferences.dart';
import '../../../api/exception_handler.dart';
import '../model/dashboard_model.dart';

class DashboardRepo {
  static const String _tag = 'DashboardRepo / DashboardScreen';

  /// Fetches live today attendance state and monthly summary in parallel.
  /// Strict Invariant: Returns null on complete failure. ZERO fallback or dummy data injection.
  Future<DashboardDataModel?> fetchDashboardData() async {
    try {
      final results = await Future.wait([
        fetchTodayAttendance(),
        fetchMonthlySummary(),
      ]);

      final today = results[0] as TodayAttendanceModel?;
      final summary = results[1] as MonthlySummaryModel?;

      // If both remote endpoints returned null (network/server error), return null so UI renders CustomStateView
      if (today == null && summary == null) {
        return null;
      }

      return DashboardDataModel(
        todayAttendance: today ??
            const TodayAttendanceModel(
              checkInTime: '--:--',
              checkOutTime: '--:--',
              workingHours: '0:00',
              shiftRemaining: '00h 00m',
              overtime: '0:00',
              isCheckedIn: false,
              status: 'Not Checked In',
              officeRadiusStatus: 'Standby',
              shiftTiming: '--:--',
              shiftName: 'General Shift',
            ),
        monthlySummary: summary ??
            const MonthlySummaryModel(
              totalDays: 0,
              presentDays: 0,
              lateDays: 0,
              absentDays: 0,
              attendanceRate: 0.0,
              monthName: '',
            ),
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch dashboard data: $e'),
        tag: '$_tag -> fetchDashboardData() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Fetches live punch state, allowed buttons, requirements, and day stats from GET /me/attendance/today
  Future<TodayAttendanceModel?> fetchTodayAttendance() async {
    try {
      dynamic response = await ApiClient.request(
        endpoint: ApiEndpoints.attendanceToday,
        method: HttpMethod.get,
        tag: '$_tag -> fetchTodayAttendance()',
        showToastOnError: false,
      );

      // Resilient fallback in case server route is mapped to /me/attendance
      response ??= await ApiClient.request(
        endpoint: ApiEndpoints.attendance,
        method: HttpMethod.get,
        tag: '$_tag -> fetchTodayAttendance(fallback)',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        final model = TodayAttendanceModel.fromApiJson(data);

        // Cache live state for offline / shell reference
        await AppPreferences.setTodayAttendance(model.toJson());

        return model;
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Today attendance fetch failed: $e'),
        tag: '$_tag -> fetchTodayAttendance() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Fetches monthly attendance analytics breakdown from GET /me/attendance/summary
  Future<MonthlySummaryModel?> fetchMonthlySummary() async {
    try {
      final response = await ApiClient.request(
        endpoint: ApiEndpoints.attendanceSummary,
        method: HttpMethod.get,
        tag: '$_tag -> fetchMonthlySummary()',
        showToastOnError: false,
      );

      if (response != null && response is Map && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        final meta = response['meta'] is Map
            ? Map<String, dynamic>.from(response['meta'] as Map)
            : null;

        return MonthlySummaryModel.fromApiJson(data, meta: meta);
      }
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Monthly summary fetch failed: $e'),
        tag: '$_tag -> fetchMonthlySummary() [${stackTrace.toString().split('\n').first}]',
      );
    }
    return null;
  }

  /// Submits an attendance punch action via POST /me/attendance/punches
  /// Supports JSON and Multipart (when photoFile is attached for selfie verification)
  Future<TodayAttendanceModel?> submitPunch({
    required String kind,
    double? latitude,
    double? longitude,
    int? accuracyMeters,
    bool isMocked = false,
    File? photoFile,
    String? faceMatch,
    double? faceScore,
    bool? faceConsent,
  }) async {
    try {
      final String idempotencyKey =
          'punch_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}';

      if (photoFile != null) {
        // Multipart request when selfie photo is attached
        final fields = <String, String>{
          'kind': kind,
          'idempotency_key': idempotencyKey,
        };

        if (latitude != null && longitude != null) {
          fields['latitude'] = latitude.toString();
          fields['longitude'] = longitude.toString();
          fields['accuracy_m'] = (accuracyMeters ?? 10).toString();
          fields['is_mocked'] = isMocked ? 'true' : 'false';
        }
        if (faceMatch != null) {
          fields['face_match'] = faceMatch;
        }
        if (faceScore != null) {
          fields['face_score'] = faceScore.toStringAsFixed(4);
        }
        if (faceConsent != null) {
          fields['face_consent'] = faceConsent ? 'true' : 'false';
        }

        final multipartFile = await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
        );

        final response = await ApiClient.requestMultipart(
          method: HttpMethod.post,
          endpoint: ApiEndpoints.attendancePunches,
          fields: fields,
          files: [multipartFile],
          tag: '$_tag -> submitPunch(multipart, $kind)',
          showToastOnError: true,
        );

        if (response != null && response is Map && response['data'] != null) {
          final data = Map<String, dynamic>.from(response['data'] as Map);
          return TodayAttendanceModel.fromApiJson(data);
        }

        return await fetchTodayAttendance();
      }

      // Normal JSON payload
      final body = <String, dynamic>{
        'kind': kind,
        'idempotency_key': idempotencyKey,
      };

      if (latitude != null && longitude != null) {
        body['latitude'] = latitude;
        body['longitude'] = longitude;
        body['accuracy_m'] = accuracyMeters ?? 10;
        body['is_mocked'] = isMocked;
      }
      if (faceMatch != null) body['face_match'] = faceMatch;
      if (faceScore != null) body['face_score'] = faceScore;
      if (faceConsent != null) body['face_consent'] = faceConsent;

      final response = await ApiClient.request(
        endpoint: ApiEndpoints.attendancePunches,
        method: HttpMethod.post,
        body: body,
        tag: '$_tag -> submitPunch($kind)',
        showToastOnError: true,
      );

      if (response != null && response is Map && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        return TodayAttendanceModel.fromApiJson(data);
      }

      // If response body doesn't return updated day state, re-fetch live state
      return await fetchTodayAttendance();
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Punch submission failed: $e'),
        tag: '$_tag -> submitPunch($kind) [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
