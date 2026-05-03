import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────
//  SERVIÇO DE CÁLCULO ANTT
// ─────────────────────────────────────────────

class AnttService {
  static ResultadoFrete calcular({
    required String cidadeOrigem,
    required String cidadeDestino,
    required double distanciaKm,
    required int duracaoMinutos,
    required String tipoCarga,
    required int eixos,
    required bool retornoVazio,
    required double consumoKmL,
  }) {
    final granelLiquido = tipoCarga == 'Granel Líquido';
    final coef = TabelaAntt.buscarPorEixos(eixos,
        granelLiquido: granelLiquido);
    if (coef == null) throw Exception('Eixos inválidos: $eixos');

    final fator = granelLiquido
        ? 1.0 // Granel Líquido usa tabela própria, sem fator
        : (TabelaAntt.fatoresCarga[tipoCarga] ?? 1.0);
    final ccdAplicado = coef.ccd * fator;
    final cc = coef.cc;

    // Fórmula ANTT: Piso = (distância × CCD) + CC
    double piso = (distanciaKm * ccdAplicado) + cc;

    // Retorno vazio: +90% do CCD sobre o trecho de volta
    if (retornoVazio) {
      piso += distanciaKm * ccdAplicado * 0.9;
    }

    // Custos estimados
    final custoDisel = distanciaKm * (TabelaAntt.dieselReferencia / consumoKmL);
    final custoPedagio = distanciaKm * 0.28; // média R$/km em rodovias BR
    final margemEstimada = piso - custoDisel - custoPedagio;

    return ResultadoFrete(
      cidadeOrigem: cidadeOrigem,
      cidadeDestino: cidadeDestino,
      distanciaKm: distanciaKm,
      duracaoMinutos: duracaoMinutos,
      tipoCarga: tipoCarga,
      eixos: eixos,
      retornoVazio: retornoVazio,
      ccdAplicado: ccdAplicado,
      cc: cc,
      pisoMinimo: piso,
      custoDisel: custoDisel,
      custoPedagio: custoPedagio,
      margemEstimada: margemEstimada.clamp(0, double.infinity),
      calculadoEm: DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
//  SERVIÇO OSM — GEOCODIFICAÇÃO + ROTA
//  100% gratuito · Sem chave de API
// ─────────────────────────────────────────────

class OsmService {
  static const _userAgent = 'FretePro/1.0 (contato@fretepro.app.br)';

  /// Converte nome da cidade em coordenadas (lat/lon)
  static Future<Map<String, double>?> geocodificar(String cidade) async {
    try {
      final query = Uri.encodeComponent('$cidade, Brasil');
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$query&format=json&limit=1&countrycodes=br',
      );
      final res = await http.get(url, headers: {'User-Agent': _userAgent});
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as List;
      if (data.isEmpty) return null;

      return {
        'lat': double.parse(data[0]['lat']),
        'lon': double.parse(data[0]['lon']),
      };
    } catch (_) {
      return null;
    }
  }

  /// Busca sugestões de cidades enquanto usuário digita
  static Future<List<String>> sugerirCidades(String termo) async {
    try {
      final query = Uri.encodeComponent('$termo, Brasil');
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$query&format=json&limit=12&countrycodes=br'
        '&addressdetails=1',
      );
      final res = await http.get(url, headers: {'User-Agent': _userAgent});
      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body) as List;
      final resultados = <String>[];
      final vistos = <String>{};
      for (final item in data) {
        final addr = item['address'] as Map<String, dynamic>? ?? {};
        final cidade = (addr['city'] ??
                addr['town'] ??
                addr['village'] ??
                addr['municipality'] ??
                addr['county'] ??
                addr['hamlet'] ??
                '')
            .toString()
            .trim();
        final estado = (addr['state'] ??
                addr['state_district'] ??
                addr['region'] ??
                '')
            .toString()
            .trim();

        if (cidade.isNotEmpty) {
          final sugestao = estado.isNotEmpty ? '$cidade, $estado' : cidade;
          final chave = sugestao.toLowerCase();
          if (!vistos.contains(chave)) {
            vistos.add(chave);
            resultados.add(sugestao);
          }
        }
      }
      return resultados;
    } catch (_) {
      return [];
    }
  }

  /// Calcula distância real de rodovia entre dois pontos via OSRM
  static Future<Map<String, dynamic>?> calcularRota({
    required Map<String, double> origem,
    required Map<String, double> destino,
  }) async {
    try {
      final oLon = origem['lon'], oLat = origem['lat'];
      final dLon = destino['lon'], dLat = destino['lat'];
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$oLon,$oLat;$dLon,$dLat?overview=false',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data['code'] != 'Ok') return null;

      final rota = data['routes'][0];
      return {
        'distancia_km': (rota['distance'] / 1000).roundToDouble(),
        'duracao_min': (rota['duration'] / 60).round(),
      };
    } catch (_) {
      return null;
    }
  }

  /// Fluxo completo: nomes de cidades → distância km
  static Future<Map<String, dynamic>?> distanciaEntreCidades(
    String origem, String destino,
  ) async {
    final coordO = await geocodificar(origem);
    final coordD = await geocodificar(destino);
    if (coordO == null || coordD == null) return null;
    return calcularRota(origem: coordO, destino: coordD);
  }
}

// ─────────────────────────────────────────────
//  SERVIÇO DE ARMAZENAMENTO LOCAL
//  SharedPreferences — sem login, sem servidor
// ─────────────────────────────────────────────

class StorageService {
  static const _keyPerfil    = 'perfil_veiculo';
  static const _keyHistorico = 'historico_fretes';

  // ── Perfil do veículo ──

  static Future<PerfilVeiculo> carregarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_keyPerfil);
    if (json == null) return const PerfilVeiculo();
    try {
      return PerfilVeiculo.fromJson(jsonDecode(json));
    } catch (_) {
      return const PerfilVeiculo();
    }
  }

  static Future<void> salvarPerfil(PerfilVeiculo perfil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPerfil, jsonEncode(perfil.toJson()));
  }

  // ── Histórico de fretes ──

  static Future<List<ResultadoFrete>> carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_keyHistorico);
    if (raw == null) return [];
    try {
      final lista = jsonDecode(raw) as List;
      return lista.map((j) => ResultadoFrete.fromJson(j)).toList()
        ..sort((a, b) => b.calculadoEm.compareTo(a.calculadoEm));
    } catch (_) {
      return [];
    }
  }

  static Future<void> salvarNoHistorico(ResultadoFrete resultado) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await carregarHistorico();

    // Mantém no máximo 50 registros
    lista.insert(0, resultado);
    final cortado = lista.take(50).toList();

    await prefs.setString(
      _keyHistorico,
      jsonEncode(cortado.map((r) => r.toJson()).toList()),
    );
  }

  static Future<void> limparHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistorico);
  }
}
