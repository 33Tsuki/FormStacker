import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

/// Animated banner that shows connectivity and sync state.
///
/// Displays below the AppBar as a thin slide-down banner with four states:
/// - OFFLINE: persistent amber banner with pulsing wifi_off icon
/// - SYNCING: blue banner with rotating sync icon
/// - SUCCESS: green banner with scale-in checkmark, auto-dismisses 3s
/// - FAILED: red banner with shake-animated warning, auto-dismisses 4s
class SyncStatusBar extends StatefulWidget {
  const SyncStatusBar({super.key});

  @override
  State<SyncStatusBar> createState() => _SyncStatusBarState();
}

class _SyncStatusBarState extends State<SyncStatusBar>
    with TickerProviderStateMixin {
  // Slide animation for the banner
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  // Rotating sync icon
  late final AnimationController _rotationController;

  // Pulsing offline icon
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Success checkmark scale
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  // Shake animation for error
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  _BannerState _currentBanner = _BannerState.hidden;

  @override
  void initState() {
    super.initState();

    // -- Slide --
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // -- Rotation (sync) --
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // -- Pulse (offline) --
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // -- Scale (success checkmark) --
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // -- Shake (error) --
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    // Listen to both notifiers
    ConnectivityService().isOnline.addListener(_onStateChanged);
    SyncService().syncState.addListener(_onStateChanged);

    // Evaluate initial state
    _onStateChanged();
  }

  @override
  void dispose() {
    ConnectivityService().isOnline.removeListener(_onStateChanged);
    SyncService().syncState.removeListener(_onStateChanged);
    _slideController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final online = ConnectivityService().isOnline.value;
    final syncState = SyncService().syncState.value;

    _BannerState newBanner;
    if (!online) {
      newBanner = _BannerState.offline;
    } else if (syncState == SyncState.syncing) {
      newBanner = _BannerState.syncing;
    } else if (syncState == SyncState.success) {
      newBanner = _BannerState.success;
    } else if (syncState == SyncState.failed) {
      newBanner = _BannerState.failed;
    } else {
      newBanner = _BannerState.hidden;
    }

    if (newBanner == _currentBanner) return;

    // Stop all secondary animations
    _rotationController.stop();
    _pulseController.stop();
    _scaleController.reset();
    _shakeController.reset();

    setState(() {
      _currentBanner = newBanner;
    });

    if (newBanner == _BannerState.hidden) {
      _slideController.reverse();
    } else {
      _slideController.forward();
      switch (newBanner) {
        case _BannerState.offline:
          _pulseController.repeat(reverse: true);
          break;
        case _BannerState.syncing:
          _rotationController.repeat();
          break;
        case _BannerState.success:
          _scaleController.forward();
          break;
        case _BannerState.failed:
          _shakeController.forward();
          break;
        case _BannerState.hidden:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _currentBanner == _BannerState.hidden
            ? const SizedBox.shrink(key: ValueKey('hidden'))
            : _buildBanner(),
      ),
    );
  }

  Widget _buildBanner() {
    final config = _getBannerConfig();
    return Container(
      key: ValueKey(_currentBanner),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: config.backgroundColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          config.iconWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              config.text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _BannerConfig _getBannerConfig() {
    switch (_currentBanner) {
      case _BannerState.offline:
        return _BannerConfig(
          backgroundColor: Colors.orange.shade700,
          text: 'You are offline. Responses will sync when back online.',
          iconWidget: FadeTransition(
            opacity: _pulseAnimation,
            child: const Icon(Icons.wifi_off, color: Colors.white, size: 20),
          ),
        );
      case _BannerState.syncing:
        return _BannerConfig(
          backgroundColor: Colors.blue.shade600,
          text: 'Syncing responses to cloud...',
          iconWidget: RotationTransition(
            turns: _rotationController,
            child: const Icon(Icons.sync, color: Colors.white, size: 20),
          ),
        );
      case _BannerState.success:
        return _BannerConfig(
          backgroundColor: Colors.green.shade600,
          text: 'All responses synced to cloud',
          iconWidget: ScaleTransition(
            scale: _scaleAnimation,
            child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ),
        );
      case _BannerState.failed:
        return _BannerConfig(
          backgroundColor: Colors.red.shade600,
          text: 'Sync failed. Will retry when online.',
          iconWidget: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          ),
        );
      case _BannerState.hidden:
        return _BannerConfig(
          backgroundColor: Colors.transparent,
          text: '',
          iconWidget: const SizedBox.shrink(),
        );
    }
  }
}

enum _BannerState { hidden, offline, syncing, success, failed }

class _BannerConfig {
  final Color backgroundColor;
  final String text;
  final Widget iconWidget;

  const _BannerConfig({
    required this.backgroundColor,
    required this.text,
    required this.iconWidget,
  });
}
