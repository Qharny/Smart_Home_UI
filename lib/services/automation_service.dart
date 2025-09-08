import 'dart:async';

import '../repositories/device_repository.dart';

class AutomationService {
  static final AutomationService _instance = AutomationService._internal();
  factory AutomationService() => _instance;
  AutomationService._internal();

  final DeviceRepository _deviceRepository = DeviceRepository();
  Timer? _timer;
  bool _isRunning = false;

  // Start the automation service
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    print('AutomationService: Starting automation service');

    // Check automations every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndExecuteAutomations();
    });

    // Also check immediately when starting
    _checkAndExecuteAutomations();
  }

  // Stop the automation service
  void stop() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    print('AutomationService: Stopped automation service');
  }

  // Check if service is running
  bool get isRunning => _isRunning;

  // Check and execute pending automations
  Future<void> _checkAndExecuteAutomations() async {
    try {
      await _deviceRepository.checkAndExecuteAutomations();
    } catch (e) {
      print('AutomationService: Error checking automations: $e');
    }
  }

  // Manually trigger automation check (useful for testing)
  Future<void> checkAutomationsNow() async {
    await _checkAndExecuteAutomations();
  }

  // Get automation statistics
  Future<Map<String, dynamic>> getAutomationStats() async {
    final automations = await _deviceRepository.getAllAutomations();
    final totalAutomations = automations.length;
    final enabledAutomations = automations.where((a) => a.isEnabled).length;
    final disabledAutomations = totalAutomations - enabledAutomations;

    final automationsByDevice = <String, int>{};
    for (final automation in automations) {
      automationsByDevice[automation.deviceName] =
          (automationsByDevice[automation.deviceName] ?? 0) + 1;
    }

    return {
      'totalAutomations': totalAutomations,
      'enabledAutomations': enabledAutomations,
      'disabledAutomations': disabledAutomations,
      'automationsByDevice': automationsByDevice,
      'serviceRunning': _isRunning,
    };
  }
}
