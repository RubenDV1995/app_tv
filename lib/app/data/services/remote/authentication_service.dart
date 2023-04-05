import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../../domain/either.dart';
import '../../../domain/enums.dart';

class AuthenticationService {
  final Client _client;
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = '6efa857898538e7f3070b0035db8d0a9';

  AuthenticationService(this._client);

  Future<String?> createRequestToken() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/authentication/token/new?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final json = Map<String, dynamic>.from(
          jsonDecode(response.body),
        );

        return json['request_token'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Either<SignInFailure, String>> createSessionWithLogin({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(
          '$_baseUrl/authentication/token/validate_with_login?api_key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {
            "username": username,
            "password": password,
            "request_token": requestToken
          },
        ),
      );
      switch (response.statusCode) {
        case 200:
          final json = Map<String, dynamic>.from(
            jsonDecode(response.body),
          );
          final newRequestToken = json['request_token'];
          return Either.right(newRequestToken);
        case 401:
          return Either.left(SignInFailure.unauthorized);
        case 404:
          return Either.left(SignInFailure.notFound);
        default:
          return Either.left(SignInFailure.unknown);
      }
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SignInFailure.network);
      }
      return Either.left(SignInFailure.unknown);
    }
  }

  Future<Either<SignInFailure, String>> createSession({
    required String requestToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/authentication/session/new?api_key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {"request_token": requestToken},
        ),
      );
      if (response.statusCode == 200) {
        final json = Map<String, dynamic>.from(
          jsonDecode(response.body),
        );
        final sessionId = json['session_id'] as String;
        return Either.right(sessionId);
      }
      return Either.left(SignInFailure.unknown);
    } catch (e) {
      if (e is SocketException) {
        return Either.left(SignInFailure.network);
      }
      return Either.left(SignInFailure.unknown);
    }
  }
}
