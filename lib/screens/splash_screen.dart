import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your home page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start fade-in animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Navigate to home page after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.primary, // Use primary color for splash
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replaced Icon with Image.asset
              Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to an icon if the image fails to load
                  return Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: Theme.of(context).colorScheme.onPrimary,
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'My To-Do App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Organize Your Life',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
