part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

// Aggiunto birthDate
class SignUpRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;
  final DateTime birthDate; // Nuovo campo

  const SignUpRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.birthDate,
  });
}

class GoogleLoginRequested extends AuthEvent {}

// Nuovo evento per la password dimenticata
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});
}
