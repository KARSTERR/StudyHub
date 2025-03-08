import 'package:flutter/material.dart';
import 'services/counter_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart' as auth;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MyHomePage(title: 'StudyHub Home'),
      },
      // Use onGenerateRoute for routes that need parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => LoginScreen(
              onLogin: (username, password) async {
                final authService = auth.AuthService();
                try {
                  return await authService.login(username, password);
                } catch (e) {
                  return false;
                }
              },
            ),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = auth.AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    setState(() {
      _isLoading = true;
    });

    // Check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();

    setState(() {
      _isLoading = false;
      _isAuthenticated = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const MyHomePage(title: 'StudyHub Home');
    } else {
      Future.microtask(() =>
        Navigator.of(context).pushReplacementNamed('/login')
      );
      return Container();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final CounterService _service = CounterService();
  final _authService = auth.AuthService();
  bool _isLoading = true;
  String _errorMessage = '';
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getUsername();
    setState(() {
      _username = username;
    });
  }

  Future<void> _loadCounter() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final value = await _service.getCounter('global');

      setState(() {
        _counter = value;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load counter: $e';
      });
    }
  }

  Future<void> _incrementCounter() async {
    try {
      // Optimistic update for better UX
      setState(() {
        _counter++;
        _errorMessage = '';
      });

      try {
        // Since we're only storing locally now, this will always succeed
        await _service.updateCounter('global', _counter);
      } catch (e) {
        // Show error but keep the optimistic update
        setState(() {
          _errorMessage = 'Failed to update counter: $e';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_username != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Welcome, $_username!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            const Text('You have pushed the button this many times:'),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_errorMessage.isNotEmpty)
              ElevatedButton(
                onPressed: _loadCounter,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}