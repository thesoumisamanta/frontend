import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'auth/login_screen.dart';
import 'home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _startTimeout();
  }

  // Add a safety timeout in case auth check takes too long
  void _startTimeout() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && !_hasNavigated) {
        setState(() {
          _statusMessage = 'Taking longer than expected. Retrying...';
        });
        
        // Try one more time
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && !_hasNavigated) {
            // Force navigation to login after total 40 seconds
            _navigateTo(const LoginScreen());
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Connection timeout. Please check your internet and try logging in.',
                  ),
                  duration: Duration(seconds: 5),
                ),
              );
            }
          }
        });
      }
    });
  }

  void _navigateTo(Widget screen) {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateTo(const MainScreen());
        } else if (state is AuthUnauthenticated) {
          _navigateTo(const LoginScreen());
        } else if (state is AuthLoading) {
          setState(() {
            _statusMessage = 'Connecting to server...';
          });
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.travel_explore,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Travel Diary',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}