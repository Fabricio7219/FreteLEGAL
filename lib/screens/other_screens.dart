import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

// ─────────────────────────────────────────────
//  TELA HISTÓRICO
// ─────────────────────────────────────────────

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<ResultadoFrete> _lista    = [];
  bool                 _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await StorageService.carregarHistorico();
    setState(() {
      _lista      = lista;
      _carregando = false;
    });
  }

  Future<void> _limpar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: Text('Limpar histórico', style: AppTextStyles.h2),
        content: Text(
            'Todos os registros serão apagados do dispositivo.',
            style: AppTextStyles.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Limpar')),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.limparHistorico();
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          if (_lista.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _limpar,
              tooltip: 'Limpar histórico',
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _lista.isEmpty
              ? _buildVazio()
              : _buildLista(),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('Nenhum cálculo ainda',
              style:
                  AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Seus fretes calculados aparecerão aqui',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _lista.length,
      itemBuilder: (ctx, i) => _ItemHistorico(frete: _lista[i]),
    );
  }
}

class _ItemHistorico extends StatelessWidget {
  final ResultadoFrete frete;
  const _ItemHistorico({required this.frete});

  String _formatarData(DateTime dt) {
    final agora = DateTime.now();
    final diff  = agora.difference(dt);
    if (diff.inDays == 0)
      return 'Hoje · ${dt.hour}h${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1)
      return 'Ontem · ${dt.hour}h${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(frete.rota,
                    style: AppTextStyles.h3,
                    overflow: TextOverflow.ellipsis),
              ),
              Text(formatarReais(frete.pisoMinimo),
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              AppBadge.blue(formatarKm(frete.distanciaKm)),
              AppBadge.blue('${frete.eixos} eixos'),
              AppBadge.blue(frete.tipoCarga),
              if (frete.retornoVazio) AppBadge.amber('Retorno vazio'),
            ],
          ),
          const SizedBox(height: 6),
          Text(_formatarData(frete.calculadoEm),
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TELA TABELA ANTT
// ─────────────────────────────────────────────

class TabelaScreen extends StatelessWidget {
  const TabelaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tabela ANTT 2026')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Info portaria
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Portaria SUROC 3/2026',
                      style: AppTextStyles.h2
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                      'Resolução ANTT nº 6.076/2026 · Lei nº 13.703/2018',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  Text('Reajuste de ~4,82% sobre a Resolução anterior',
                      style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Fórmula
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Fórmula oficial'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: AppRadius.md,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      'Piso (R\$) = (Distância × CCD) + CC',
                      style: AppTextStyles.mono.copyWith(
                        color: AppColors.primary, fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow('CCD',
                      'Coeficiente de Custo de Deslocamento (R\$/km)'),
                  _InfoRow('CC',
                      'Coeficiente de Carga e Descarga (R\$ fixo)'),
                  _InfoRow('Retorno vazio',
                      '+90% do CCD sobre o trecho de volta'),
                ],
              ),
            ),

            // Tabela de coeficientes
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Coeficientes — Granel Sólido'),
                  const SizedBox(height: 8),
                  // Cabeçalho
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('Eixos',
                                style: AppTextStyles.label
                                    .copyWith(color: Colors.white))),
                        Expanded(
                            child: Text('CCD (R\$/km)',
                                style: AppTextStyles.label.copyWith(
                                    color: Colors.white),
                                textAlign: TextAlign.center)),
                        Expanded(
                            child: Text('CC (R\$)',
                                style: AppTextStyles.label.copyWith(
                                    color: Colors.white),
                                textAlign: TextAlign.end)),
                      ],
                    ),
                  ),
                  // Linhas
                  ...TabelaAntt.coeficientes.asMap().entries.map((e) {
                    final i       = e.key;
                    final c       = e.value;
                    final destaque = c.eixos == 5; // mais comum
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: destaque
                            ? AppColors.accent.withOpacity(0.08)
                            : i.isEven
                                ? AppColors.surface
                                : AppColors.surfaceAlt,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text('${c.eixos} eixos',
                                  style: AppTextStyles.body.copyWith(
                                      fontWeight: destaque
                                          ? FontWeight.w700
                                          : FontWeight.w400)),
                              if (destaque)
                                AppBadge.amber('comum'),
                            ],
                          )),
                          Expanded(
                              child: Text(
                            c.ccd.toStringAsFixed(4),
                            style: AppTextStyles.mono,
                            textAlign: TextAlign.center,
                          )),
                          Expanded(
                              child: Text(
                            formatarReais(c.cc),
                            style: AppTextStyles.mono,
                            textAlign: TextAlign.end,
                          )),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Fatores de carga
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Multiplicadores por tipo de carga'),
                  const SizedBox(height: 8),
                  ...TabelaAntt.fatoresCarga.entries.map((e) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: AppTextStyles.body),
                            Text(
                              '×${e.value.toStringAsFixed(2)}',
                              style: AppTextStyles.mono.copyWith(
                                color: e.value > 1.0
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // Regras especiais
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Regras especiais'),
                  _InfoRow('Eixos suspensos',
                      'A PNPM-TRC considera TODOS os eixos, suspensos ou não'),
                  _InfoRow('Gatilho do diesel',
                      'Reajuste automático quando Diesel S10 varia +5%'),
                  _InfoRow('Alto desempenho',
                      'Operações com carga/descarga reduzida (Tabelas C e D)'),
                  _InfoRow('Diesel referência',
                      'R\$ ${TabelaAntt.dieselReferencia}/litro (Portaria vigente)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.accent, shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.body,
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: value,
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TELA PERFIL DO VEÍCULO
// ─────────────────────────────────────────────

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  PerfilVeiculo _perfil  = const PerfilVeiculo();
  bool          _salvando = false;
  bool          _salvo    = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final p = await StorageService.carregarPerfil();
    setState(() => _perfil = p);
  }

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _salvo    = false;
    });
    await StorageService.salvarPerfil(_perfil);
    setState(() {
      _salvando = false;
      _salvo    = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _salvo = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Meu veículo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Ícone do caminhão
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.lg,
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_shipping,
                      size: 56, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(_perfil.apelido,
                      style:
                          AppTextStyles.h2.copyWith(color: Colors.white)),
                  Text(
                    '${_perfil.composicao.label} · ${_perfil.totalEixos} eixos',
                    style: AppTextStyles.body
                        .copyWith(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Identificação'),
                  TextFormField(
                    initialValue: _perfil.apelido,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'Apelido do veículo',
                      hintText: 'Ex: Meu Scania 500',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    onChanged: (v) =>
                        setState(() => _perfil = _perfil.copyWith(apelido: v)),
                  ),
                ],
              ),
            ),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Composição'),
                  DropdownButtonFormField<TipoComposicao>(
                    value: _perfil.composicao,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de composição',
                      prefixIcon: Icon(Icons.directions_car_outlined),
                    ),
                    items: TipoComposicao.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text('${t.icone} ${t.label}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _perfil = _perfil.copyWith(
                          composicao: v,
                          totalEixos: v?.eixos,
                        )),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SectionLabel('Total de eixos'),
                  EixoSelector(
                    selecionado: _perfil.totalEixos,
                    onChanged: (v) =>
                        setState(() => _perfil = _perfil.copyWith(totalEixos: v)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<TipoImplemento>(
                    value: _perfil.implemento,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de implemento',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    items: TipoImplemento.values
                        .map((t) => DropdownMenuItem(
                              value: t, child: Text(t.label)))
                        .toList(),
                    onChanged: (v) => setState(() =>
                        _perfil = _perfil.copyWith(implemento: v)),
                  ),
                ],
              ),
            ),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Desempenho'),
                  TextFormField(
                    initialValue: _perfil.consumoKmL.toString(),
                    style: AppTextStyles.body,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Consumo médio (km/l)',
                      hintText: 'Ex: 2.8',
                      prefixIcon: Icon(Icons.local_gas_station_outlined),
                      suffixText: 'km/l',
                    ),
                    onChanged: (v) {
                      final d = double.tryParse(v.replaceAll(',', '.'));
                      if (d != null) {
                        setState(() =>
                            _perfil = _perfil.copyWith(consumoKmL: d));
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: _perfil.capacidadeTon.toString(),
                    style: AppTextStyles.body,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Capacidade de carga (ton)',
                      hintText: 'Ex: 28',
                      prefixIcon: Icon(Icons.fitness_center_outlined),
                      suffixText: 'ton',
                    ),
                    onChanged: (v) {
                      final d = double.tryParse(v.replaceAll(',', '.'));
                      if (d != null) {
                        setState(() =>
                            _perfil = _perfil.copyWith(capacidadeTon: d));
                      }
                    },
                  ),
                ],
              ),
            ),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvo
                    ? const Icon(Icons.check)
                    : _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                label: Text(_salvo
                    ? 'Salvo no dispositivo!'
                    : 'Salvar dados do veículo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _salvo ? AppColors.success : AppColors.accent,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            Text(
              'Dados salvos apenas neste dispositivo.\nSem cadastro ou login necessário.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
