
enum DocumentKind {
  cv,
  certificate,
  id,
  other;

  String get label => switch (this) {
    DocumentKind.cv => 'CV',
    DocumentKind.certificate => 'Certificate',
    DocumentKind.id => 'ID',
    DocumentKind.other => 'Document',
  };
}

/// A file attached to a person. The bytes live in Supabase storage;
/// this is only the record pointing at them.
class PersonDocument {
  final String id;
  final String personId;
  final DocumentKind kind;

  /// Path inside the bucket, never a URL. URLs are signed on demand
  /// and expire, so storing one would be storing something stale.
  final String storagePath;

  final String fileName;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime createdAt;

  const PersonDocument({
    required this.id,
    required this.personId,
    required this.kind,
    required this.storagePath,
    required this.fileName,
    required this.createdAt,
    this.mimeType,
    this.sizeBytes,
  });

  bool get isPdf =>
      mimeType == 'application/pdf' || fileName.toLowerCase().endsWith('.pdf');

  bool get isImage => mimeType?.startsWith('image/') ?? false;

  /// Word documents cannot render in-app, so the viewer hands these
  /// to the system instead.
  bool get isOfficeDoc {
    final n = fileName.toLowerCase();
    return n.endsWith('.doc') || n.endsWith('.docx');
  }

  String get readableSize {
    final bytes = sizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// What the picker hands back before upload.
class DocumentUpload {
  final String filePath;
  final String fileName;
  final DocumentKind kind;
  final String? mimeType;

  const DocumentUpload({
    required this.filePath,
    required this.fileName,
    this.kind = DocumentKind.cv,
    this.mimeType,
  });
}

/// What the server read out of an uploaded file, offered to the user
/// as a pre-fill. Never saved without them confirming.
class ExtractedDetails {
  final String? fullName;
  final String? phone;
  final String? email;

  const ExtractedDetails({this.fullName, this.phone, this.email});

  bool get isEmpty => fullName == null && phone == null && email == null;
}
