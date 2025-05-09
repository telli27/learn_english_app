import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/constants/colors.dart';
import 'verification_screen.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../features/settings/screens/terms_of_use_screen.dart';
import '../../../features/settings/screens/privacy_policy_screen.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // Animation controller
  late AnimationController _animationController;

  // Item animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _usernameFieldFadeAnimation;
  late Animation<Offset> _usernameFieldSlideAnimation;
  late Animation<double> _emailFieldFadeAnimation;
  late Animation<Offset> _emailFieldSlideAnimation;
  late Animation<double> _passwordFieldFadeAnimation;
  late Animation<Offset> _passwordFieldSlideAnimation;
  late Animation<double> _confirmPasswordFieldFadeAnimation;
  late Animation<Offset> _confirmPasswordFieldSlideAnimation;
  late Animation<double> _termsCheckboxFadeAnimation;
  late Animation<Offset> _termsCheckboxSlideAnimation;
  late Animation<double> _registerButtonFadeAnimation;
  late Animation<Offset> _registerButtonSlideAnimation;
  late Animation<double> _loginOptionFadeAnimation;
  late Animation<Offset> _loginOptionSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logo animations
    _logoFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Title animations
    _titleFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    // Username field animations
    _usernameFieldFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
    );

    _usernameFieldSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Email field animations
    _emailFieldFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
    );

    _emailFieldSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Password field animations
    _passwordFieldFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
    );

    _passwordFieldSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Confirm password field animations
    _confirmPasswordFieldFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
    );

    _confirmPasswordFieldSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    // Terms checkbox animations
    _termsCheckboxFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 0.9, curve: Curves.easeIn),
    );

    _termsCheckboxSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOut),
      ),
    );

    // Register button animations
    _registerButtonFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    _registerButtonSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    // Login option animations
    _loginOptionFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
    );

    _loginOptionSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      Fluttertoast.showToast(
          msg: 'Kullanım şartlarını ve gizlilik politikasını kabul etmelisiniz',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    setState(() => _isLoading = true);

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Register with auth provider
      final success = await ref.read(authProvider.notifier).register(
            _usernameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (success && mounted) {
        // Success haptic feedback
        HapticFeedback.mediumImpact();

        // Get auth state
        final authState = ref.read(authProvider);

        if (authState.isEmailVerified) {
          // If verified (for demo), just return to the home screen
          Fluttertoast.showToast(
              msg: 'Kayıt başarılı! Hoş geldiniz.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);

          if (mounted) {
            // Navigate back to home screen
            Navigator.pop(context);
          }
        } else {
          // In a real app, we would send verification email and navigate to verification screen
          await ref.read(authProvider.notifier).sendEmailVerification();

          Fluttertoast.showToast(
              msg: 'E-posta doğrulama linki gönderildi',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 16.0);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    VerificationScreen(
                  email: _emailController.text.trim(),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.easeOutQuint;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          }
        }
      } else if (mounted) {
        // Error haptic feedback
        HapticFeedback.heavyImpact();

        // Hata mesajı
        final errorMsg =
            ref.read(authProvider).errorMessage ?? 'Kayıt başarısız';
        Fluttertoast.showToast(
            msg: errorMsg,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();

      if (mounted) {
        Fluttertoast.showToast(
            msg: 'Kayıt başarısız: ${e.toString()}',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Logo with animation
                    Center(
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: (1 - value) * 0.5,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 65,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Header text with animation
                    FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: SlideTransition(
                        position: _titleSlideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hesap Oluştur',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Öğrenme deneyimini kişiselleştirmek için kayıt ol',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Username field with animation
                    FadeTransition(
                      opacity: _usernameFieldFadeAnimation,
                      child: SlideTransition(
                        position: _usernameFieldSlideAnimation,
                        child: _buildTextField(
                          controller: _usernameController,
                          label: 'Kullanıcı Adı',
                          placeholder: 'kullanıcı_adı',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kullanıcı adı gerekli';
                            }
                            if (value.length < 3) {
                              return 'Kullanıcı adı en az 3 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email field with animation
                    FadeTransition(
                      opacity: _emailFieldFadeAnimation,
                      child: SlideTransition(
                        position: _emailFieldSlideAnimation,
                        child: _buildTextField(
                          controller: _emailController,
                          label: 'E-posta',
                          placeholder: 'ornek@email.com',
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'E-posta adresi gerekli';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password field with animation
                    FadeTransition(
                      opacity: _passwordFieldFadeAnimation,
                      child: SlideTransition(
                        position: _passwordFieldSlideAnimation,
                        child: _buildTextField(
                          controller: _passwordController,
                          label: 'Şifre',
                          placeholder: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          isDark: isDark,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark ? Colors.white54 : Colors.black45,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre gerekli';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm password field with animation
                    FadeTransition(
                      opacity: _confirmPasswordFieldFadeAnimation,
                      child: SlideTransition(
                        position: _confirmPasswordFieldSlideAnimation,
                        child: _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Şifreyi Onayla',
                          placeholder: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          isDark: isDark,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark ? Colors.white54 : Colors.black45,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre onayı gerekli';
                            }
                            if (value != _passwordController.text) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Terms and conditions checkbox with animation
                    FadeTransition(
                      opacity: _termsCheckboxFadeAnimation,
                      child: SlideTransition(
                        position: _termsCheckboxSlideAnimation,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor:
                                isDark ? Colors.white54 : Colors.black45,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.02),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: CheckboxListTile(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                                HapticFeedback.selectionClick();
                              },
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: RichText(
                                text: TextSpan(
                                  text: 'Kabul ediyorum ',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Kullanım Şartları',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          HapticFeedback.selectionClick();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TermsOfUseScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                    const TextSpan(text: ' ve '),
                                    TextSpan(
                                      text: 'Gizlilik Politikası',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          HapticFeedback.selectionClick();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PrivacyPolicyScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register button with animation
                    FadeTransition(
                      opacity: _registerButtonFadeAnimation,
                      child: SlideTransition(
                        position: _registerButtonSlideAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Kayıt Ol',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login option with animation
                    FadeTransition(
                      opacity: _loginOptionFadeAnimation,
                      child: SlideTransition(
                        position: _loginOptionSlideAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zaten hesabınız var mı?',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text('Giriş Yap'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            keyboardType: keyboardType,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            onChanged: (_) {
              HapticFeedback.selectionClick();
            },
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 15,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  icon,
                  color: isDark ? Colors.white60 : Colors.black54,
                  size: 20,
                ),
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
