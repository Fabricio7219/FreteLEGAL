import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'pro_service.dart';

// ─────────────────────────────────────────────
//  GERADOR DE PDF PROFISSIONAL
//  Frete Pro ANTT · Portaria SUROC 3/2026
// ─────────────────────────────────────────────

// ── Paleta PDF (PdfColor) ──

const _azul        = PdfColor.fromInt(0xFF0F2D52);
const _laranja     = PdfColor.fromInt(0xFFE87722);
const _cinzaBg     = PdfColor.fromInt(0xFFF5F4F0);
const _verde       = PdfColor.fromInt(0xFF2E7D32);
const _verdeBg     = PdfColor.fromInt(0xFFE8F5E9);
const _amareloBg   = PdfColor.fromInt(0xFFFFF3E0);
const _preto       = PdfColor.fromInt(0xFF1A1A1A);
const _cinzaTxt    = PdfColor.fromInt(0xFF5A5A5A);
const _cinzaBorda  = PdfColor.fromInt(0xFFDDDAD0);
const _vermelho    = PdfColor.fromInt(0xFFC62828);
const _laranjaCusto = PdfColor.fromInt(0xFFE65100);
const _azulClaro   = PdfColor.fromInt(0xFFAABDD4);
const _branco      = PdfColors.white;

// ─────────────────────────────────────────────
//  CLASSE PRINCIPAL — FretePdfGenerator
// ─────────────────────────────────────────────

class FretePdfGenerator {

  /// Gera o PDF e retorna os bytes
  static Future<List<int>> gerar({
    required ResultadoFrete resultado,
    required PerfilVeiculo perfil,
    String? nomeTransportadora,
  }) async {
    final pdf = pw.Document(
      title: 'Orcamento de Frete - Frete Pro ANTT',
      author: 'Frete Pro ANTT',
      subject: 'Piso Minimo ANTT - ${resultado.rota}',
    );

    // Carrega fontes do Google Fonts (sem precisar de arquivos locais)
    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontMedium  = await PdfGoogleFonts.interMedium();
    final fontBold    = await PdfGoogleFonts.interBold();
    final fontMono    = await PdfGoogleFonts.robotoMonoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => _buildPagina(
          ctx, resultado, perfil,
          nomeTransportadora,
          fontRegular, fontMedium, fontBold, fontMono,
        ),
      ),
    );

    return pdf.save();
  }

  // ── Página completa ──

  static pw.Widget _buildPagina(
    pw.Context ctx,
    ResultadoFrete r,
    PerfilVeiculo p,
    String? transportadora,
    pw.Font fontR, pw.Font fontM, pw.Font fontB, pw.Font fontMono,
  ) {
    // Helpers de texto
    pw.TextStyle ts({
      double size = 10,
      PdfColor? color,
      pw.Font? font,
      double? height,
    }) =>
        pw.TextStyle(
          font: font ?? fontR,
          fontSize: size,
          color: color ?? _preto,
          lineSpacing: height,
        );

    pw.TextStyle tsB({double size = 10, PdfColor? color}) =>
        ts(size: size, color: color, font: fontB);

    pw.TextStyle tsM({double size = 10, PdfColor? color}) =>
        ts(size: size, color: color, font: fontM);

    final now         = DateTime.now();
    final numeroOrc   = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [

        // ── CABEÇALHO azul ──────────────────────────
        pw.Container(
          color: _azul,
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                pw.Container(
                  width: 44, height: 44,
                  decoration: const pw.BoxDecoration(
                    color: _laranja,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text('F', style: tsB(size: 22, color: _branco)),
                ),
                pw.SizedBox(width: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('FRETE PRO ANTT', style: tsB(size: 16, color: _branco)),
                    pw.SizedBox(height: 3),
                    pw.Text('Calculadora de Piso Minimo — ANTT 2026',
                        style: ts(size: 8, color: _azulClaro)),
                  ],
                ),
              ]),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('ORCAMENTO DE FRETE',
                      style: tsB(size: 9, color: _laranja)),
                  pw.SizedBox(height: 3),
                  pw.Text('Nº $numeroOrc',
                      style: ts(size: 8, color: _branco)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                    style: ts(size: 8, color: _azulClaro),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── BARRA PORTARIA laranja ───────────────────
        pw.Container(
          color: _laranja,
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Center(
            child: pw.Text(
              'Portaria SUROC 3/2026  |  Resolucao ANTT 6.076/2026  |  Lei 13.703/2018',
              style: tsB(size: 7.5, color: _branco),
            ),
          ),
        ),

        // ── CORPO ────────────────────────────────────
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [

                // Transportadora (se informada)
                if (transportadora != null) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: _cinzaBg,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: _cinzaBorda, width: 0.5),
                    ),
                    child: pw.Row(children: [
                      pw.Text('Para: ', style: tsB(size: 9, color: _cinzaTxt)),
                      pw.Text(transportadora, style: tsB(size: 9, color: _azul)),
                    ]),
                  ),
                  pw.SizedBox(height: 10),
                ],

                // ── ROTA ────────────────────────────
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _cinzaBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: _cinzaBorda, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ROTA', style: tsB(size: 7, color: _cinzaTxt)),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('ORIGEM',
                                  style: ts(size: 7, color: _cinzaTxt)),
                              pw.SizedBox(height: 2),
                              pw.Text(r.cidadeOrigem,
                                  style: tsB(size: 12, color: _azul)),
                            ],
                          ),
                          pw.Text('>', style: tsB(size: 18, color: _laranja)),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('DESTINO',
                                  style: ts(size: 7, color: _cinzaTxt)),
                              pw.SizedBox(height: 2),
                              pw.Text(r.cidadeDestino,
                                  style: tsB(size: 12, color: _azul)),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(children: [
                        _badge('${formatarKm(r.distanciaKm)} por estrada',
                            _azul, tsB),
                        pw.SizedBox(width: 6),
                        _badge(r.horas + ' de viagem', _azul, tsB),
                        pw.SizedBox(width: 6),
                        _badge('OpenStreetMap', _verde, tsB),
                      ]),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // ── PISO MÍNIMO ──────────────────────
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: _verdeBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: _verde, width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PISO MINIMO LEGAL — LEI 13.703/2018',
                          style: tsB(size: 7.5, color: _verde)),
                      pw.SizedBox(height: 6),
                      pw.Text(formatarReais(r.pisoMinimo),
                          style: tsB(size: 26, color: _verde)),
                      pw.SizedBox(height: 3),
                      pw.Text('Valor obrigatorio por lei.',
                          style: ts(size: 7.5, color: _cinzaTxt)),
                      pw.Text(
                          'A transportadora nao pode pagar abaixo deste valor.',
                          style: ts(size: 7.5, color: _cinzaTxt)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                // ── DUAS COLUNAS: cálculo + veículo ──
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    // Coluna esquerda — Detalhamento do cálculo
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _secaoTitulo('DETALHAMENTO DO CALCULO', tsB),
                          pw.SizedBox(height: 6),
                          _tabelaDetalhes([
                            ['Formula', 'Piso = (Dist x CCD) + CC'],
                            ['Distancia', formatarKm(r.distanciaKm)],
                            ['Tipo de carga', r.tipoCarga],
                            ['Eixos', '${r.eixos} eixos'],
                            ['CCD', 'R\$ ${r.ccdAplicado.toStringAsFixed(4)}/km'],
                            ['CC', formatarReais(r.cc)],
                            ['Retorno vazio', r.retornoVazio ? 'Sim (+90%)' : 'Nao'],
                            ['Portaria', TabelaAntt.versao],
                          ], ts, tsB),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 12),

                    // Coluna direita — Veículo
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _secaoTitulo('DADOS DO VEICULO', tsB),
                          pw.SizedBox(height: 6),
                          _tabelaDetalhes([
                            ['Apelido', p.apelido],
                            ['Composicao', p.composicao.label],
                            ['Eixos', '${p.totalEixos} eixos'],
                            ['Implemento', p.implemento.label],
                            ['Consumo', '${p.consumoKmL} km/l'],
                          ], ts, tsB),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // ── AVISO LEGAL ──────────────────────
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: _amareloBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: _laranja, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('AVISO LEGAL',
                          style: tsB(size: 7.5, color: _laranja)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Este documento comprova o piso minimo legal calculado conforme a Lei 13.703/2018 (PNPM-TRC). '
                        'O valor indicado e o MINIMO obrigatorio — a transportadora nao pode pagar abaixo deste valor. '
                        'Calculado com base na Portaria SUROC 3/2026. Distancia calculada via OpenStreetMap (OSRM).',
                        style: ts(size: 7.5, color: _cinzaTxt),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // ── RODAPÉ ───────────────────────────
                pw.Divider(color: _cinzaBorda, thickness: 0.5),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Frete Pro ANTT — fretepro.app.br',
                        style: tsB(size: 7.5, color: _azul)),
                    pw.Text(
                      'Gerado em ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                      style: ts(size: 7.5, color: _cinzaTxt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Widget badge ──
  static pw.Widget _badge(String label, PdfColor cor, Function tsB) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: cor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
      ),
      child: pw.Text(label, style: (tsB as dynamic)(size: 7.0, color: _branco)),
    );
  }

  // ── Título de seção ──
  static pw.Widget _secaoTitulo(String titulo, Function tsB) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(titulo, style: (tsB as dynamic)(size: 7.5, color: _azul)),
        pw.Container(
            height: 1.5,
            color: _azul,
            margin: const pw.EdgeInsets.only(top: 3)),
      ],
    );
  }

  // ── Tabela de detalhes ──
  static pw.Widget _tabelaDetalhes(
    List<List<String>> linhas,
    Function ts,
    Function tsB, {
    List<PdfColor>? corValores,
  }) {
    return pw.Column(
      children: linhas.asMap().entries.map((e) {
        final i     = e.key;
        final linha = e.value;
        final bg    = i.isEven ? _cinzaBg : _branco;
        final corV  = corValores != null && i < corValores.length
            ? corValores[i]
            : _preto;
        return pw.Container(
          color: bg,
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(linha[0],
                  style: (ts as dynamic)(size: 7.5, color: _cinzaTxt)),
              pw.Text(linha[1],
                  style: (tsB as dynamic)(size: 7.5, color: corV)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGET — Botão de geração e compartilhamento
// ─────────────────────────────────────────────

class BotaoPdfPremium extends StatefulWidget {
  final ResultadoFrete resultado;
  final PerfilVeiculo perfil;

  const BotaoPdfPremium({
    super.key,
    required this.resultado,
    required this.perfil,
  });

  @override
  State<BotaoPdfPremium> createState() => _BotaoPdfPremiumState();
}

class _BotaoPdfPremiumState extends State<BotaoPdfPremium> {
  bool _gerando = false;
  final _ctrlTransportadora = TextEditingController();

  Future<void> _gerarECompartilhar() async {
    setState(() => _gerando = true);
    try {
      final bytes = await FretePdfGenerator.gerar(
        resultado: widget.resultado,
        perfil: widget.perfil,
        nomeTransportadora: _ctrlTransportadora.text.isEmpty
            ? null
            : _ctrlTransportadora.text,
      );

      // Salva temporariamente
      final dir  = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/frete_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      // Compartilha
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Orçamento de frete - ${widget.resultado.rota}\n'
            'Piso mínimo ANTT: ${formatarReais(widget.resultado.pisoMinimo)}',
        subject: 'Orçamento Frete - ${widget.resultado.rota}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao gerar PDF: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  Future<void> _visualizarPdf() async {
    final bytes = await FretePdfGenerator.gerar(
      resultado: widget.resultado,
      perfil: widget.perfil,
    );
    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (_) async => Uint8List.fromList(bytes),
      name:
          'Frete_${widget.resultado.cidadeOrigem}_${widget.resultado.cidadeDestino}',
    );
  }

  void _mostrarDialog() {
    // Verifica se é usuário Pro
    if (!ProService.isPro) {
      _mostrarDialogUpgrade();
      return;
    }
    _abrirBottomSheetPdf();
  }

  void _mostrarDialogUpgrade() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: AppRadius.md,
              ),
              child: Icon(Icons.workspace_premium,
                  color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text('Frete Pro', style: AppTextStyles.h2)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Desbloqueie o PDF profissional:',
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _UpgradeItem(Icons.picture_as_pdf_outlined,
                'PDF com logo e dados da empresa'),
            _UpgradeItem(Icons.share,
                'Envio direto por WhatsApp'),
            _UpgradeItem(Icons.block, 'Sem anúncios'),
            _UpgradeItem(Icons.all_inclusive, 'Acesso vitalício'),
            const SizedBox(height: 12),
            Text('Pagamento único via Google Play',
                style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ProService.restaurar();
              if (mounted && ProService.isPro) {
                _abrirBottomSheetPdf();
              }
            },
            child: const Text('Restaurar compra'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final erro = await ProService.comprar();
              if (erro != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(erro)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: const Text('Comprar Pro'),
          ),
        ],
      ),
    );
  }

  void _abrirBottomSheetPdf() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xl),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.full,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Gerar PDF profissional', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text('Envie por WhatsApp para a transportadora',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 20),

            // Campo transportadora (opcional)
            TextField(
              controller: _ctrlTransportadora,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                labelText: 'Nome da transportadora (opcional)',
                hintText: 'Ex: Transportadora Exemplo Ltda',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Preview do que será gerado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: AppRadius.md,
              ),
              child: Column(
                children: [
                  _PreviewRow('Rota', widget.resultado.rota),
                  _PreviewRow(
                      'Distância', formatarKm(widget.resultado.distanciaKm)),
                  _PreviewRow('Piso mínimo',
                      formatarReais(widget.resultado.pisoMinimo)),
                  _PreviewRow('Portaria', TabelaAntt.versao),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botões
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _visualizarPdf,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Visualizar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _gerando
                      ? null
                      : () {
                          Navigator.pop(context);
                          _gerarECompartilhar();
                        },
                  icon: _gerando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.share, size: 18),
                  label: Text(_gerando ? 'Gerando...' : 'Enviar WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ProService.isProNotifier,
      builder: (_, isPro, __) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _gerando ? null : _mostrarDialog,
            icon: _gerando
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(isPro
                    ? Icons.picture_as_pdf
                    : Icons.lock_outline,
                    size: 20),
            label: Text(_gerando
                ? 'Gerando PDF...'
                : isPro
                    ? 'Gerar PDF e enviar por WhatsApp'
                    : 'Gerar PDF — Versão Pro'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ctrlTransportadora.dispose();
    super.dispose();
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String valor;
  const _PreviewRow(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(valor,
              style:
                  AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Item do dialog de upgrade ──

class _UpgradeItem extends StatelessWidget {
  final IconData icone;
  final String texto;
  const _UpgradeItem(this.icone, this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
