import 'package:architecture/architecture.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// A signed-in user used across feature and widget tests.
const testUser = AuthUser(id: 'user-1', username: 'alice');

/// A generic failure used to drive error paths in tests.
const testFailure = UnknownFailure('Something went wrong');
