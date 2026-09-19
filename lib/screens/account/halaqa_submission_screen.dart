import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pending_halaqa_model.dart';
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
const _focusOptions = {'حفظ': 'memorization', 'مراجعة': 'review', 'تجويد': 'tajweed'};
const _timeOptions = {'صباحي': 'morning', 'مسائي': 'evening'};
const _ageOptions = {
  'أطفال': 'kids',
  'ناشئة': 'youth',
  'بالغون': 'adults',
  'كبار سن': 'seniors',
};
const _feeOptions = {'مجاني': 'free', 'رسوم رمزية': 'symbolic'};
const _memorizationOptions = [
  'نصف وجه',
  'وجه',
  'وجهين',
  'ثلاث أوجه',
  'أربع أوجه',
  'خمس أوجه',
  'حر',
];

class HalaqaSubmissionScreen extends StatefulWidget {
  const HalaqaSubmissionScreen({super.key});

  @override
  State<HalaqaSubmissionScreen> createState() => _HalaqaSubmissionScreenState();
}

class _HalaqaSubmissionScreenState extends State<HalaqaSubmissionScreen> {
  final _repo = SubmissionRepository();

  final _name = TextEditingController();
  final _darNameRef = TextEditingController();
  final _meetingUrl = TextEditingController();
  final _nisab = TextEditingController();
  final _registrationUrl = TextEditingController();
  final _contactPhone = TextEditingController();

  String? _attendance;
  String? _category;
  String? _focus;
  String? _time;
  String? _memorizationAmount;
  String? _age;
  String? _fee;
  String? _status;
  TimeOfDay? _timeFrom;
  TimeOfDay? _timeTo;

  bool _submitting = false;
  String? _errorText;

  bool get _isOnline => _attendance == 'أونلاين';
  bool get _isReview => _focus == 'مراجعة';
  bool get _registrationUrlRequired => _isOnline && _status == 'مفتوح';

  @override
  void dispose() {
    _name.dispose();
    _darNameRef.dispose();
    _meetingUrl.dispose();
    _nisab.dispose();
    _registrationUrl.dispose();
    _contactPhone.dispose();
    super.dispose();
  }

  String? _formatTime(TimeOfDay? t) {
    if (t == null) return null;
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isFrom ? _timeFrom : _timeTo) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _timeFrom = picked;
      } else {
        _timeTo = picked;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);

    if (_name.text.trim().isEmpty ||
        _attendance == null ||
        _category == null ||
        _focus == null ||
        _time == null ||
        _age == null ||
        _fee == null ||
        _status == null) {
      setState(() => _errorText = 'عبّ الحقول الإلزامية المؤشرة بـ * قبل الإرسال.');
      return;
    }
    if (_registrationUrlRequired && _registrationUrl.text.trim().isEmpty) {
      setState(() => _errorText =
          'رابط التسجيل إلزامي هنا لأن الحلقة أونلاين والتسجيل بها مفتوح.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final request = PendingHalaqaModel(
        id: '',
        submittedBy: '',
        status: SubmissionStatus.pending,
        submittedAt: DateTime.now(),
        name: _name.text.trim(),
        darNameRef:
            _darNameRef.text.trim().isEmpty ? null : _darNameRef.text.trim(),
        attendanceType: _attendanceOptions[_attendance]!,
        category: _categoryOptions[_category]!,
        focus: _focusOptions[_focus]!,
        time: _timeOptions[_time]!,
        time2: _formatTime(_timeFrom),
        time3: _formatTime(_timeTo),
        memorizationAmount: _memorizationAmount,
        ageGroup: _ageOptions[_age]!,
        feeType: _feeOptions[_fee]!,
        nisab: _isReview && _nisab.text.trim().isNotEmpty
            ? _nisab.text.trim()
            : null,
        registrationStatus: _statusOptions[_status]!,
        registrationUrl: _registrationUrl.text.trim().isEmpty
            ? null
            : _registrationUrl.text.trim(),
        contactPhone:
            _contactPhone.text.trim().isEmpty ? null : _contactPhone.text.trim(),
        onlineMeetingUrl: _isOnline && _meetingUrl.text.trim().isNotEmpty
            ? _meetingUrl.text.trim()
            : null,
      );

      await _repo.submitHalaqa(request);

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
      {String? hint, TextInputType? type}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      style: GoogleFonts.ibmPlexSansArabic(color: _C.ivory, fontSize: 13.5),
      decoration: _inputDecoration(hintText: hint),
    );
  }

  Widget _singleChoice({
    required List<String> options,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((label) {
        final isSelected = value == label;
        return _ChoicePill(
          label: label,
          selected: isSelected,
          onTap: () => onChanged(label),
        );
      }).toList(),
    );
  }

  Widget _timeField(String label, TimeOfDay? value, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _C.surfaceRaised,
            border: Border.all(color: _C.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: _C.textMuted),
              const SizedBox(width: 8),
              Text(
                value != null ? _formatTime(value)! : label,
                style: GoogleFonts.ibmPlexSansArabic(
                    color: value != null ? _C.ivory : _C.textMuted, fontSize: 12.5),
              ),
            ],
          ),
        ),
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
                child: Text('تسجيل بيانات حلقة',
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
                  _label('اسم الحلقة', required: true),
                  _textField(_name, hint: 'مثال: حلقة تحفيظ النساء - المستوى الأول'),
                  const SizedBox(height: 16),
                  _label('اسم الدار المرتبطة',
                      note: 'اتركه فارغًا لو الحلقة أونلاين مستقلة'),
                  _textField(_darNameRef,
                      hint: 'اكتب اسم الدار كما كتبته بالضبط بنموذج الدار'),
                  const SizedBox(height: 16),
                  _label('طريقة الحضور', required: true),
                  _singleChoice(
                    options: _attendanceOptions.keys.toList(),
                    value: _attendance,
                    onChanged: (v) => setState(() => _attendance = v),
                  ),
                  const SizedBox(height: 16),
                  _label('الفئة', required: true),
                  _singleChoice(
                    options: _categoryOptions.keys.toList(),
                    value: _category,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 16),
                  _label('نوع الحلقة', required: true),
                  _singleChoice(
                    options: _focusOptions.keys.toList(),
                    value: _focus,
                    onChanged: (v) => setState(() => _focus = v),
                  ),
                  const SizedBox(height: 16),
                  _label('الوقت', required: true),
                  _singleChoice(
                    options: _timeOptions.keys.toList(),
                    value: _time,
                    onChanged: (v) => setState(() => _time = v),
                  ),
                  const SizedBox(height: 16),
                  _label('وقت الحلقة (من - إلى)', note: '(اختياري)'),
                  Row(
                    children: [
                      _timeField('من', _timeFrom, () => _pickTime(true)),
                      const SizedBox(width: 10),
                      _timeField('إلى', _timeTo, () => _pickTime(false)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _label('مقدار الحفظ', note: '(اختياري)'),
                  _singleChoice(
                    options: _memorizationOptions,
                    value: _memorizationAmount,
                    onChanged: (v) => setState(() => _memorizationAmount =
                        _memorizationAmount == v ? null : v),
                  ),
                  if (_isOnline) ...[
                    const SizedBox(height: 16),
                    _label('رابط الاجتماع الأونلاين', note: '(اختياري)'),
                    _textField(_meetingUrl, hint: 'https://'),
                  ],
                  const SizedBox(height: 16),
                  _label('الفئة العمرية', required: true),
                  _singleChoice(
                    options: _ageOptions.keys.toList(),
                    value: _age,
                    onChanged: (v) => setState(() => _age = v),
                  ),
                  const SizedBox(height: 16),
                  _label('نوع الرسوم', required: true),
                  _singleChoice(
                    options: _feeOptions.keys.toList(),
                    value: _fee,
                    onChanged: (v) => setState(() => _fee = v),
                  ),
                  if (_isReview) ...[
                    const SizedBox(height: 16),
                    _label('النصاب', note: '(اختياري، للمراجعة)'),
                    _textField(_nisab, hint: 'مثال: جزء عم'),
                  ],
                  const SizedBox(height: 16),
                  _label('حالة التسجيل', required: true),
                  _singleChoice(
                    options: _statusOptions.keys.toList(),
                    value: _status,
                    onChanged: (v) => setState(() => _status = v),
                  ),
                ],
              ),
              _card(
                title: 'تواصل إضافي (اختياري)',
                children: [
                  _label('رابط التسجيل',
                      required: _registrationUrlRequired,
                      note: _registrationUrlRequired
                          ? null
                          : 'يصبح إلزاميًا إذا كانت الحلقة أونلاين والتسجيل مفتوح.'),
                  _textField(_registrationUrl, hint: 'https://'),
                  const SizedBox(height: 16),
                  _label('رقم تواصل'),
                  _textField(_contactPhone,
                      hint: '05xxxxxxxx', type: TextInputType.phone),
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
