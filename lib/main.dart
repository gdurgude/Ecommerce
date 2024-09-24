import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'screens/product_details_page.dart';
import 'screens/cart_page.dart';
import 'screens/profile_page.dart';
import 'screens/image_classification_page.dart';
import 'models/cart.dart';
import 'models/user.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => User()),
        Provider(create: (context) => ApiService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      theme: ThemeData(
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.orangeAccent),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false, 
      routes: {
        '/product': (context) => const ProductDetailsPage(),
        '/cart': (context) => const CartPage(),
        '/profile': (context) => const ProfilePage(),
        '/image_classification': (context) => const ImageClassificationPage(),
      },
    );
  }
}
