import 'package:bloc/bloc.dart';
import 'package:campo_base/data/repository/authRepository.dart';
import 'package:pocketbase/pocketbase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) {
      if (_authRepository.isSignedIn) {
        final user = _authRepository.user;
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signIn(email: event.email, password: event.password);
        final user = _authRepository.user;
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(AuthFailure(error: "Login riuscito ma dati utente non trovati."));
        }
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<GoogleLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.authWithGoogle();
        final user = _authRepository.user;
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(const AuthFailure(error: "Utente Google non trovato"));
        }
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _authRepository.logout();
      emit(Unauthenticated());
    });

    // Aggiornato per gestire birthDate
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signUp(
          username: event.username,
          email: event.email,
          password: event.password,
          birthDate: event.birthDate,
        );
        // Se la registrazione va a buon fine, proviamo il login
        add(LoginRequested(email: event.email, password: event.password));
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });

    // Nuovo handler per reset password
    on<PasswordResetRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.requestPasswordReset(event.email);
        emit(const PasswordResetSent(message: "Ti abbiamo inviato una mail per resettare la password\n controlla fra qualche minuto anche nella cartella spam"));
        // Torniamo allo stato Unauthenticated per mostrare il form di login
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    });
  }
}
