import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E7D6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash screen.jpeg', width: 200, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 20),
            const Text(
              'प्रीतोस्तु कृष्णः प्रभुः',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF7C5A3A)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Stutimallika',
              style: TextStyle(fontSize: 18, color: Color(0xFF7C5A3A)),
            ),
          ],
        ),
      ),
    );
  }
}
