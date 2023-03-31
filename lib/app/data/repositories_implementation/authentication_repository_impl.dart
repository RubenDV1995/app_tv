import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/either.dart';
import '../../domain/enums.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/authentication_repository.dart';

const String _key = 'SessionId';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  final FlutterSecureStorage _flutterSecureStorage;

  AuthenticationRepositoryImpl(this._flutterSecureStorage);

  @override
  Future<User?> getUserData() {
    return Future.value(
      User(),
    );
  }

  @override
  Future<bool> get isSignedIn async {
    final sessionIOd = await _flutterSecureStorage.read(key: _key);
    return sessionIOd != null;
  }

  @override
  Future<Either<SignInFailure, User>> signIn(
      String username, String password) async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );
    if (username != 'test') {
      return Future.value(Either.left(SignInFailure.notFound));
    }
    if (password != '12345') {
      return Future.value(Either.left(SignInFailure.unauthorized));
    }

    await _flutterSecureStorage.write(key: _key, value: '123');

    return Future.value(
      Either.right(
        User(),
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await _flutterSecureStorage.delete(key: _key);
  }
}
