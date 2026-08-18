
import 'package:cv_bank/core/utils/date_format.dart';
import '../../domain/entities/placement.dart';
// =====================================================================
// Placement
// =====================================================================

class PlacementModel extends Placement {
  const PlacementModel({
    required super.id,
    required super.personId,
    required super.startedOn,
    required super.isCurrent,
    super.positionTitle,
    super.organisation,
    super.endedOn,
  });

  factory PlacementModel.fromJson(Map<String, dynamic> json) {
    return PlacementModel(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      positionTitle: json['position_title'] as String?,
      organisation: json['organisation'] as String?,
      startedOn: AppDate.parse(json['started_on'] as String),
      endedOn: AppDate.tryParse(json['ended_on'] as String?),
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}
