import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

abstract interface class UseCase<Success, Params> {
  Future<Either<Failure, Success>> call(Params params);
}

class NoParams {
  const NoParams();
}
