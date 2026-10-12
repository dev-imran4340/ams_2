import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected =
        !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    if (mounted && _isConnected != connected) {
      setState(() {
        _isConnected = connected;
      });
      if (connected && widget.onRetry != null) {
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
    if (_isChecking) {
      return widget.child;
    }

    if (!_isConnected) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: CustomStateView.error(
            icon: Icons.wifi_off_rounded,
            title: 'No Connection',
            message: widget.offlineMessage,
            buttonText: 'Try Again',
            onRetry: () async {
              final results = await Connectivity().checkConnectivity();
              _updateConnectionStatus(results);
              if (widget.onRetry != null) {
                await widget.onRetry!();
              }
            },
          ),
        ),
      );
    }

    return widget.child;
  }
}
