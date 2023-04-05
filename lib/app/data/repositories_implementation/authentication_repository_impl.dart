import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/either.dart';
import '../../domain/enums.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../services/remote/authentication_service.dart';

const String _key = 'SessionId';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  final FlutterSecureStorage _flutterSecureStorage;
  final AuthenticationService _authenticationService;

  AuthenticationRepositoryImpl(
      this._flutterSecureStorage, this._authenticationService);

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
    final requestToken = await _authenticationService.createRequestToken();
    if (requestToken == null) {
      return Either.left(SignInFailure.unknown);
    }
    final loginResult = await _authenticationService.createSessionWithLogin(
      username: username,
      password: password,
      requestToken: requestToken,
    );

    return loginResult.when(
      (failure) async {
        return Either.left(failure);
      },
      (newRequestToken) async {
        final sessionResult = await _authenticationService.createSession(
          requestToken: newRequestToken,
        );
        return sessionResult.when(
          (failure) async {
            return Either.left(failure);
          },
          (sessionId) async {
            await _flutterSecureStorage.write(
              key: _key,
              value: sessionId,
            );
            return Either.right(
              User(),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> signOut() async {
    await _flutterSecureStorage.delete(key: _key);
  }
}
