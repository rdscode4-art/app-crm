class CRMTask {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // Employee Name
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  final String status; // 'Todo', 'In Progress', 'Review', 'Done'

  CRMTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
    required this.status,
  });

  CRMTask copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    String? priority,
    String? status,
  }) {
    return CRMTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }
}
