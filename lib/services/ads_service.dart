import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
//  ADS SERVICE — Gerencia anúncios AdMob
//  Exibidos apenas na versão gratuita
// ─────────────────────────────────────────────
//
//  ⚠️  ANTES DE PUBLICAR:
//  1. Crie uma conta no Google AdMob (admob.google.com)
//  2. Crie um app Android e gere os IDs de anúncio
//  3. Substitua os IDs de teste abaixo pelos seus IDs reais:
//     - _appId        → ID do App AdMob
//     - _bannerId     → ID do bloco de anúncio Banner
//     - _interstId    → ID do bloco de anúncio Intersticial
//  4. Atualize também o APPLICATION_ID no AndroidManifest.xml
// ─────────────────────────────────────────────

class AdsService {
  // IDs de produção (release)
  static const _bannerIdProd  = 'ca-app-pub-8591038417855463/6579677798';
  static const _interstIdProd = 'ca-app-pub-8591038417855463/4962420355';

  // IDs oficiais de teste do Google (debug/profile)
  static const _bannerIdTest  = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstIdTest = 'ca-app-pub-3940256099942544/1033173712';

  static String get _bannerId => kReleaseMode ? _bannerIdProd : _bannerIdTest;
  static String get _interstId => kReleaseMode ? _interstIdProd : _interstIdTest;

  static BannerAd?       _banner;
  static InterstitialAd? _intersticial;
  static bool            _interstPronto = false;
  static int             _tentativasIntersticial = 0;

  static BannerAd? get banner => _banner;

  // ── Inicialização ──────────────────────────

  static Future<void> init() async {
    await MobileAds.instance.initialize();
    _carregarBanner();
    _carregarIntersticial();
  }

  // ── Banner ─────────────────────────────────

  static void _carregarBanner() {
    _banner = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  static void recarregarBanner() {
    _banner?.dispose();
    _carregarBanner();
  }

  // ── Intersticial ───────────────────────────

  static void _carregarIntersticial() {
    InterstitialAd.load(
      adUnitId: _interstId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _intersticial = ad;
          _interstPronto = true;
          _tentativasIntersticial = 0;
        },
        onAdFailedToLoad: (_) {
          _intersticial = null;
          _interstPronto = false;

          // Re-tenta automaticamente para não ficar sem intersticial.
          _tentativasIntersticial++;
          final atrasoSegundos = _tentativasIntersticial > 5
              ? 30
              : _tentativasIntersticial * 3;
          Future.delayed(Duration(seconds: atrasoSegundos), () {
            _carregarIntersticial();
          });
        },
      ),
    );
  }

  static Future<void> mostrarIntersticial() async {
    if (!_interstPronto || _intersticial == null) {
      _carregarIntersticial();
      return;
    }

    _intersticial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _intersticial  = null;
        _interstPronto = false;
        _carregarIntersticial(); // pré-carrega o próximo
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _intersticial  = null;
        _interstPronto = false;
        _carregarIntersticial();
      },
    );

    await _intersticial!.show();
    _interstPronto = false;
  }

  static void dispose() {
    _banner?.dispose();
    _intersticial?.dispose();
  }
}
