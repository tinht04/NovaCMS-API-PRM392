import 'package:flutter/material.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/signup_screen.dart';
import 'ui/screens/product_list_screen.dart';
import 'ui/screens/product_detail_screen.dart';
import 'ui/screens/payment_screen.dart';
import 'ui/screens/cart_screen.dart';
import 'ui/screens/map_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/widgets/root_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova Mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      // RootPage decides whether to show Login or Main scaffold depending on auth state
      home: const RootPage(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/products': (_) => const ProductListScreen(),
        '/product': (_) => const ProductDetailScreen(),
        '/payment': (_) => const PaymentScreen(),
  '/cart': (_) => const CartScreen(),
        '/map': (_) => const MapScreen(),
        '/chat': (_) => const ChatScreen(),
      },
    );
  }
}
