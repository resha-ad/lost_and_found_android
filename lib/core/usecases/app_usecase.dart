import 'package:dartz/dartz.dart';
import 'package:lost_n_found/core/error/failures.dart';

abstract interface class UseCaseWithParams<SuccesType, Params> {
  Future<Either<Failure, SuccesType>> call(Params params);
}

abstract interface class UseCaseWithoutParams<SuccesType> {
  Future<Either<Failure, SuccesType>> call();
}
