class CRMAsset {
  final String id;
  final String name;
  final String serialNumber;
  final String category; // 'Laptop', 'Phone', 'Accessory', 'Other'
  final String assignedTo;
  final String status; // 'Assigned', 'Available', 'Maintenance'
  final DateTime dateAssigned;

  CRMAsset({
    required this.id,
    required this.name,
    required this.serialNumber,
    required this.category,
    required this.assignedTo,
    required this.status,
    required this.dateAssigned,
  });

  factory CRMAsset.fromJson(Map<String, dynamic> json) {
    return CRMAsset(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ?? json['serial_number']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      assignedTo: json['assignedTo']?.toString() ?? 'Unassigned',
      status: json['status']?.toString() ?? 'Available',
      dateAssigned: json['dateAssigned'] != null
          ? DateTime.tryParse(json['dateAssigned'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serialNumber': serialNumber,
      'category': category,
      'assignedTo': assignedTo,
      'status': status,
      'dateAssigned': dateAssigned.toIso8601String(),
    };
  }
}
