import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/opportunity_model.dart';

class OpportunityRegistrationScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const OpportunityRegistrationScreen({super.key, required this.opportunity});

  @override
  State<OpportunityRegistrationScreen> createState() =>
      _OpportunityRegistrationScreenState();
}

class _OpportunityRegistrationScreenState
    extends State<OpportunityRegistrationScreen> {

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textMuted = Color(0xFF7E8882);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: _gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('التسجيل بالفرصة',
            style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _ivory,
                fontSize: 14)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.opportunity.roleLabel} - ${widget.opportunity.organizationName}',
                style: GoogleFonts.amiri(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _ivory,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'عبّي بياناتك عشان نكمّل تقديمك على الفرصة',
                style: TextStyle(
                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                    fontSize: 12,
                    color: _textMuted),
              ),
              const SizedBox(height: 24),

              _buildLabel('الاسم الكامل'),
              _buildTextField(
                controller: _nameController,
                hint: 'مثال: سارة عبدالله',
                keyboardType: TextInputType.name,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'الاسم مطلوب'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('العمر'),
              _buildTextField(
                controller: _ageController,
                hint: 'مثال: 28',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'العمر مطلوب';
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null) return 'أدخلي رقم صحيح';
                  if (age < widget.opportunity.ageMin ||
                      age > widget.opportunity.ageMax) {
                    return 'العمر المطلوب ${widget.opportunity.ageRangeLabel}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('رقم الجوال'),
              _buildTextField(
                controller: _phoneController,
                hint: '05xxxxxxxx',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'رقم الجوال مطلوب';
                  }
                  if (value.trim().length < 9) {
                    return 'رقم الجوال غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: Text('تسجيل',
                    style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        color: _background,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
          fontSize: 12.5,
          color: _ivory,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
        color: _ivory,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
          color: _textMuted,
        ),
        filled: true,
        fillColor: _surfaceRaised,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _gold, width: 1.4),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check,
                      color: _gold, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'تم التسجيل بنجاح',
                  style: GoogleFonts.amiri(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _ivory,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'راح يتواصلون معك قريبًا بخصوص الفرصة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      fontSize: 12,
                      color: _textMuted),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: Text('العودة',
                        style: TextStyle(
                            fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                            color: _background,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
