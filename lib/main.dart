import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/pro_service.dart';
import 'services/ads_service.dart';

// ─────────────────────────────────────────────
//  FRETE LEGAL — main.dart
//  Ponto de entrada do aplicativo
// ─────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barra de status transparente, ícones escuros
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Bloqueia orientação — apenas retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa serviços de monetização
  await ProService.init();
  await AdsService.init();

  runApp(const FretePro());
}

class FretePro extends StatelessWidget {
  const FretePro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frete Legal',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}

// ── Splash Screen ──

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<double>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    // Navega para home após splash
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      size: 56, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Frete Legal',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white, fontSize: 40,
                      )),
                  const SizedBox(height: 8),
                  Text('Piso minimo ${DateTime.now().year}',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.accent,
                      )),
                  const SizedBox(height: 16),
                  Text(
                    'Piso mínimo de frete na palma da mão',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
