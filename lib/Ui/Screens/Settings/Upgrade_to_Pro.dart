import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpgradeToProPage extends StatefulWidget {
  const UpgradeToProPage({Key? key}) : super(key: key);

  @override
  _UpgradeToProPageState createState() => _UpgradeToProPageState();
}

class _UpgradeToProPageState extends State<UpgradeToProPage>
    with TickerProviderStateMixin {
  String selectedPlan = 'free';
  bool showPayment = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleUpgrade(String plan) {
    setState(() {
      selectedPlan = plan;
      if (plan == 'pro') {
        showPayment = true;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _handleGooglePay() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // Simulate Google Pay process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.white : const Color(0xFF4F46E5),
              ),
            ),
          ),
    );

    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pop();
    setState(() {
      showPayment = false;
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: isDarkMode ? Colors.greenAccent : Colors.green,
                  size: 28.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Welcome to Pro!',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Payment successful! You now have access to all premium features.',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14.sp,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.blueAccent
                            : const Color(0xFF4F46E5),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upgrade to pro',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black87,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(isDarkMode),
                      SizedBox(height: 32.h),
                      _buildPricingCards(isDarkMode, theme),
                      SizedBox(height: 48.h),
                      _buildFeaturesSection(isDarkMode),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Payment modal
          if (showPayment) _buildPaymentModal(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDarkMode ? Colors.white : Colors.black,
              width: 4.w,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.black26
                        : Colors.grey.shade400.withOpacity(0.2),
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
            color: isDarkMode ? Colors.white : Colors.black,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.memory,
                  size: 32.sp,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
          ),
        ),
        SizedBox(height: 16.h),
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors:
                    isDarkMode
                        ? [Colors.white, Colors.white10]
                        : [Colors.black, Colors.black12],
              ).createShader(bounds),
          child: Text(
            'Upgrade to Pro',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Unlock premium features for your Gemini GPT experience',
          style: TextStyle(
            fontSize: 16.sp,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPricingCards(bool isDarkMode, ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildFreePlan(isDarkMode, theme)),
        SizedBox(width: 16.w),
        Expanded(child: _buildProPlan(isDarkMode, theme)),
      ],
    );
  }

  Widget _buildFreePlan(bool isDarkMode, ThemeData theme) {
    final isSelected = selectedPlan == 'free';
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      child: Card(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color:
                isSelected
                    ? (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!)
                    : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            width: 2.w,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDarkMode
                      ? [Color(0xFF2D2D2D), Colors.white.withOpacity(0.1)]
                      : [Colors.white, Color(0xFF2D2D2D)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Freemium',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$0',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '/forever',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                ..._buildFeatureList(
                  [
                    'Basic Gemini AI responses',
                    '10 requests per day',
                    'Standard response time',
                    'Community support',
                  ],
                  Colors.green,
                  isDarkMode,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleUpgrade('free'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected
                              ? (isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[800])
                              : (isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[100]),
                      foregroundColor:
                          isSelected
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.grey[800]),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Current Plan' : 'Stay Free',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProPlan(bool isDarkMode, ThemeData theme) {
    final isSelected = selectedPlan == 'pro';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            elevation: isSelected ? 12 : 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                width: 2.w,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDarkMode
                          ? [Color(0xFF2D2D2D), Colors.white.withOpacity(0.1)]
                          : [Colors.white, Color(0xFF2D2D2D)],
                ),
              ),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors:
                                  isDarkMode
                                      ? [Colors.grey[400]!, Colors.grey[600]!]
                                      : [],
                            ).createShader(bounds),
                        child: Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Promium',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$0.10',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),

                      Text(
                        '/one-time',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  ..._buildFeatureList(
                    [
                      'Unlimited Gemini AI requests',
                      'Priority response time',
                      'Advanced conversation modes',
                      'Export chat history',
                      'Premium support',
                      'No ads',
                    ],
                    Colors.green,
                    isDarkMode,
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleUpgrade('pro'),
                      icon: Icon(Icons.flash_on, size: 18.sp),
                      label: Text(
                        'Upgrade to Pro',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected
                                ? (isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[800])
                                : (isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[100]),
                        foregroundColor:
                            isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white
                                    : Colors.grey[800]),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Popular badge
          Positioned(
            top: -8.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDarkMode
                            ? [Color(0xFF2D2D2D), Colors.white.withOpacity(0.1)]
                            : [Colors.white, Color(0xFF2D2D2D)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Most Popular',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureList(
    List<String> features,
    Color color,
    bool isDarkMode,
  ) {
    return features
        .map(
          (feature) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildFeaturesSection(bool isDarkMode) {
    return Column(
      children: [
        Text(
          'Why upgrade to Pro?',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Get unlimited access for just 10 cents',
          style: TextStyle(
            fontSize: 16.sp,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                Icons.all_inclusive,
                'Unlimited',
                'Remove all daily limits and use Gemini AI as much as you want.',
                isDarkMode,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildFeatureCard(
                Icons.speed,
                'Priority',
                'Get faster response times and skip the queue with priority access.',
                isDarkMode,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildFeatureCard(
          Icons.security,
          'One-Time Payment',
          'Pay once, own forever. No recurring subscriptions or hidden fees.',
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDarkMode
                  ? [Color(0xFF2D2D2D)]
                  : [Colors.white, Color(0xFF2D2D2D)],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDarkMode
                          ? [Color(0xFF2D2D2D), Colors.white.withOpacity(0.1)]
                          : [Colors.white, Color(0xFF2D2D2D)],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentModal(bool isDarkMode) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          margin: EdgeInsets.all(24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDarkMode
                              ? [
                                Color(0xFF2D2D2D),
                                Colors.white.withOpacity(0.1),
                              ]
                              : [Colors.white, Color(0xFF2D2D2D)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Complete Your Upgrade',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'One-time payment of \$0.10',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleGooglePay,
                    icon: Container(
                      width: 20.w,
                      height: 20.h,
                      child: SvgPicture.asset(
                        'assets/icons8-google.svg',
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.payment,
                              size: 20.sp,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    label: Text(
                      'Pay with Google Pay',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.grey[800] : Colors.white,
                      foregroundColor:
                          isDarkMode ? Colors.white : Colors.grey[800],
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: BorderSide(
                        color:
                            isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => setState(() => showPayment = false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: 16.sp,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Secure payment • One-time purchase • No subscription',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProStatusManager {
  static const String _proStatusKey = 'gemini_gpt_pro_status';

  static Future<bool> isProUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_proStatusKey) ?? false;
    } catch (e) {
      print('Error checking pro status: $e');
      return false;
    }
  }

  static Future<void> setProStatus(bool isPro) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_proStatusKey, isPro);
      print('Pro status set to: $isPro');
    } catch (e) {
      print('Error setting pro status: $e');
    }
  }

  static Future<void> clearProStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_proStatusKey);
    } catch (e) {
      print('Error clearing pro status: $e');
    }
  }
}
