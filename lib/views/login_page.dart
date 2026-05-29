import 'package:flutter/material.dart';
import 'package:inventory_apps/utils/color.dart';
import 'package:inventory_apps/views/dashboard.dart';
import 'package:inventory_apps/widgets/button/custom_button.dart';
import 'package:inventory_apps/widgets/form/custom_text_field.dart';
import 'package:lottie/lottie.dart';
import 'package:inventory_apps/service/auth_service.dart';
import 'package:inventory_apps/views/dashboard.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset("assets/icons/login.json"),
                    ),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Inventory',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          TextSpan(
                            text: 'Apps',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Manage Your Inventory Efficiently',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Login To Your Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 24),

                    CustomTextField(
                      controller: _usernameController,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                   // === GANTI DENGAN KODE BARU INI ===
_isLoading 
? const CircularProgressIndicator(
    color: AppColors.primaryBlue,
  )
: CustomButton(
  label: 'Login',
  onTap: () async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi input kosong
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // 2. Aktifkan status loading
    setState(() {
      _isLoading = true;
    });

    // 3. Tembak API ke Backend Express
    bool isSuccess = await AuthService.login(username, password);

    // 4. Matikan status loading setelah dapat respon
    setState(() {
      _isLoading = false;
    });

    // 5. Jika sukses, pindah ke halaman Dashboard
    if (isSuccess) {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else {
      // Jika gagal login
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed! Periksa kembali akun Anda.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  },
  backgroundColor: AppColors.primaryBlue,
),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
