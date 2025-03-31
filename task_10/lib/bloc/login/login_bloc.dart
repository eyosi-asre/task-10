import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_10/bloc/login/login_event.dart';
import 'package:task_10/bloc/login/login_state.dart';
import 'package:task_10/repositories/auth_repositories.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginState.initial()) {
    on<LoginEmailChanged>(_onLoginEmailChanged);
    on<LoginPasswordChanged>(_onLoginPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  void _onLoginEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final isEmailValid = event.email.contains('@');
    emit(state.copyWith(email: event.email, isEmailValid: isEmailValid));
  }

  void _onLoginPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final isPasswordValid = event.password.length >= 6;
    emit(state.copyWith(password: event.password, isPasswordValid: isPasswordValid));
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isEmailValid || !state.isPasswordValid) {
      emit(state.copyWith(
          isFailure: true, errorMessage: 'Invalid email or password'));
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      final user = await authRepository.signInWithEmailAndPassword(
          state.email, state.password);
      if (user != null) {
        emit(state.copyWith(isSuccess: true, isSubmitting: false));
      } else {
        emit(state.copyWith(
            isFailure: true, isSubmitting: false, errorMessage: 'Login failed'));
      }
    } catch (e) {
      emit(state.copyWith(
          isFailure: true, isSubmitting: false, errorMessage: e.toString()));
    }
  }
}