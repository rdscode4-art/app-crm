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
}
