import 'package:flutter/material.dart';
import 'package:inspire_app/screens/home_screen.dart';
import 'package:inspire_app/services/quote_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuoteProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inspiring Quotes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
