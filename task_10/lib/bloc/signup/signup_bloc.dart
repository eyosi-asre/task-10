import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:task_10/bloc/signup/signup_event.dart';
import 'package:task_10/bloc/signup/signup_state.dart';
import 'package:task_10/repositories/auth_repositories.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;

  SignupBloc({required this.authRepository}) : super(SignupState.initial()) {
    on<SignupEmailChanged>(_onSignupEmailChanged);
    on<SignupPasswordChanged>(_onSignupPasswordChanged);
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  void _onSignupEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    final isEmailValid = event.email.contains('@');
    emit(state.copyWith(email: event.email, isEmailValid: isEmailValid));
  }

  void _onSignupPasswordChanged(
      SignupPasswordChanged event, Emitter<SignupState> emit) {
    final isPasswordValid = event.password.length >= 6;
    emit(state.copyWith(password: event.password, isPasswordValid: isPasswordValid));
  }

  Future<void> _onSignupSubmitted(
      SignupSubmitted event, Emitter<SignupState> emit) async {
    if (!state.isEmailValid || !state.isPasswordValid) {
      emit(state.copyWith(
          isFailure: true, errorMessage: 'Invalid email or password'));
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      final user = await authRepository.createUserWithEmailAndPassword(
          state.email, state.password);
      if (user != null) {
        emit(state.copyWith(isSuccess: true, isSubmitting: false));
      } else {
        emit(state.copyWith(
            isFailure: true, isSubmitting: false, errorMessage: 'Signup failed'));
      }
    } catch (e) {
      emit(state.copyWith(
          isFailure: true, isSubmitting: false, errorMessage: e.toString()));
    }
  }
}