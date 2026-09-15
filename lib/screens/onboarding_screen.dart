import 'package:flutter/material.dart';
import 'package:mishkah/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController pageController = PageController();

  int currentPage = 0;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> slideAnimation;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/images/onboarding_1.png',
      'title': 'كل ما تحتاجه في مكان واحد',
      'description':
          'اكتشف دور التحفيظ وحلقات القرآن والبرامج التعليمية بسهولة.',
    },
    {
      'image': 'assets/images/onboarding_2.png',
      'title': 'تعلم بما يناسبك',
      'description':
          'اختر الحلقة أو البرنامج الذي يناسب احتياجك وطموحك.',
    },
    {
      'image': 'assets/images/onboarding_3.png',
      'title': 'فرص تصنع أثراً',
      'description':
          'اكتشف الفرص والمبادرات التي تساعدك على التعلم والعطاء.',
    },
  ];

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    slideAnimation = Tween<double>(
      begin: 25,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    animationController.forward();
  }

  void restartAnimation() {
    animationController.reset();
    animationController.forward();
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBDD),
      body: PageView.builder(
        controller: pageController,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });

          restartAnimation();
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    pages[index]['image']!,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [
                              0.00,
                              0.16,
                              0.32,
                              0.48,
                              0.64,
                              0.78,
                              1.00,
                            ],
                            colors: [
                              Color(0xFFF0EBDD),
                              Color.fromRGBO(240, 235, 221, 0.98),
                              Color.fromRGBO(240, 235, 221, 0.90),
                              Color.fromRGBO(240, 235, 221, 0.72),
                              Color.fromRGBO(240, 235, 221, 0.48),
                              Color.fromRGBO(240, 235, 221, 0.20),
                              Color.fromRGBO(240, 235, 221, 0.00),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (currentPage > 0)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 8,
                          ),
                          child: IconButton(
                            onPressed: previousPage,
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 21,
                              color: Color(0xFF24483A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          28,
                          0,
                          28,
                          22,
                        ),
                        child: Opacity(
                          opacity: fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              slideAnimation.value,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  pages[index]['title']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF171B18),
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pages[index]['description']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF625F58),
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    pages.length,
                                    (dotIndex) {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: currentPage == dotIndex
                                            ? 23
                                            : 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: currentPage == dotIndex
                                              ? const Color(0xFF24483A)
                                              : const Color(0xFFBDB7AA),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF24483A),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(17),
                                      ),
                                    ),
                                    child: Text(
                                      currentPage == pages.length - 1
                                          ? 'ابدأ الآن'
                                          : 'التالي',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}