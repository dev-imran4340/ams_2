class AssetItemModel {
  final String id;
  final String code;
  final String name;
  final String category;
  final String? serialNumber;

  const AssetItemModel({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    this.serialNumber,
  });

  factory AssetItemModel.fromJson(Map<String, dynamic> json) {
    return AssetItemModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Company Asset',
      category: json['category']?.toString() ?? 'Equipment',
      serialNumber: json['serial_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      if (serialNumber != null) 'serial_number': serialNumber,
    };
  }
}

class AssetAssignmentModel {
  final String id;
  final AssetItemModel asset;
  final String? assignedOn;
  final String? expectedReturnOn;
  final String? conditionOut;
  final String? acknowledgedAt;
  final String? returnedOn;
  final String? conditionIn;
  final String? note;
  final bool isOpen;
  final bool charged;

  const AssetAssignmentModel({
    required this.id,
    required this.asset,
    this.assignedOn,
    this.expectedReturnOn,
    this.conditionOut,
    this.acknowledgedAt,
    this.returnedOn,
    this.conditionIn,
    this.note,
    this.isOpen = true,
    this.charged = false,
  });

  factory AssetAssignmentModel.fromJson(Map<String, dynamic> json) {
    final assetJson = json['asset'] is Map<String, dynamic>
        ? json['asset'] as Map<String, dynamic>
        : <String, dynamic>{};

    return AssetAssignmentModel(
      id: json['id']?.toString() ?? '',
      asset: AssetItemModel.fromJson(assetJson),
      assignedOn: json['assigned_on']?.toString(),
      expectedReturnOn: json['expected_return_on']?.toString(),
      conditionOut: json['condition_out']?.toString(),
      acknowledgedAt: json['acknowledged_at']?.toString(),
      returnedOn: json['returned_on']?.toString(),
      conditionIn: json['condition_in']?.toString(),
      note: json['note']?.toString(),
      isOpen: json['is_open'] == true,
      charged: json['charged'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset': asset.toJson(),
      'assigned_on': assignedOn,
      'expected_return_on': expectedReturnOn,
      'condition_out': conditionOut,
      'acknowledged_at': acknowledgedAt,
      'returned_on': returnedOn,
      'condition_in': conditionIn,
      'note': note,
      'is_open': isOpen,
      'charged': charged,
    };
  }

  /// True if currently in employee's custody (not returned)
  bool get isCurrentlyHeld => isOpen && returnedOn == null;

  /// True if returned back to company inventory
  bool get isReturned => !isOpen || (returnedOn != null && returnedOn!.isNotEmpty);

  /// True if acknowledged by employee
  bool get isAcknowledged => acknowledgedAt != null && acknowledgedAt!.isNotEmpty;

  /// True if currently held and waiting for digital acknowledgment
  bool get canAcknowledge => isCurrentlyHeld && !isAcknowledged;

  AssetAssignmentModel copyWith({
    String? id,
    AssetItemModel? asset,
    String? assignedOn,
    String? expectedReturnOn,
    String? conditionOut,
    String? acknowledgedAt,
    String? returnedOn,
    String? conditionIn,
    String? note,
    bool? isOpen,
    bool? charged,
  }) {
    return AssetAssignmentModel(
      id: id ?? this.id,
      asset: asset ?? this.asset,
      assignedOn: assignedOn ?? this.assignedOn,
      expectedReturnOn: expectedReturnOn ?? this.expectedReturnOn,
      conditionOut: conditionOut ?? this.conditionOut,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      returnedOn: returnedOn ?? this.returnedOn,
      conditionIn: conditionIn ?? this.conditionIn,
      note: note ?? this.note,
      isOpen: isOpen ?? this.isOpen,
      charged: charged ?? this.charged,
    );
  }
}
