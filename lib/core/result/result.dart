// Define a result class
import 'package:study_aid/core/error/failures.dart';

class Result<T> {
  final T? data;
  final Failure? failure;

  Result.success(this.data) : failure = null;
  Result.failure(this.failure) : data = null;
}
