import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MishkahColors {
  static const background = Color(0xFF0D1713);
  static const surface = Color(0xFF15221C);
  static const surfaceRaised = Color(0xFF1B2B24);
  static const border = Color(0xFF2A3A32);
  static const green = Color(0xFF2C5142);
  static const gold = Color(0xFFC6A15B);
  static const goldLight = Color(0xFFD8BC7A);
  static const ivory = Color(0xFFF4EFE3);
  static const textSecondary = Color(0xFFA8B0AA);
  static const textMuted = Color(0xFF7E8882);
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('حدث خطأ غير متوقع، حاولي مرة أخرى');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: GoogleFonts.ibmPlexSansArabic(color: _MishkahColors.ivory),
        ),
        backgroundColor: _MishkahColors.surfaceRaised,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _MishkahColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: _MishkahColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _BackButton(onTap: () => Navigator.pop(context)),
              ),
              title: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'استعادة كلمة المرور',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    color: _MishkahColors.ivory,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _emailSent ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: _MishkahColors.surfaceRaised,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _MishkahColors.gold.withOpacity(0.24),
                ),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: _MishkahColors.gold,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'نسيت كلمة المرور؟',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: _MishkahColors.ivory,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أدخلي بريدك الإلكتروني المسجل وسنرسل لك رابطًا لإعادة تعيين كلمة المرور',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              color: _MishkahColors.textSecondary,
              fontSize: 13,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'البريد الإلكتروني',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.ibmPlexSansArabic(
                color: _MishkahColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            validator: _validateEmail,
            style: GoogleFonts.ibmPlexSansArabic(
              color: _MishkahColors.ivory,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'example@email.com',
              hintTextDirection: TextDirection.ltr,
              hintStyle: GoogleFonts.ibmPlexSansArabic(
                color: _MishkahColors.textMuted,
                fontSize: 13,
              ),
              filled: true,
              fillColor: _MishkahColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _MishkahColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _MishkahColors.gold),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              errorStyle: GoogleFonts.ibmPlexSansArabic(
                color: Colors.redAccent.shade100,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: _MishkahColors.gold,
                disabledBackgroundColor:
                    _MishkahColors.gold.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: _MishkahColors.background,
                      ),
                    )
                  : Text(
                      'إرسال رابط إعادة التعيين',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: _MishkahColors.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: _MishkahColors.surfaceRaised,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _MishkahColors.gold.withOpacity(0.24)),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: _MishkahColors.gold,
            size: 40,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'تم إرسال الرابط',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
            color: _MishkahColors.ivory,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'أرسلنا رابط إعادة تعيين كلمة المرور إلى:\n${_emailController.text.trim()}\n\nافتحي بريدك الإلكتروني واتبعي الرابط لتعيين كلمة مرور جديدة.',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSansArabic(
            color: _MishkahColors.textSecondary,
            fontSize: 13,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _MishkahColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'العودة لتسجيل الدخول',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.ibmPlexSansArabic(
                color: _MishkahColors.ivory,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _MishkahColors.surfaceRaised,
          border: Border.all(
            color: _MishkahColors.gold.withOpacity(0.24),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _MishkahColors.ivory,
          size: 16,
        ),
      ),
    );
  }
}
