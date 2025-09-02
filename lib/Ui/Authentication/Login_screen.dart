// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gemini_gpt/Ui/Screens/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Future<void> loginguser() async {
  //   try {
  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //         email: _emailController.text, password: _passwordController.text);

  //     User? user = userCredential.user;
  //     if (user != null) {
  //       if (user.emailVerified) {
  //         Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => HomePage(),
  //             ));
  //       }
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     print("FirebaseAuth Error$e");
  //   } catch (e) {
  //     print("Unexpected login error: $e");
  //   }
  //   return;
  // }

  // Future<void> signInWithGoogle() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final UserCredential = await _authService.signInWithGoogle();
  //     final user = UserCredential?.user;
  //     if (user != null && mounted) {
  //       setState(() {
  //         _passwordController.text = user.email ?? "";
  //         _emailController.text = user.email ?? "";
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => HomePage()),
  //         );
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       print("Error in google sign in $e");
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/screen.png'),
            fit: BoxFit.cover,
          ),

          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Colors.white,
          //     Colors.black87,
          //   ],
          // ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(15.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 4.w),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Color.lerp(
                                      Colors.grey.shade400.withOpacity(0.2),
                                      Colors.grey.shade400.withOpacity(0.6),
                                      _glowAnimation.value,
                                    )!,
                                blurRadius: 20.r,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/logo-removebg-preview.png",
                            fit: BoxFit.contain,
                            height: 45.h,
                            width: 40.w,
                          ),
                          // child: Icon(
                          //   Icons.memory,
                          //   size: 32.sp,
                          //   color: Colors.black,
                          // ),
                        );
                      },
                    ),
                    SizedBox(height: 32.h),

                    // Title
                    Text(
                      'Gemini GPT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Email Field
                    _buildInputField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.email_outlined,
                    ),

                    SizedBox(height: 16.h),

                    // Password Field
                    _buildInputField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      hintText: 'Password',
                      isPassword: true,
                      icon: Icons.lock_outline,
                    ),

                    SizedBox(height: 16.h),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: const Color(0xFF757575),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Login Button
                    _buildGlowingButton(),

                    SizedBox(height: 24.h),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1.h,
                            color: Colors.grey[300],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1.h,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Google Login Button
                    _buildGoogleLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    required IconData icon,
  }) {
    return Container(
      height: 55.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white),
      ),
      child: TextField(
        cursorColor: Colors.black,
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: isPassword && !_isPasswordVisible,
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black, fontSize: 16.sp),
          prefixIcon: Icon(icon, color: Colors.black, size: 20.sp),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    onPressed:
                        () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                      size: 22.sp,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGlowingButton() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(colors: [Colors.black, Colors.grey]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(4.w, 4.h),
            blurRadius: 8.r,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(-2.w, -2.h),
            blurRadius: 4.r,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          //   loginguser();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(4.w, 4.h),
            blurRadius: 8.r,
          ),
          BoxShadow(
            color: Colors.grey.shade400,
            offset: Offset(-4.w, -4.h),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Handle Google login
          //   signInWithGoogle();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Icon
            SvgPicture.asset(
              "assets/icons8-google.svg",
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
