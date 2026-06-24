import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;
  late final AnimationController _frameCtrl;
  late final Animation<double> _frameAnim;

  static const _chars = [
    'assets/characters/char-vontade-full.png',
    'assets/characters/char-motivacao-full.png',
    'assets/characters/char-calma-full.png',
    'assets/characters/char-disciplina-full.png',
    'assets/characters/char-insight-full.png',
  ];

  @override
  void initState() {
    super.initState();
    _frameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _frameAnim = CurvedAnimation(parent: _frameCtrl, curve: Curves.easeOut);

    _controllers = List.generate(
      _chars.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _anims = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _frameCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 180));
    }
  }

  @override
  void dispose() {
    _frameCtrl.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JueviColors.carmesim,
      body: Center(
        child: FadeTransition(
          opacity: _frameAnim,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 780, maxHeight: 480),
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: JueviColors.bgCard,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 48,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo + personagens sobrepostos
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Logo principal em chumbo, ancorado no topo e contido
                      // (evita que o "COLLAB" do logo caia sobre os personagens)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: SvgPicture.asset(
                            'assets/logos/logo-principal-red.svg',
                            colorFilter: ColorFilter.mode(
                              JueviColors.chumbo,
                              BlendMode.srcIn,
                            ),
                            fit: BoxFit.contain,
                            height: 215,
                          ),
                        ),
                      ),
                      // Personagens na frente
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(_chars.length, (i) {
                            return FadeTransition(
                              opacity: _anims[i],
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(_anims[i]),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Image.asset(_chars[i], height: 130),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Botão START
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JueviColors.carmesim,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 64, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: Text('START',
                      style: JueviText.bodyBold(size: 16, color: Colors.white)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
