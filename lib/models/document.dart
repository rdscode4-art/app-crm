class CRMDocument {
  final String id;
  final String title;
  final String category; // 'Contract', 'Invoice', 'SOP', 'Resume', 'Other'
  final String fileUrl;
  final String size;
  final String uploadedBy;
  final DateTime uploadDate;

  CRMDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.fileUrl,
    required this.size,
    required this.uploadedBy,
    required this.uploadDate,
  });

  factory CRMDocument.fromJson(Map<String, dynamic> json) {
    return CRMDocument(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? json['type']?.toString() ?? 'Other',
      fileUrl: json['fileUrl']?.toString() ?? json['file_url']?.toString() ?? '',
      size: json['size']?.toString() ?? '0 KB',
      uploadedBy: json['uploadedBy']?.toString() ?? json['uploaded_by']?.toString() ?? 'Unknown',
      uploadDate: json['uploadDate'] != null
          ? DateTime.tryParse(json['uploadDate'].toString()) ?? DateTime.now()
          : json['upload_date'] != null
              ? DateTime.tryParse(json['upload_date'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'fileUrl': fileUrl,
      'size': size,
      'uploadedBy': uploadedBy,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }
}
