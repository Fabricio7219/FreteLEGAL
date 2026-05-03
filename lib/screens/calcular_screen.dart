import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../services/pdf_generator.dart';
import '../services/ads_service.dart';
import '../services/pro_service.dart';
import '../widgets/widgets.dart';

// ─────────────────────────────────────────────
//  TELA CALCULAR — Coração do app
// ─────────────────────────────────────────────

class CalcularScreen extends StatefulWidget {
  const CalcularScreen({super.key});

  @override
  State<CalcularScreen> createState() => _CalcularScreenState();
}

class _CalcularScreenState extends State<CalcularScreen> {
  // Entradas
  String _cidadeOrigem  = '';
  String _cidadeDestino = '';
  String _tipoCarga     = 'Granel Sólido';
  int    _eixos         = 5;
  bool   _retornoVazio  = false;

  // Estado
  bool            _carregando = false;
  String?         _erro;
  double?         _distanciaKm;
  int?            _duracaoMin;
  ResultadoFrete? _resultado;

  // Perfil salvo
  PerfilVeiculo _perfil = const PerfilVeiculo();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final p = await StorageService.carregarPerfil();
    setState(() {
      _perfil = p;
      _eixos  = p.totalEixos;
    });
  }

  bool get _podeCalcular =>
      _cidadeOrigem.isNotEmpty && _cidadeDestino.isNotEmpty;

  Future<void> _buscarRota() async {
    if (!_podeCalcular) return;
    setState(() {
      _carregando = true;
      _erro       = null;
      _resultado  = null;
    });

    try {
      final rota = await OsmService.distanciaEntreCidades(
        _cidadeOrigem,
        _cidadeDestino,
      );

      if (rota == null) {
        setState(() {
          _erro = 'Não foi possível calcular a rota. Verifique os nomes das cidades.';
          _carregando = false;
        });
        return;
      }

      final distKm  = rota['distancia_km'] as double;
      final duracao = rota['duracao_min']  as int;

      final resultado = AnttService.calcular(
        cidadeOrigem:   _cidadeOrigem,
        cidadeDestino:  _cidadeDestino,
        distanciaKm:    distKm,
        duracaoMinutos: duracao,
        tipoCarga:      _tipoCarga,
        eixos:          _eixos,
        retornoVazio:   _retornoVazio,
        consumoKmL:     _perfil.consumoKmL,
      );

      await StorageService.salvarNoHistorico(resultado);

      // Mostra intersticial após cálculo (apenas versão gratuita)
      if (!ProService.isPro) {
        await AdsService.mostrarIntersticial();
      }

      setState(() {
        _distanciaKm = distKm;
        _duracaoMin  = duracao;
        _resultado   = resultado;
        _carregando  = false;
      });

      // Scroll para o resultado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _erro       = 'Erro ao buscar rota. Verifique sua conexão.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calcular frete'),
        actions: [
          if (_resultado != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() => _resultado = null),
              tooltip: 'Novo cálculo',
            ),
        ],
      ),
      // Banner no rodapé (apenas versão gratuita)
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: ProService.isProNotifier,
        builder: (_, isPro, __) {
          if (isPro) return const SizedBox.shrink();
          final ad = AdsService.banner;
          if (ad == null) return const SizedBox.shrink();
          return SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          );
        },
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRota(),
            const SizedBox(height: AppSpacing.md),
            _buildConfiguracoes(),
            const SizedBox(height: AppSpacing.md),
            _buildBotaoCalcular(),
            if (_erro != null) _buildErro(),
            if (_resultado != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildResultado(_resultado!),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildRota() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Rota'),
          CidadeInput(
            label: 'Origem',
            hint: 'Ex: São Paulo, São Paulo',
            icone: Icons.trip_origin,
            iconColor: AppColors.primary,
            onSelected: (v) => setState(() {
              _cidadeOrigem = v;
              _resultado    = null;
            }),
          ),
          const SizedBox(height: 12),

          // Botão trocar cidades
          Center(
            child: GestureDetector(
              onTap: () => setState(() {
                final tmp     = _cidadeOrigem;
                _cidadeOrigem  = _cidadeDestino;
                _cidadeDestino = tmp;
                _resultado     = null;
              }),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: AppRadius.full,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(Icons.swap_vert,
                    color: AppColors.primary, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),

          CidadeInput(
            label: 'Destino',
            hint: 'Ex: Cuiabá, Mato Grosso',
            icone: Icons.location_on,
            iconColor: AppColors.accent,
            onSelected: (v) => setState(() {
              _cidadeDestino = v;
              _resultado     = null;
            }),
          ),

          // Tags de distância após busca
          if (_distanciaKm != null && _resultado != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                AppBadge.blue('${formatarKm(_distanciaKm!)} por estrada'),
                AppBadge.blue(_resultado!.horas + ' de viagem'),
                AppBadge.green('OpenStreetMap'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfiguracoes() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Configurações do frete'),

          // Tipo de carga
          const SizedBox(height: 8),
          const SectionLabel('Tipo de carga'),
          DropdownButtonFormField<String>(
            value: _tipoCarga,
            style: AppTextStyles.body,
            decoration: const InputDecoration(),
            items: TabelaAntt.fatoresCarga.keys
                .map((tipo) =>
                    DropdownMenuItem(value: tipo, child: Text(tipo)))
                .toList(),
            onChanged: (v) =>
                setState(() {
                  _tipoCarga = v!;
                  _resultado = null;
                }),
          ),

          const SizedBox(height: AppSpacing.md),

          // Eixos
          const SectionLabel('Número de eixos'),
          EixoSelector(
            selecionado: _eixos,
            onChanged: (v) => setState(() {
              _eixos     = v;
              _resultado = null;
            }),
          ),

          const SizedBox(height: AppSpacing.md),

          // Retorno vazio
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _retornoVazio
                  ? AppColors.warningBg
                  : AppColors.surfaceAlt,
              borderRadius: AppRadius.md,
              border: Border.all(
                color: _retornoVazio
                    ? AppColors.accent.withOpacity(0.4)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Retorno vazio',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                      Text('+90% do CCD sobre o trecho de volta',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Switch(
                  value: _retornoVazio,
                  activeColor: AppColors.accent,
                  onChanged: (v) => setState(() {
                    _retornoVazio = v;
                    _resultado    = null;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoCalcular() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _podeCalcular && !_carregando ? _buscarRota : null,
        child: _carregando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calculate, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _podeCalcular
                          ? 'Calcular piso mínimo ANTT'
                          : 'Preencha origem e destino',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErro() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
              child: Text(_erro!,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.danger))),
        ],
      ),
    );
  }

  Widget _buildResultado(ResultadoFrete r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResultadoCard(
          label: 'Piso mínimo legal — Lei 13.703/2018',
          valor: formatarReais(r.pisoMinimo),
          sublabel:
              '${r.cidadeOrigem} → ${r.cidadeDestino} · ${formatarKm(r.distanciaKm)}',
        ),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Detalhamento do cálculo'),
              DetalheRow(
                  label: 'Distância por estrada',
                  valor: formatarKm(r.distanciaKm)),
              DetalheRow(
                  label: 'Tempo estimado', valor: r.horas),
              DetalheRow(
                  label: 'CCD (${r.tipoCarga})',
                  valor: 'R\$ ${r.ccdAplicado.toStringAsFixed(4)}/km'),
              DetalheRow(
                  label: 'CC (carga/descarga)',
                  valor: formatarReais(r.cc)),
              if (r.retornoVazio)
                DetalheRow(
                  label: 'Retorno vazio (+90%)',
                  valor: formatarReais(r.distanciaKm * r.ccdAplicado * 0.9),
                  valorColor: AppColors.warning,
                ),
              DetalheRow(
                  label: 'Eixos da composição',
                  valor: '${r.eixos} eixos'),
              DetalheRow(
                label: 'Portaria vigente',
                valor: TabelaAntt.versao,
                isLast: true,
              ),
            ],
          ),
        ),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Estimativa de custos'),
              DetalheRow(
                label:
                    'Diesel (${_perfil.consumoKmL} km/l · R\$${TabelaAntt.dieselReferencia})',
                valor: formatarReais(r.custoDisel),
                valorColor: AppColors.danger,
              ),
              DetalheRow(
                label: 'Pedágio (estimado)',
                valor: formatarReais(r.custoPedagio),
                valorColor: AppColors.warning,
              ),
              DetalheRow(
                label: 'Margem estimada',
                valor: formatarReais(r.margemEstimada),
                valorColor: AppColors.success,
                isLast: true,
              ),
            ],
          ),
        ),

        // Botão PDF + WhatsApp
        BotaoPdfPremium(resultado: r, perfil: _perfil),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
