// ─────────────────────────────────────────────
//  FRETE PRO ANTT — Models
// ─────────────────────────────────────────────

// ── Tabela ANTT 2026 — Portaria SUROC 3/2026 ──

class CoeficienteAntt {
  final int eixos;
  final double ccd; // R$/km
  final double cc;  // R$ fixo carga/descarga

  const CoeficienteAntt({
    required this.eixos,
    required this.ccd,
    required this.cc,
  });
}

class TabelaAntt {
  static const String versao = 'SUROC-4-2026';
  static const String dataPublicacao = '20/03/2026';
  static const double dieselReferencia = 7.35; // R$/litro — semana 15-21/03/2026

  // Coeficientes por eixo — Granel Sólido (Tabela A, Portaria SUROC 4/2026)
  static const List<CoeficienteAntt> coeficientes = [
    CoeficienteAntt(eixos: 2, ccd: 4.0338, cc: 444.84),
    CoeficienteAntt(eixos: 3, ccd: 5.1660, cc: 533.36),
    CoeficienteAntt(eixos: 4, ccd: 5.8464, cc: 576.59),
    CoeficienteAntt(eixos: 5, ccd: 6.7381, cc: 642.10),
    CoeficienteAntt(eixos: 6, ccd: 7.4408, cc: 656.76),
    CoeficienteAntt(eixos: 7, ccd: 8.0855, cc: 792.30),
    CoeficienteAntt(eixos: 9, ccd: 9.2662, cc: 877.83),
  ];

  // Coeficientes Granel Líquido (Tabela A, Portaria SUROC 4/2026)
  static const List<CoeficienteAntt> coeficientesGranelLiquido = [
    CoeficienteAntt(eixos: 2, ccd: 4.1052, cc: 455.84),
    CoeficienteAntt(eixos: 3, ccd: 5.2583, cc: 550.10),
    CoeficienteAntt(eixos: 4, ccd: 5.9955, cc: 600.27),
    CoeficienteAntt(eixos: 5, ccd: 6.9002, cc: 669.38),
    CoeficienteAntt(eixos: 6, ccd: 7.6080, cc: 685.45),
    CoeficienteAntt(eixos: 7, ccd: 8.2192, cc: 811.76),
    CoeficienteAntt(eixos: 9, ccd: 9.4199, cc: 902.80),
  ];

  static CoeficienteAntt? buscarPorEixos(int eixos,
      {bool granelLiquido = false}) {
    final lista = granelLiquido ? coeficientesGranelLiquido : coeficientes;
    try {
      return lista.firstWhere((c) => c.eixos == eixos);
    } catch (_) {
      return null;
    }
  }

  // Fatores multiplicadores por tipo de carga sobre o CCD do Granel Sólido
  // (tipos com tabela própria na portaria usam fator 1.0 e coeficientes diretos)
  static const Map<String, double> fatoresCarga = {
    'Granel Sólido':      1.00,
    'Granel Líquido':     1.00, // usa coeficientesGranelLiquido diretamente
    'Carga Geral':        1.05,
    'Neogranel':          1.10,
    'Frigorificada':      1.15,
    'Conteinerizada':     1.05,
    'Perigosa (Sólido)':  1.25,
    'Perigosa (Líquido)': 1.30,
    'Perigosa (Frigo)':   1.35,
    'Pressurizada':       1.40,
  };
}

// ── Tipos de composição de veículo ──

enum TipoComposicao {
  toco(label: 'Toco', eixos: 2, icone: '🚛'),
  truck(label: 'Truck', eixos: 3, icone: '🚚'),
  cavaloCarre(label: 'Cavalo + Carreta', eixos: 5, icone: '🚜'),
  bitrem(label: 'Bitrem', eixos: 7, icone: '🚛'),
  rodotrem(label: 'Rodotrem', eixos: 9, icone: '🚛'),
  outro(label: 'Outro', eixos: 4, icone: '🚚');

  final String label;
  final int eixos;
  final String icone;
  const TipoComposicao({
    required this.label,
    required this.eixos,
    required this.icone,
  });
}

enum TipoImplemento {
  bau(label: 'Baú'),
  sider(label: 'Sider'),
  graneleiro(label: 'Graneleiro'),
  cacamba(label: 'Caçamba'),
  tanque(label: 'Tanque'),
  frigorifico(label: 'Frigorífico'),
  plataforma(label: 'Plataforma'),
  outro(label: 'Outro');

  final String label;
  const TipoImplemento({required this.label});
}

// ── Perfil do veículo (salvo localmente) ──

class PerfilVeiculo {
  final String apelido;
  final TipoComposicao composicao;
  final int totalEixos;
  final TipoImplemento implemento;
  final double consumoKmL;      // km/litro
  final double capacidadeTon;   // toneladas

  const PerfilVeiculo({
    this.apelido = 'Meu Caminhão',
    this.composicao = TipoComposicao.cavaloCarre,
    this.totalEixos = 5,
    this.implemento = TipoImplemento.bau,
    this.consumoKmL = 2.8,
    this.capacidadeTon = 28.0,
  });

  PerfilVeiculo copyWith({
    String? apelido,
    TipoComposicao? composicao,
    int? totalEixos,
    TipoImplemento? implemento,
    double? consumoKmL,
    double? capacidadeTon,
  }) {
    return PerfilVeiculo(
      apelido: apelido ?? this.apelido,
      composicao: composicao ?? this.composicao,
      totalEixos: totalEixos ?? this.totalEixos,
      implemento: implemento ?? this.implemento,
      consumoKmL: consumoKmL ?? this.consumoKmL,
      capacidadeTon: capacidadeTon ?? this.capacidadeTon,
    );
  }

  Map<String, dynamic> toJson() => {
    'apelido': apelido,
    'composicao': composicao.index,
    'totalEixos': totalEixos,
    'implemento': implemento.index,
    'consumoKmL': consumoKmL,
    'capacidadeTon': capacidadeTon,
  };

  factory PerfilVeiculo.fromJson(Map<String, dynamic> json) => PerfilVeiculo(
    apelido: json['apelido'] ?? 'Meu Caminhão',
    composicao: TipoComposicao.values[json['composicao'] ?? 2],
    totalEixos: json['totalEixos'] ?? 5,
    implemento: TipoImplemento.values[json['implemento'] ?? 0],
    consumoKmL: (json['consumoKmL'] ?? 2.8).toDouble(),
    capacidadeTon: (json['capacidadeTon'] ?? 28.0).toDouble(),
  );
}

// ── Resultado do cálculo de frete ──

class ResultadoFrete {
  final String cidadeOrigem;
  final String cidadeDestino;
  final double distanciaKm;
  final int duracaoMinutos;
  final String tipoCarga;
  final int eixos;
  final bool retornoVazio;
  final double ccdAplicado;
  final double cc;
  final double pisoMinimo;
  final double custoDisel;
  final double custoPedagio;
  final double margemEstimada;
  final DateTime calculadoEm;

  const ResultadoFrete({
    required this.cidadeOrigem,
    required this.cidadeDestino,
    required this.distanciaKm,
    required this.duracaoMinutos,
    required this.tipoCarga,
    required this.eixos,
    required this.retornoVazio,
    required this.ccdAplicado,
    required this.cc,
    required this.pisoMinimo,
    required this.custoDisel,
    required this.custoPedagio,
    required this.margemEstimada,
    required this.calculadoEm,
  });

  String get horas {
    final h = duracaoMinutos ~/ 60;
    final m = duracaoMinutos % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  String get rota => '$cidadeOrigem → $cidadeDestino';

  Map<String, dynamic> toJson() => {
    'cidadeOrigem': cidadeOrigem,
    'cidadeDestino': cidadeDestino,
    'distanciaKm': distanciaKm,
    'duracaoMinutos': duracaoMinutos,
    'tipoCarga': tipoCarga,
    'eixos': eixos,
    'retornoVazio': retornoVazio,
    'ccdAplicado': ccdAplicado,
    'cc': cc,
    'pisoMinimo': pisoMinimo,
    'custoDisel': custoDisel,
    'custoPedagio': custoPedagio,
    'margemEstimada': margemEstimada,
    'calculadoEm': calculadoEm.toIso8601String(),
  };

  factory ResultadoFrete.fromJson(Map<String, dynamic> json) => ResultadoFrete(
    cidadeOrigem: json['cidadeOrigem'],
    cidadeDestino: json['cidadeDestino'],
    distanciaKm: json['distanciaKm'].toDouble(),
    duracaoMinutos: json['duracaoMinutos'],
    tipoCarga: json['tipoCarga'],
    eixos: json['eixos'],
    retornoVazio: json['retornoVazio'],
    ccdAplicado: json['ccdAplicado'].toDouble(),
    cc: json['cc'].toDouble(),
    pisoMinimo: json['pisoMinimo'].toDouble(),
    custoDisel: json['custoDisel'].toDouble(),
    custoPedagio: json['custoPedagio'].toDouble(),
    margemEstimada: json['margemEstimada'].toDouble(),
    calculadoEm: DateTime.parse(json['calculadoEm']),
  );
}
