class Automation {
  final String id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String time; // Format: "HH:mm" (24-hour format)
  final String action; // "on", "off", "brightness", "speed"
  final double? value; // For brightness/speed actions
  final bool isEnabled;
  final List<String> days; // ["monday", "tuesday", etc.] or ["daily"]
  final DateTime createdAt;
  final DateTime? lastExecuted;

  Automation({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.time,
    required this.action,
    this.value,
    this.isEnabled = true,
    this.days = const ["daily"],
    required this.createdAt,
    this.lastExecuted,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'time': time,
      'action': action,
      'value': value,
      'isEnabled': isEnabled,
      'days': days,
      'createdAt': createdAt.toIso8601String(),
      'lastExecuted': lastExecuted?.toIso8601String(),
    };
  }

  // Create from Map
  factory Automation.fromMap(Map<String, dynamic> map) {
    return Automation(
      id: map['id'] ?? '',
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      deviceType: map['deviceType'] ?? '',
      time: map['time'] ?? '00:00',
      action: map['action'] ?? 'on',
      value: map['value']?.toDouble(),
      isEnabled: map['isEnabled'] ?? true,
      days: List<String>.from(map['days'] ?? ['daily']),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastExecuted: map['lastExecuted'] != null
          ? DateTime.parse(map['lastExecuted'])
          : null,
    );
  }

  // Copy with method for immutable updates
  Automation copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? time,
    String? action,
    double? value,
    bool? isEnabled,
    List<String>? days,
    DateTime? createdAt,
    DateTime? lastExecuted,
  }) {
    return Automation(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      time: time ?? this.time,
      action: action ?? this.action,
      value: value ?? this.value,
      isEnabled: isEnabled ?? this.isEnabled,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      lastExecuted: lastExecuted ?? this.lastExecuted,
    );
  }

  // Get formatted time for display
  String get formattedTime {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    
    if (hour == 0) {
      return '12:$minute AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }

  // Get action display text
  String get actionDisplayText {
    switch (action) {
      case 'on':
        return 'Turn On';
      case 'off':
        return 'Turn Off';
      case 'brightness':
        return 'Set Brightness to ${value?.round()}%';
      case 'speed':
        return 'Set Speed to ${value?.round()}%';
      default:
        return action;
    }
  }

  // Check if automation should run today
  bool shouldRunToday() {
    if (!isEnabled) return false;
    
    final now = DateTime.now();
    final today = now.weekday; // 1 = Monday, 7 = Sunday
    
    if (days.contains('daily')) return true;
    
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayName = dayNames[today - 1];
    
    return days.contains(todayName);
  }

  // Check if it's time to execute this automation
  bool isTimeToExecute() {
    if (!shouldRunToday()) return false;
    
    final now = DateTime.now();
    final timeParts = time.split(':');
    final automationHour = int.parse(timeParts[0]);
    final automationMinute = int.parse(timeParts[1]);
    
    // Check if current time matches automation time (within 1 minute tolerance)
    final timeDiff = (now.hour * 60 + now.minute) - (automationHour * 60 + automationMinute);
    return timeDiff.abs() <= 1;
  }

  @override
  String toString() {
    return 'Automation(id: $id, device: $deviceName, time: $time, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Automation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}