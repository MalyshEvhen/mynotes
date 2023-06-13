import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('should not be initialize at the begin with', () {
      expect(
        provider._isInitialize,
        false,
      );
    });

    test('cannot log out if not initialize', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NoInitializeException>()),
      );
    });

    test('should be able to be initialize', () async {
      await provider.initialize();
      expect(
        provider._isInitialize,
        true,
      );
    });

    test('user should be null after initialization', () {
      expect(
        provider.currentUser,
        null,
      );
    });

    test(
      'should be able to initialize in less then 2 sec',
      () async {
        await provider.initialize();
        expect(
          provider.isInitialize,
          true,
        );
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('create user should delegate to login function', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'password',
      );

      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final badPasswordUser = provider.createUser(
        email: 'foobar@bar.com',
        password: 'foobar',
      );

      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.createUser(
        email: 'email',
        password: 'password',
      );

      expect(
        provider.currentUser,
        user,
      );

      expect(
        user.isEmailVerified,
        false,
      );
    });

    test('logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;

      expect(
        user,
        isNotNull,
      );

      expect(
        user!.isEmailVerified,
        true,
      );
    });

    test('should be able to login and log out', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;

      expect(
        user,
        isNotNull,
      );
    });
  });
}

class NoInitializeException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialize = false;

  bool get isInitialize => _isInitialize;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialize) throw NoInitializeException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialize = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialize) throw NoInitializeException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: '1',
      email: 'email@mail.com',
      isEmailVerified: false,
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialize) throw NoInitializeException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialize) throw NoInitializeException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      id: '1',
      email: 'email@mail.com',
      isEmailVerified: true,
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    throw UnimplementedError();
  }
}
