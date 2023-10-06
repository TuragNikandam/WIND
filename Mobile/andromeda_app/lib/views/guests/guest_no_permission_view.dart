import 'package:flutter/material.dart';

class GuestNoPermissionView extends StatefulWidget {
  const GuestNoPermissionView({Key? key}) : super(key: key);

  static const String route = "/guest/no_permission";

  @override
  State<GuestNoPermissionView> createState() => _GuestNoPermissionViewState();
}

class _GuestNoPermissionViewState extends State<GuestNoPermissionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2, milliseconds: 500),
      vsync: this,
      lowerBound: 0.2,
      upperBound: 0.8,
    );

    _animation = CurveTween(curve: Curves.easeInOut).animate(_controller);

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        _controller.reverse();
      }
      if (_controller.status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block,
                color: Colors.grey,
                size: 100.0,
              ),
              const SizedBox(height: 30),
              const Text(
                'Diese Seite ist nur für registrierte Nutzer verfügbar',
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 130),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: const [
                          Colors.orangeAccent,
                          Colors.white70,
                          Colors.orange
                        ],
                        stops: [
                          0.0,
                          _animation.value,
                          1.0,
                        ],
                      ).createShader(bounds);
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/registration', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Jetzt registrieren!',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
