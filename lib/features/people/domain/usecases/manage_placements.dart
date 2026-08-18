import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import '../entities/placement.dart';
import '../repositories/person_repository.dart';

class MarkEmployedParams {
  final String personId;
  final String? positionTitle;
  final String? organisation;
  final DateTime? startedOn;

  const MarkEmployedParams({
    required this.personId,
    this.positionTitle,
    this.organisation,
    this.startedOn,
  });
}

class MarkEmployed implements UseCase<Placement, MarkEmployedParams> {
  final PersonRepository repository;
  const MarkEmployed(this.repository);

  @override
  Future<Either<Failure, Placement>> call(MarkEmployedParams params) async {
    final started = params.startedOn ?? DateTime.now();

    // A date in the future would put the placement outside every
    // "this month" count and quietly break the dashboard.
    if (started.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return left(
        const ValidationFailure('Start date cannot be in the future.'),
      );
    }

    final title = params.positionTitle?.trim();
    final org = params.organisation?.trim();

    return repository.markEmployed(
      personId: params.personId,
      positionTitle: (title?.isEmpty ?? true) ? null : title,
      organisation: (org?.isEmpty ?? true) ? null : org,
      startedOn: started,
    );
  }
}

class MarkUnemployed implements UseCase<Unit, String> {
  final PersonRepository repository;
  const MarkUnemployed(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String personId) =>
      repository.markUnemployed(personId);
}

class GetPlacements implements UseCase<List<Placement>, String> {
  final PersonRepository repository;
  const GetPlacements(this.repository);

  @override
  Future<Either<Failure, List<Placement>>> call(String personId) =>
      repository.getPlacements(personId);
}
