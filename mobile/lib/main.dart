import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_controller.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChoirdApp());
}

class ChoirdApp extends StatefulWidget {
  const ChoirdApp({super.key, this.authController});

  final AuthController? authController;

  @override
  State<ChoirdApp> createState() => _ChoirdAppState();
}

class _ChoirdAppState extends State<ChoirdApp> with WidgetsBindingObserver {
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = widget.authController ?? AuthController();
    AuthController.instance = _auth;
    _auth.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (AuthController.instance == _auth) {
      AuthController.instance = null;
    }
    _auth.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _auth.expireIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _auth,
      child: MaterialApp(
        title: 'Choird',
        theme: AppTheme.light,
        home: ListenableBuilder(
          listenable: _auth,
          builder: (context, _) {
            if (!_auth.isReady) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (_auth.session == null) {
              return const LoginScreen();
            }

            return const MainScreen();
          },
        ),
      ),
    );
  }
}
