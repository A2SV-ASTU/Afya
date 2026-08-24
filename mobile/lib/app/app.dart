import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class AfyaMindApp extends StatelessWidget {
  const AfyaMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfyaMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('AfyaMind Initialized'),
        ),
      ),
    );
  }
}
