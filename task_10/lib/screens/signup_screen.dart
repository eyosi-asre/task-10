import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_10/bloc/signup/signup_bloc.dart';
import 'package:task_10/bloc/signup/signup_event.dart';
import 'package:task_10/bloc/signup/signup_state.dart';
import 'package:task_10/repositories/auth_repositories.dart';
import 'package:task_10/screens/home_screen.dart';
import 'package:task_10/screens/login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: BlocProvider(
        create: (context) => SignupBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: const SignupForm(),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        } else if (state.isSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      },
      child: BlocBuilder<SignupBloc, SignupState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) =>
                      context.read<SignupBloc>().add(SignupEmailChanged(value)),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (value) => context
                      .read<SignupBloc>()
                      .add(SignupPasswordChanged(value)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => context.read<SignupBloc>().add(SignupSubmitted()),
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Placeholder for Facebook signup (not implemented)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Facebook signup not implemented')),
                    );
                  },
                  icon: Image.asset('assets/facebook_logo.png', height: 24),
                  label: const Text('Sign up with Facebook'),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}