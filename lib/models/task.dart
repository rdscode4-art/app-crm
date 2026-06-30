class CRMTask {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // Employee Name
  final DateTime dueDate;
  final DateTime? startDate;
  final String? category;
  final String priority; // 'Low', 'Medium', 'High'
  final String status; // 'Todo', 'In Progress', 'Review', 'Done'

  CRMTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    this.startDate,
    this.category,
    required this.priority,
    required this.status,
  });

  CRMTask copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    DateTime? startDate,
    String? category,
    String? priority,
    String? status,
  }) {
    return CRMTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  factory CRMTask.fromJson(Map<String, dynamic> json) {
    String assignee = 'Unassigned';
    if (json['assignedTo'] is List && (json['assignedTo'] as List).isNotEmpty) {
      final first = json['assignedTo'][0];
      if (first is Map && first.containsKey('name')) {
        assignee = first['name']?.toString() ?? 'Unassigned';
      }
    } else if (json['assignedTo'] is String) {
      assignee = json['assignedTo'];
    }

    String rawStatus = json['status']?.toString().toLowerCase() ?? 'todo';
    String status = 'Todo';
    if (rawStatus == 'in progress' || rawStatus == 'in_progress') {
      status = 'In Progress';
    } else if (rawStatus == 'review') {
      status = 'Review';
    } else if (rawStatus == 'done' || rawStatus == 'completed') {
      status = 'Done';
    } else if (rawStatus == 'pending') {
      status = 'Todo';
    }

    String rawPriority = json['priority']?.toString().toLowerCase() ?? 'medium';
    String priority = 'Medium';
    if (rawPriority == 'high') {
      priority = 'High';
    } else if (rawPriority == 'low') {
      priority = 'Low';
    }

    return CRMTask(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      assignedTo: assignee,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      category: json['category']?.toString(),
      priority: priority,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'category': category,
      'priority': priority,
      'status': status,
    };
  }
}
