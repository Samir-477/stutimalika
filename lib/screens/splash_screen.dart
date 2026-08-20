import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../theme/app_colors.dart';
import '../utils/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final Animation<double> _imageFade;
  late final Animation<double> _imageScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _pulseScale;

  bool _exiting = false;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _imageFade = CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _imageScale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)));
    _titleFade = CurvedAnimation(parent: _entrance, curve: const Interval(0.3, 0.8, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _entrance, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));
    _subtitleFade = CurvedAnimation(parent: _entrance, curve: const Interval(0.5, 1.0, curve: Curves.easeOut));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _entrance, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)));

    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _pulseScale = Tween<double>(begin: 1.0, end: 1.035).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _entrance.forward().whenComplete(() {
      if (mounted) _pulse.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 2200), _goHome);
  }

  Future<void> _goHome() async {
    if (!mounted) return;
    _pulse.stop();
    setState(() => _exiting = true);
    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    Navigator.pushReplacement(context, smoothRoute(const HomeScreen()));
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeIn,
          opacity: _exiting ? 0.0 : 1.0,
          child: AnimatedBuilder(
            animation: Listenable.merge([_entrance, _pulse]),
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _imageFade,
                    child: ScaleTransition(
                      scale: _imageScale,
                      child: Transform.scale(
                        scale: _pulseScale.value,
                        child: Image.asset('assets/images/splash screen.jpeg', width: 200, height: 200, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        'प्रीतोस्तु कृष्णः प्रभुः',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: c.brandText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'Stutimallika',
                        style: TextStyle(fontSize: 18, color: c.brandText),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
