class Device {
  final String id;
  final String name;
  final String imagePath;
  final String type;
  bool isOn;
  final DateTime? lastUpdated;
  final Map<String, dynamic>? additionalProperties;

  Device({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.type,
    this.isOn = false,
    this.lastUpdated,
    this.additionalProperties,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'type': type,
      'isOn': isOn,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'additionalProperties': additionalProperties,
    };
  }

  // Create from Map
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imagePath: map['imagePath'] ?? '',
      type: map['type'] ?? '',
      isOn: map['isOn'] ?? false,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
      additionalProperties: map['additionalProperties'],
    );
  }

  // Copy with method for immutable updates
  Device copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? type,
    bool? isOn,
    DateTime? lastUpdated,
    Map<String, dynamic>? additionalProperties,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      additionalProperties: additionalProperties ?? this.additionalProperties,
    );
  }

  // Toggle device state
  Device toggle() {
    return copyWith(isOn: !isOn, lastUpdated: DateTime.now());
  }

  // Turn device on
  Device turnOn() {
    return copyWith(isOn: true, lastUpdated: DateTime.now());
  }

  // Turn device off
  Device turnOff() {
    return copyWith(isOn: false, lastUpdated: DateTime.now());
  }

  @override
  String toString() {
    return 'Device(id: $id, name: $name, type: $type, isOn: $isOn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
