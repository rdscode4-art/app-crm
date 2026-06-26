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
    String sizeStr = '0 KB';
    if (json['size'] != null) {
      sizeStr = json['size'].toString();
    } else if (json['fileSize'] != null) {
      final bytes = double.tryParse(json['fileSize'].toString()) ?? 0.0;
      if (bytes > 0) {
        if (bytes > 1024 * 1024) {
          sizeStr = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else {
          sizeStr = '${(bytes / 1024).toStringAsFixed(1)} KB';
        }
      }
    }

    String uploadedByStr = 'Unknown';
    if (json['uploadedBy'] != null) {
      if (json['uploadedBy'] is Map) {
        uploadedByStr = json['uploadedBy']['name']?.toString() ?? 'Unknown';
      } else {
        uploadedByStr = json['uploadedBy'].toString();
      }
    } else if (json['uploaded_by'] != null) {
      if (json['uploaded_by'] is Map) {
        uploadedByStr = json['uploaded_by']['name']?.toString() ?? 'Unknown';
      } else {
        uploadedByStr = json['uploaded_by'].toString();
      }
    }

    final cat = json['documentType']?.toString() ?? json['category']?.toString() ?? json['type']?.toString() ?? 'Other';

    return CRMDocument(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: cat,
      fileUrl: json['fileUrl']?.toString() ?? json['file_url']?.toString() ?? '',
      size: sizeStr,
      uploadedBy: uploadedByStr,
      uploadDate: json['uploadDate'] != null
          ? DateTime.tryParse(json['uploadDate'].toString()) ?? DateTime.now()
          : json['upload_date'] != null
              ? DateTime.tryParse(json['upload_date'].toString()) ?? DateTime.now()
              : json['createdAt'] != null
                  ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
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
