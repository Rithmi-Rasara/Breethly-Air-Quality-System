import 'package:flutter/material.dart';
import 'login_page.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  static const Color bgColor = Color(0xFF0A1628);
  static const Color blueVivid = Color(0xFF1565C0);
  static const Color blueLight = Color(0xFF42A5F5);
  static const Color whiteDim = Color(0xFFB0C4DE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF102040),
                  border: Border.all(
                    color: blueLight.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: blueVivid.withOpacity(0.30),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.public_rounded,
                  size: 90,
                  color: Color(0xFF42A5F5),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(true),
                  const SizedBox(width: 6),
                  _dot(false),
                  const SizedBox(width: 6),
                  _dot(false),
                ],
              ),

              const SizedBox(height: 36),

              const Text(
                "Breathe Better,\nLive Better",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "Monitor real-time air quality, stay\ninformed and protect your health\nand environment.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: whiteDim.withOpacity(0.75),
                  height: 1.6,
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: blueVivid.withOpacity(0.40),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) => Container(
    width: active ? 22 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: active ? blueVivid : Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
