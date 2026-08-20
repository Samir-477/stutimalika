import 'package:flutter/material.dart';
import 'home_screen.dart';
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
    const textShadow = [Shadow(color: Colors.black87, blurRadius: 10), Shadow(color: Colors.black54, blurRadius: 24)];

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeIn,
        opacity: _exiting ? 0.0 : 1.0,
        child: AnimatedBuilder(
          animation: Listenable.merge([_entrance, _pulse]),
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Transform.scale(
                  scale: _pulseScale.value,
                  child: Image.asset('assets/images/splash screen.jpeg', fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Align(
                  // Lower than dead-center so the deity's face stays visible
                  // above the text, with the title sitting around chest height.
                  alignment: const Alignment(0, 0.42),
                  child: FadeTransition(
                    opacity: _imageFade,
                    child: ScaleTransition(
                      scale: _imageScale,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FadeTransition(
                              opacity: _titleFade,
                              child: SlideTransition(
                                position: _titleSlide,
                                child: const Text(
                                  'प्रीतोस्तु कृष्णः प्रभुः',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 40, height: 1.4, fontWeight: FontWeight.bold, color: Colors.white, shadows: textShadow),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FadeTransition(
                              opacity: _subtitleFade,
                              child: SlideTransition(
                                position: _subtitleSlide,
                                child: const Text(
                                  'स्तुतिमल्लिका',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22, letterSpacing: 1.2, color: Colors.white70, shadows: textShadow),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
