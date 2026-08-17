import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color bgColor = Color(0xFF060D1F);
  static const Color cardColor = Color(0xFF0D1628);
  static const Color socialBg = Color(0xFF111D35);
  static const Color socialBorder = Color(0xFF1E3A6B);
  static const Color blueDeep = Color(0xFF1246A0);
  static const Color blueVivid = Color(0xFF1E6FFF);
  static const Color blueGlow = Color(0xFF4A9EFF);
  static const Color dimText = Color(0xFF6B82A8);

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _hidePass = true;
  bool _loading = false;
  bool _googleLoad = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Enter email and password");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnack("User not found");
      } else if (e.code == 'wrong-password') {
        _showSnack("Wrong password");
      } else if (e.code == 'invalid-email') {
        _showSnack("Invalid email");
      } else {
        _showSnack(e.message ?? "Login failed");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnack("Please enter your email first.");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnack("Password reset email sent to: $email");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _showSnack("No account found with this email.");
          break;
        case 'invalid-email':
          _showSnack("Please enter a valid email.");
          break;
        default:
          _showSnack(e.message ?? "Something went wrong.");
      }
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoad = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _googleLoad = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      _goHome();
    } catch (e) {
      debugPrint("Google error: $e");
      if (mounted) _showSnack("Google sign-in failed: $e");
    } finally {
      if (mounted) setState(() => _googleLoad = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool password = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: socialBorder.withOpacity(0.6)),
      ),
      child: TextField(
        controller: controller,
        obscureText: password && _hidePass,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: blueGlow),
          suffixIcon: password
              ? IconButton(
                  onPressed: () => setState(() => _hidePass = !_hidePass),
                  icon: Icon(
                    _hidePass ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withOpacity(0.4),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF1A3F8F), Color(0xFF071020)],
                  ),
                  border: Border.all(color: blueGlow.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.location_city,
                  size: 48,
                  color: blueGlow,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to continue monitoring air quality.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              const SizedBox(height: 36),
              _field(_emailCtrl, "Email", Icons.email_outlined),
              const SizedBox(height: 14),
              _field(_passCtrl, "Password", Icons.lock_outline, password: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: blueGlow),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _loading ? null : _login,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [blueDeep, blueVivid],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: socialBorder.withOpacity(0.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "or continue with",
                      style: TextStyle(color: dimText),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: socialBorder.withOpacity(0.5)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _googleLoad ? null : _googleSignIn,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: socialBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: socialBorder.withOpacity(0.7)),
                  ),
                  child: Center(
                    child: _googleLoad
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.g_mobiledata,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: dimText),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: blueGlow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
