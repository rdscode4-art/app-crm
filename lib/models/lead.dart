class Lead {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final double value;
  final String status; // 'New', 'Contacted', 'Proposal', 'Won', 'Lost'
  final String source; // 'Website', 'Referral', 'LinkedIn', 'Cold Call'
  final DateTime dateCreated;
  final String owner;

  Lead({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.value,
    required this.status,
    required this.source,
    required this.dateCreated,
    required this.owner,
  });

  Lead copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    double? value,
    String? status,
    String? source,
    DateTime? dateCreated,
    String? owner,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      value: value ?? this.value,
      status: status ?? this.status,
      source: source ?? this.source,
      dateCreated: dateCreated ?? this.dateCreated,
      owner: owner ?? this.owner,
    );
  }

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      value: double.tryParse(json['value']?.toString() ?? '') ?? 0.0,
      status: json['status']?.toString() ?? 'New',
      source: json['source']?.toString() ?? 'Website',
      dateCreated: json['dateCreated'] != null
          ? DateTime.tryParse(json['dateCreated'].toString()) ?? DateTime.now()
          : json['date_created'] != null
              ? DateTime.tryParse(json['date_created'].toString()) ?? DateTime.now()
              : DateTime.now(),
      owner: json['owner']?.toString() ?? 'Sales Agent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'value': value,
      'status': status,
      'source': source,
      'dateCreated': dateCreated.toIso8601String(),
      'owner': owner,
    };
  }
}
