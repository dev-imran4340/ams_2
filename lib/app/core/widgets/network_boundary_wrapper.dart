import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/network_connectivity_service.dart';
import '../utils/app_colors.dart';
import 'custom_state_view.dart';

/// Standardized Network Boundary Wrapper
/// Wraps screen or section content to listen to connectivity changes
/// and shows CustomStateView.error on offline state with auto-recovery and retry.
class NetworkBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRetry;
  final String offlineMessage;

  const NetworkBoundaryWrapper({
    super.key,
    required this.child,
    this.onRetry,
    this.offlineMessage =
        'No active internet connection. Please check your network.',
  });

  @override
  State<NetworkBoundaryWrapper> createState() => _NetworkBoundaryWrapperState();
}

class _NetworkBoundaryWrapperState extends State<NetworkBoundaryWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    // Auto-scroll screen to top whenever entering or mounting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollScreenToTop();
      }
    });
  }

  void _scrollScreenToTop() {
    try {
      final primary = PrimaryScrollController.maybeOf(context);
      if (primary != null && primary.hasClients) {
        primary.jumpTo(0.0);
        return;
      }
      Scrollable.maybeOf(context)?.position.jumpTo(0.0);
    } catch (_) {}
  }

  Future<void> _checkInitialConnectivity() async {
    // Fast hardware check (local, near-zero latency)
    try {
      final results = await Connectivity().checkConnectivity();
      final hasHardware =
          !results.contains(ConnectivityResult.none) && results.isNotEmpty;
      if (!hasHardware) {
        if (mounted && _isConnected != false) {
          setState(() {
            _isConnected = false;
          });
        }
        return;
      }
    } catch (_) {}

    // Verify real packet connectivity (uses cached result if verified within 30s)
    final connected = await NetworkConnectivityService.hasConnection();
    if (mounted && _isConnected != connected) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final hasHardware =
        !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    if (!hasHardware) {
      if (mounted && _isConnected != false) {
        setState(() {
          _isConnected = false;
        });
      }
      return;
    }

    // Hardware interface is active (Wi-Fi or Mobile Data) -> Verify real packet transmission
    final hasRealInternet = await NetworkConnectivityService.hasConnection();
    if (mounted && _isConnected != hasRealInternet) {
      setState(() {
        _isConnected = hasRealInternet;
      });
      if (hasRealInternet && widget.onRetry != null) {
        // Seamlessly refresh when internet returns
        widget.onRetry!();
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (!_isConnected) {
      content = Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: CustomStateView.error(
            icon: Icons.wifi_off_rounded,
            title: 'No Connection',
            message: widget.offlineMessage,
            buttonText: 'Try Again',
            onRetry: () async {
              NetworkConnectivityService.invalidateCache();
              final isOnline = await NetworkConnectivityService.hasConnection();
              if (mounted) {
                setState(() {
                  _isConnected = isOnline;
                });
              }
              if (isOnline && widget.onRetry != null) {
                await widget.onRetry!();
              }
            },
          ),
        ),
      );
    } else {
      content = widget.child;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: content,
    );
  }
}
