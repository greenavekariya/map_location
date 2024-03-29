import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:maplocation/maplocation/currentlocation.dart';
import 'package:maplocation/paymnetgateway/stripepaymnet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  'pk_test_51OuCd0SChapbQH8O1R4MFtbbRNk1imJXZLa5AkqAF03E3KhazJRloWiVKgcwZXBBv2w9XsnYNaz2ehOy9t4cptVZ00mwAsKkHt';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  const HomeScreen(),
    );
  }
}

