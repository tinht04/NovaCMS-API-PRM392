import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

/// RootPage: checks auth on startup and shows MainScaffold (bottom nav) when logged in,
/// otherwise navigates to LoginScreen (using named route). For simplicity this widget
/// shows MainScaffold even for guests but exposes Login/Register buttons on Home.
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final _storage = const FlutterSecureStorage();
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await _storage.read(key: 'access_token');
    setState(() {
      _loggedIn = token != null && token.isNotEmpty;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_loggedIn) {
      return LoginScreen(onSuccess: () => setState(() => _loggedIn = true));
    }
    return const MainScaffold();
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;
  static const _pages = [
    HomeScreen(),
    ProductListScreen(),
    CartScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ProfileScreen moved to its own file: lib/ui/screens/profile_screen.dart
