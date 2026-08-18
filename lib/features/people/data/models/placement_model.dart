import 'package:cv_bank/core/utils/date_format.dart';

import '../../domain/entities/person_document.dart';

// =====================================================================
// Document
// =====================================================================
T? _enumFrom<T extends Enum>(List<T> values, String? raw) {
  if (raw == null) return null;
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return null;
}

class PersonDocumentModel extends PersonDocument {
  const PersonDocumentModel({
    required super.id,
    required super.personId,
    required super.kind,
    required super.storagePath,
    required super.fileName,
    required super.createdAt,
    super.mimeType,
    super.sizeBytes,
  });

  factory PersonDocumentModel.fromJson(Map<String, dynamic> json) {
    return PersonDocumentModel(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      kind:
          _enumFrom(DocumentKind.values, json['doc_type'] as String?) ??
          DocumentKind.other,
      storagePath: json['storage_path'] as String,
      fileName: json['file_name'] as String,
      mimeType: json['mime_type'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      createdAt: AppDate.parse(json['created_at'] as String),
    );
  }
}
