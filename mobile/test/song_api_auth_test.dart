import 'package:choird/models/auth_session.dart';
import 'package:choird/services/auth_api.dart';
import 'package:choird/services/auth_controller.dart';
import 'package:choird/services/auth_token_store.dart';
import 'package:choird/services/song_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  tearDown(() {
    AuthController.instance = null;
  });

  test('song requests send the bearer token and sign out on 401', () async {
    final store = MemoryAuthTokenStore();
    await store.write(
      AuthSession(
        token: 'token-1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        user: const AuthUser(
          id: 1,
          name: 'Ada',
          email: 'ada@example.com',
          role: 'member',
        ),
      ),
    );

    final auth = AuthController(
      store: store,
      api: AuthApi(
        client: MockClient((request) async => http.Response('', 204)),
      ),
    );
    AuthController.instance = auth;
    await auth.load();

    final api = SongApi(
      client: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer token-1');
        return http.Response('{"message":"Unauthenticated."}', 401);
      }),
    );

    await expectLater(api.fetchSongs(), throwsA(isA<SongApiException>()));
    expect(auth.session, isNull);
  });
}
