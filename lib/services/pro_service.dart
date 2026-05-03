import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  PRO SERVICE — Gerencia desbloqueio Pro
//  In-App Purchase via Google Play Billing
// ─────────────────────────────────────────────
//
//  ⚠️  ANTES DE PUBLICAR:
//  1. Crie o produto "frete_antt_pro" no Google Play Console
//     (Monetizar → Produtos → Produtos avulsos)
//  2. Substitua o produtoId abaixo pelo ID que você cadastrou
//  3. Faça upload do APK de produção no Play Console
//     antes de testar compras reais
// ─────────────────────────────────────────────

class ProService {
  static const _kIsPro    = 'is_pro';
  static const produtoId  = 'frete_antt_pro'; // ← ID do produto no Play Console

  static final isProNotifier = ValueNotifier<bool>(false);
  static bool get isPro => isProNotifier.value;

  static StreamSubscription<List<PurchaseDetails>>? _sub;

  // ── Inicialização ──────────────────────────

  static Future<void> init() async {
    // Restaura estado salvo localmente
    final prefs = await SharedPreferences.getInstance();
    isProNotifier.value = prefs.getBool(_kIsPro) ?? false;

    final disponivel = await InAppPurchase.instance.isAvailable();
    if (!disponivel) return;

    // Escuta compras em tempo real (compra nova + restauração)
    _sub = InAppPurchase.instance.purchaseStream.listen(
      _processarCompras,
      onError: (_) {},
    );

    // Restaura compras anteriores ao abrir o app
    await InAppPurchase.instance.restorePurchases();
  }

  // ── Processar eventos de compra ────────────

  static Future<void> _processarCompras(
      List<PurchaseDetails> compras) async {
    for (final compra in compras) {
      if (compra.productID != produtoId) continue;

      switch (compra.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _ativarPro();
          if (compra.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(compra);
          }
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  static Future<void> _ativarPro() async {
    isProNotifier.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, true);
  }

  // ── Comprar Pro ────────────────────────────

  static Future<String?> comprar() async {
    final disponivel = await InAppPurchase.instance.isAvailable();
    if (!disponivel) return 'Play Store não disponível neste dispositivo.';

    final resposta = await InAppPurchase.instance
        .queryProductDetails({produtoId});

    if (resposta.notFoundIDs.isNotEmpty || resposta.productDetails.isEmpty) {
      return 'Produto não encontrado. Verifique sua conexão.';
    }

    final param = PurchaseParam(
      productDetails: resposta.productDetails.first,
    );

    try {
      await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: param);
      return null; // sucesso — resultado chega pelo stream
    } catch (e) {
      return 'Erro ao iniciar compra. Tente novamente.';
    }
  }

  // ── Restaurar compras ──────────────────────

  static Future<void> restaurar() async {
    final disponivel = await InAppPurchase.instance.isAvailable();
    if (disponivel) {
      await InAppPurchase.instance.restorePurchases();
    }
  }

  static void dispose() => _sub?.cancel();
}
