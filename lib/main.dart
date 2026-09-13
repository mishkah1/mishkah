import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'repositories/dar_repository.dart';
import 'screens/dar/dar_details_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const MishkatApp());
}

class MishkatApp extends StatelessWidget {
  const MishkatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مشكاة',
      debugShowCheckedModeBanner: false,
      home: const FirstDarLoader(),
    );
  }
}

/// شاشة مؤقتة تجيب أول دار وحلقاته من Supabase وتفتح صفحة الدار.
/// للتجربة فقط - لاحقا بتستبدلينها بصفحة رئيسية تعرض كل الدور.
class FirstDarLoader extends StatelessWidget {
  const FirstDarLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DarRepository();

    return FutureBuilder(
      future: repository.fetchAllDars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('حدث خطأ: ${snapshot.error}')),
          );
        }

        final dars = snapshot.data ?? [];
        if (dars.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('ما فيه دور مضافة بعد')),
          );
        }

        final firstDar = dars.first;

        return FutureBuilder(
          future: repository.fetchHalaqasForDar(firstDar.id),
          builder: (context, halaqaSnapshot) {
            if (halaqaSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return DarDetailsScreen(
              dar: firstDar,
              halaqas: halaqaSnapshot.data ?? [],
            );
          },
        );
      },
    );
  }
}