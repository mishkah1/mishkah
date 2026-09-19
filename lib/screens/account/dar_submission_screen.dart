import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pending_dar_model.dart';
import '../../repositories/submission_repository.dart';

class _C {
  static const background = Color(0xFF0D1713);
  static const surface = Color(0xFF15221C);
  static const surfaceRaised = Color(0xFF1B2B24);
  static const border = Color(0xFF2A3A32);
  static const gold = Color(0xFFC6A15B);
  static const goldLight = Color(0xFFD8BC7A);
  static const ivory = Color(0xFFF4EFE3);
  static const textSecondary = Color(0xFFA8B0AA);
  static const textMuted = Color(0xFF7E8882);
}

const _attendanceOptions = {'حضوري': 'inPerson', 'أونلاين': 'online'};
const _statusOptions = {
  'مفتوح': 'open',
  'قريبًا': 'comingSoon',
  'مغلق': 'closed',
};
const _categoryOptions = {'نسائي': 'female', 'رجالي': 'male', 'أطفال': 'kids'};
const _timeOptions = {'صباحي': 'morning', 'مسائي': 'evening'};
const _ageOptions = {
  'أطفال': 'kids',
  'ناشئة': 'youth',
  'بالغون': 'adults',
  'كبار سن': 'seniors',
};
const _feeOptions = {'مجاني': 'free', 'رسوم رمزية': 'symbolic'};

class DarSubmissionScreen extends StatefulWidget {
  const DarSubmissionScreen({super.key});

  @override
  State<DarSubmissionScreen> createState() => _DarSubmissionScreenState();
}

class _DarSubmissionScreenState extends State<DarSubmissionScreen> {
  final _repo = SubmissionRepository();

  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _mapsLink = TextEditingController();
  final _website = TextEditingController();
  final _description = TextEditingController();

  String? _attendance;
  String? _status;
  final Set<String> _categories = {};
  final Set<String> _times = {};
  final Set<String> _ages = {};
  final Set<String> _fees = {};
  bool _hasDaycare = false;
  bool _hasParking = false;
  bool _isAccessible = false;

  bool _submitting = false;
  String? _errorText;

  bool get _isOnline => _attendance == 'أونلاين';

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _mapsLink.dispose();
    _website.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);

    if (_name.text.trim().isEmpty ||
        _attendance == null ||
        _phone.text.trim().isEmpty ||
        _status == null ||
        (!_isOnline &&
            (_address.text.trim().isEmpty || _mapsLink.text.trim().isEmpty))) {
      setState(() => _errorText = 'عبّ الحقول الإلزامية المؤشرة بـ * قبل الإرسال.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final request = PendingDarModel(
        id: '',
        submittedBy: '',
        status: SubmissionStatus.pending,
        submittedAt: DateTime.now(),
        name: _name.text.trim(),
        attendanceType: _attendanceOptions[_attendance]!,
        address: _isOnline ? null : _address.text.trim(),
        mapsLink: _isOnline ? null : _mapsLink.text.trim(),
        phoneNumber: _phone.text.trim(),
        websiteUrl: _website.text.trim().isEmpty ? null : _website.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        categories: _categories.map((e) => _categoryOptions[e]!).toList(),
        times: _times.map((e) => _timeOptions[e]!).toList(),
        ageGroups: _ages.map((e) => _ageOptions[e]!).toList(),
        feeTypes: _fees.map((e) => _feeOptions[e]!).toList(),
        hasDaycare: _isOnline ? false : _hasDaycare,
        hasParking: _isOnline ? false : _hasParking,
        isAccessible: _isOnline ? false : _isAccessible,
        registrationStatus: _statusOptions[_status]!,
      );

      await _repo.submitDar(request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _C.surfaceRaised,
          content: Text('تم إرسال طلبك، بانتظار مراجعة الإدارة',
              style: GoogleFonts.ibmPlexSansArabic(color: _C.ivory)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = 'تعذر إرسال الطلب، حاولي مرة أخرى.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _card({required String title, String? hint, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.amiri(
                  color: _C.gold, fontSize: 16, fontWeight: FontWeight.w700)),
          if (hint != null) ...[
            const SizedBox(height: 3),
            Text(hint,
                style: GoogleFonts.ibmPlexSansArabic(
                    color: _C.textMuted, fontSize: 11.5)),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false, String? note}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(text,
              style: GoogleFonts.ibmPlexSansArabic(
                  color: _C.ivory, fontSize: 12.5, fontWeight: FontWeight.w600)),
          if (required)
            Text(' *',
                style: GoogleFonts.ibmPlexSansArabic(
                    color: _C.goldLight, fontWeight: FontWeight.w700)),
          if (note != null)
            Expanded(
              child: Text(' $note',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                      color: _C.textMuted, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted, fontSize: 12.5),
      filled: true,
      fillColor: _C.surfaceRaised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _C.goldLight),
      ),
    );
  }

  Widget _textField(TextEditingController c,
      {String? hint, TextInputType? type, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      maxLines: maxLines,
      style: GoogleFonts.ibmPlexSansArabic(color: _C.ivory, fontSize: 13.5),
      decoration: _inputDecoration(hintText: hint),
    );
  }

  Widget _singleChoice({
    required Map<String, String> options,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.keys.map((label) {
        final isSelected = value == label;
        return _ChoicePill(
          label: label,
          selected: isSelected,
          onTap: () => onChanged(label),
        );
      }).toList(),
    );
  }

  Widget _multiChoice({
    required Map<String, String> options,
    required Set<String> selected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.keys.map((label) {
        final isSelected = selected.contains(label);
        return _ChoicePill(
          label: label,
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                selected.remove(label);
              } else {
                selected.add(label);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _C.surfaceRaised,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.ibmPlexSansArabic(
                    color: _C.ivory, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _C.gold,
            activeTrackColor: _C.gold.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _C.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: _C.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.gold),
                onPressed: () => Navigator.pop(context),
              ),
              title: Directionality(
                textDirection: TextDirection.rtl,
                child: Text('تسجيل بيانات دار',
                    style: GoogleFonts.amiri(color: _C.ivory, fontWeight: FontWeight.w700)),
              ),
              centerTitle: true,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            children: [
              _card(
                title: 'البيانات الأساسية',
                children: [
                  _label('اسم الدار أو المقرأة', required: true),
                  _textField(_name, hint: 'مثال: دار الفرقان لتحفيظ القرآن'),
                  const SizedBox(height: 16),
                  _label('حضوري أو أونلاين', required: true),
                  _singleChoice(
                    options: _attendanceOptions,
                    value: _attendance,
                    onChanged: (v) => setState(() => _attendance = v),
                  ),
                  const SizedBox(height: 16),
                  if (!_isOnline) ...[
                    _label('العنوان', required: true),
                    _textField(_address, hint: 'الحي، المدينة'),
                    const SizedBox(height: 16),
                  ],
                  _label('رقم الجوال', required: true),
                  _textField(_phone, hint: '05xxxxxxxx', type: TextInputType.phone),
                  const SizedBox(height: 16),
                  if (!_isOnline) ...[
                    _label('رابط موقع الدار على خرائط قوقل',
                        required: true,
                        note:
                            'افتح موقع الدار في خرائط قوقل، اضغط "مشاركة"، وانسخ الرابط والصقه هنا.'),
                    _textField(_mapsLink, hint: 'https://maps.app.goo.gl/...'),
                    const SizedBox(height: 16),
                  ],
                  _label('حالة التسجيل بالدار', required: true),
                  _singleChoice(
                    options: _statusOptions,
                    value: _status,
                    onChanged: (v) => setState(() => _status = v),
                  ),
                ],
              ),
              _card(
                title: 'التصنيفات المتوفرة (اختياري)',
                children: [
                  _label('الفئات'),
                  _multiChoice(options: _categoryOptions, selected: _categories),
                  const SizedBox(height: 16),
                  _label('الأوقات المتوفرة'),
                  _multiChoice(options: _timeOptions, selected: _times),
                  const SizedBox(height: 16),
                  _label('الفئات العمرية المستهدفة'),
                  _multiChoice(options: _ageOptions, selected: _ages),
                  const SizedBox(height: 16),
                  _label('أنواع الرسوم المتوفرة'),
                  _multiChoice(options: _feeOptions, selected: _fees),
                ],
              ),
              if (!_isOnline)
                _card(
                  title: 'خدمات الموقع',
                  children: [
                    _switchRow('يوجد حضانة', _hasDaycare,
                        (v) => setState(() => _hasDaycare = v)),
                    _switchRow('يوجد مواقف سيارات', _hasParking,
                        (v) => setState(() => _hasParking = v)),
                    _switchRow('مهيأ لذوي الإعاقة', _isAccessible,
                        (v) => setState(() => _isAccessible = v)),
                  ],
                ),
              _card(
                title: 'روابط إضافية (اختياري)',
                children: [
                  _label('رابط الموقع الإلكتروني'),
                  _textField(_website, hint: 'https://'),
                  const SizedBox(height: 16),
                  _label('وصف مختصر عن الدار'),
                  _textField(_description,
                      hint: 'نبذة قصيرة عن الدار وأنشطتها', maxLines: 3),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.gold,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text('إرسال البيانات',
                          style: GoogleFonts.ibmPlexSansArabic(
                              color: _C.background,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Text(_errorText!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSansArabic(
                        color: const Color(0xFFE0A97A), fontSize: 12)),
              ],
              const SizedBox(height: 10),
              Text('طلبك بينتظر مراجعة الإدارة قبل ما يظهر بالتطبيق.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSansArabic(color: _C.textMuted, fontSize: 11.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _C.gold : _C.surfaceRaised,
          border: Border.all(color: selected ? _C.gold : _C.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            color: selected ? _C.background : _C.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
