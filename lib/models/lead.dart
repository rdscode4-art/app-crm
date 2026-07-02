class Lead {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final double value;
  final String status; // 'New', 'Hot', 'Cold', 'Converted', 'Lost', 'Follow-up'
  final String source; // 'WhatsApp', 'Facebook', 'Instagram', 'Call', 'Walk-in', 'Referral', 'Other', 'Website'
  final DateTime dateCreated;
  final String owner;

  // New expanded fields
  final String alternatePhone;
  final String salesStage; // 'Inquiry', 'Demo', 'Negotiation', 'Closed', 'Booking', 'Lost'
  final double probability;
  final String timeline; // 'Immediate', 'Within 1 Month', '1-3 Months', '3-6 Months'
  final String priority; // 'High', 'Medium', 'Low', 'Critical'
  final String requirement;
  final String street;
  final String city;
  final String state;
  final String pincode;

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
    this.alternatePhone = '',
    this.salesStage = 'Inquiry',
    this.probability = 0.0,
    this.timeline = 'Immediate',
    this.priority = 'Medium',
    this.requirement = '',
    this.street = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
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
    String? alternatePhone,
    String? salesStage,
    double? probability,
    String? timeline,
    String? priority,
    String? requirement,
    String? street,
    String? city,
    String? state,
    String? pincode,
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
      alternatePhone: alternatePhone ?? this.alternatePhone,
      salesStage: salesStage ?? this.salesStage,
      probability: probability ?? this.probability,
      timeline: timeline ?? this.timeline,
      priority: priority ?? this.priority,
      requirement: requirement ?? this.requirement,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  static String _normalizeStatus(String? status) {
    if (status == null) return 'New';
    final lower = status.trim().toLowerCase();
    if (lower == 'new') return 'New';
    if (lower == 'hot') return 'Hot';
    if (lower == 'cold' || lower == 'cool') return 'Cold';
    if (lower == 'converted' || lower == 'won' || lower == 'booking') return 'Converted';
    if (lower == 'lost') return 'Lost';
    if (lower == 'follow-up' || lower == 'followup' || lower == 'follow_up') return 'Follow-up';
    if (lower == 'assigned') return 'Assigned';
    return 'New';
  }

  factory Lead.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString() ?? json['leadStatus']?.toString() ?? 'New';
    final addressMap = json['address'] is Map<String, dynamic>
        ? json['address'] as Map<String, dynamic>
        : null;

    return Lead(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['customerName']?.toString() ?? '',
      company: json['company']?.toString() ?? json['productInterest']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      value: double.tryParse(json['value']?.toString() ?? '') ?? 
             double.tryParse(json['dealValue']?.toString() ?? '') ?? 
             (json['dealValue'] as num?)?.toDouble() ?? 0.0,
      status: _normalizeStatus(rawStatus),
      source: json['source']?.toString() ?? json['leadSource']?.toString() ?? 'Website',
      dateCreated: json['dateCreated'] != null
          ? DateTime.tryParse(json['dateCreated'].toString()) ?? DateTime.now()
          : json['date_created'] != null
              ? DateTime.tryParse(json['date_created'].toString()) ?? DateTime.now()
              : json['createdAt'] != null
                  ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
                  : DateTime.now(),
      owner: json['assignedTo']?['name']?.toString() ??
             json['assignedTo']?['_id']?.toString() ??
             json['assignedTo']?.toString() ??
             json['owner']?.toString() ?? 
             json['createdBy']?['name']?.toString() ?? 
             'Sales Agent',
      alternatePhone: json['alternatePhone']?.toString() ?? json['alternatePhone']?.toString() ?? '',
      salesStage: json['salesStage']?.toString() ?? json['salesStage']?.toString() ?? 'Inquiry',
      probability: double.tryParse(json['probability']?.toString() ?? '') ?? 
                   (json['probability'] as num?)?.toDouble() ?? 0.0,
      timeline: json['timeline']?.toString() ?? json['timeline']?.toString() ?? 'Immediate',
      priority: json['priority']?.toString() ?? json['priority']?.toString() ?? 'Medium',
      requirement: json['requirement']?.toString() ?? '',
      street: addressMap?['street']?.toString() ?? '',
      city: addressMap?['city']?.toString() ?? '',
      state: addressMap?['state']?.toString() ?? '',
      pincode: addressMap?['pincode']?.toString() ?? '',
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
      'alternatePhone': alternatePhone,
      'salesStage': salesStage,
      'probability': probability,
      'timeline': timeline,
      'priority': priority,
      'requirement': requirement,
      // API compatibility
      'customerName': name,
      'productInterest': company,
      'mobile': phone,
      'dealValue': value,
      'leadStatus': status,
      'leadSource': source,
      'address': {
        'street': street,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': 'India',
      },
    };
  }

  Map<String, dynamic> toCreateApiJson() {
    return {
      'customerName': name,
      'mobile': phone,
      'email': email,
      'leadSource': source,
      'leadStatus': status,
      'dealValue': value,
      'priority': priority,
      // Pass owner if your API allows assigning during creation
      'owner': owner,
    };
  }
}
