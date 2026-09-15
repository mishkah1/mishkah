import 'package:flutter/material.dart';
import 'package:mishkah/models/dar_model.dart';

class FilterScreen extends StatefulWidget {
  final List<DarModel> dars;
  final String? initialName;
  final String? initialAddress;

  const FilterScreen({
    super.key,
    required this.dars,
    this.initialName,
    this.initialAddress,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const _darkGreen = Color(0xFF24483A);
  static const _cream = Color(0xFFF7F5EF);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _brown = Color(0xFF9A7955);

  late final TextEditingController nameController;
  String? selectedAddress;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.initialName ?? '',
    );

    selectedAddress = widget.initialAddress;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  List<String> get addresses {
    final values = widget.dars
        .map((dar) => dar.address.trim())
        .where((address) => address.isNotEmpty)
        .toSet()
        .toList();

    values.sort();
    return values;
  }

  void applyFilter() {
    final name = nameController.text.trim();

    final results = widget.dars.where((dar) {
      final matchesName =
          name.isEmpty || dar.name.contains(name);

      final matchesAddress =
          selectedAddress == null ||
          selectedAddress!.isEmpty ||
          dar.address == selectedAddress;

      return matchesName && matchesAddress;
    }).toList();

    Navigator.pop(context, {
      'dars': results,
      'name': name,
      'address': selectedAddress,
    });
  }

  void resetFilter() {
    setState(() {
      nameController.clear();
      selectedAddress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _darkGreen,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward,
              color: Color(0xFFFFF8EA),
            ),
          ),
          title: const Text(
            'تصفية الدور',
            style: TextStyle(
              color: Color(0xFFFFF8EA),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          children: [
            const Text(
              'ابحثي عن الدار المناسبة',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'اختاري المعايير التي تريدينها ثم طبقي التصفية',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: _muted,
              ),
            ),
            const SizedBox(height: 22),
            _buildTitle('اسم الدار'),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFE4DED2),
                ),
              ),
              child: TextField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: _text,
                ),
                decoration: const InputDecoration(
                  hintText: 'اكتبي اسم الدار...',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: _muted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _darkGreen,
                    size: 21,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            _buildTitle('الموقع'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFE4DED2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedAddress,
                  isExpanded: true,
                  hint: const Text(
                    'اختاري الموقع',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _darkGreen,
                  ),
                  items: addresses.map(
                    (address) {
                      return DropdownMenuItem<String>(
                        value: address,
                        child: Text(
                          address,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _text,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAddress = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: const Color(0xFFFFF8EA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'تطبيق التصفية',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: resetFilter,
              child: const Text(
                'إعادة تعيين',
                style: TextStyle(
                  fontSize: 12,
                  color: _brown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: _text,
      ),
    );
  }
}