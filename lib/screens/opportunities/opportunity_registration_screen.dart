import 'package:flutter/material.dart';
import '../../models/opportunity_model.dart';

/// صفحة التسجيل بفرصة عمل أو تطوع: تطلب الاسم الكامل، العمر، ورقم الجوال.
class OpportunityRegistrationScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const OpportunityRegistrationScreen({super.key, required this.opportunity});

  @override
  State<OpportunityRegistrationScreen> createState() =>
      _OpportunityRegistrationScreenState();
}

class _OpportunityRegistrationScreenState
    extends State<OpportunityRegistrationScreen> {
  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _muted = Color(0xFF8A8470);
  static const _border = Color(0xFFE7DFC9);

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
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: _gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('التسجيل بالفرصة',
            style: TextStyle(color: _cream, fontSize: 14)),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1B12),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'عبّي بياناتك عشان نكمّل تقديمك على الفرصة',
                style: TextStyle(fontSize: 12, color: _muted),
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
                  backgroundColor: _darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text('تسجيل',
                    style: TextStyle(color: _cream, fontSize: 15)),
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
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF1E1B12),
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
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkGreen, width: 1.4),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: هنا لاحقا نرسل البيانات لجدول تسجيلات الفرص بـ Supabase
      _showSuccessDialog();
    }
  }

  /// يعرض مربع نجاح فوق نفس الشاشة (Dialog)، مو شاشة جديدة.
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3DE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Color(0xFF2D4A16), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تم التسجيل بنجاح',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1B12),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'راح يتواصلون معك قريبًا بخصوص الفرصة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext); // يقفل مربع النجاح
                      Navigator.pop(context); // يرجع لصفحة تفاصيل الفرصة
                    },
                    child: const Text('العودة',
                        style: TextStyle(color: _cream, fontSize: 14)),
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