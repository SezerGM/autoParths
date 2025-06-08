import 'package:flutter/material.dart';
import 'ui/main/main_screen.dart';
import 'routing/router.dart';

void main() {
 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'autoParths',
      routerConfig: router(),
      theme: ThemeData(
 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
    );
  }
}

