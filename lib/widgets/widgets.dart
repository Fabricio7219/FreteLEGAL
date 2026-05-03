import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';

// ─────────────────────────────────────────────
//  WIDGETS REUTILIZÁVEIS — Frete Pro ANTT
// ─────────────────────────────────────────────

// ── Card padrão ──

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

// ── Card de resultado (verde) ──

class ResultadoCard extends StatelessWidget {
  final String label;
  final String valor;
  final String? sublabel;

  const ResultadoCard({
    super.key,
    required this.label,
    required this.valor,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label.copyWith(
            color: AppColors.success,
          )),
          const SizedBox(height: 6),
          Text(valor, style: AppTextStyles.piso),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(sublabel!, style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success,
            )),
          ],
        ],
      ),
    );
  }
}

// ── Linha de detalhe ──

class DetalheRow extends StatelessWidget {
  final String label;
  final String valor;
  final Color? valorColor;
  final bool isLast;

  const DetalheRow({
    super.key,
    required this.label,
    required this.valor,
    this.valorColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: Text(label, style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                )),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Text(valor,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valorColor ?? AppColors.textPrimary,
                  )),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1),
      ],
    );
  }
}

// ── Label de seção ──

class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsets? margin;

  const SectionLabel(this.text, {super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: AppTextStyles.label),
    );
  }
}

// ── Badge ──

class AppBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;

  const AppBadge({
    super.key,
    required this.text,
    required this.bg,
    required this.textColor,
  });

  factory AppBadge.green(String text) => AppBadge(
    text: text,
    bg: AppColors.successBg,
    textColor: AppColors.success,
  );

  factory AppBadge.amber(String text) => AppBadge(
    text: text,
    bg: AppColors.warningBg,
    textColor: AppColors.warning,
  );

  factory AppBadge.blue(String text) => AppBadge(
    text: text,
    bg: const Color(0xFFE6F1FB),
    textColor: AppColors.primary,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.full,
      ),
      child: Text(text, style: AppTextStyles.bodySmall.copyWith(
        color: textColor, fontWeight: FontWeight.w600,
      )),
    );
  }
}

// ── Selector de eixos (chips) ──

class EixoSelector extends StatelessWidget {
  final int selecionado;
  final ValueChanged<int> onChanged;

  static const _eixos  = [2, 3, 4, 5, 6, 7, 9];
  static const _labels = ['2', '3', '4', '5', '6', '7', '9'];

  const EixoSelector({
    super.key,
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_eixos.length, (i) {
        final eixo     = _eixos[i];
        final selected = eixo == selecionado;
        return GestureDetector(
          onTap: () => onChanged(eixo),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: AppRadius.sm,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _labels[i],
              style: AppTextStyles.h3.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Campo autocomplete de cidade ──

class CidadeInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icone;
  final Color iconColor;
  final ValueChanged<String> onSelected;
  final String? initialValue;

  const CidadeInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icone,
    required this.iconColor,
    required this.onSelected,
    this.initialValue,
  });

  @override
  State<CidadeInput> createState() => _CidadeInputState();
}

class _CidadeInputState extends State<CidadeInput> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  List<String> _sugestoes  = [];
  bool         _carregando = false;
  Timer?       _debounce;

  // Cidades offline para resposta imediata (enquanto API carrega)
  static const _cidadesOffline = [
    'São Paulo, São Paulo', 'Rio de Janeiro, Rio de Janeiro',
    'Belo Horizonte, Minas Gerais', 'Brasília, Distrito Federal',
    'Salvador, Bahia', 'Fortaleza, Ceará', 'Curitiba, Paraná',
    'Manaus, Amazonas', 'Recife, Pernambuco', 'Porto Alegre, Rio Grande do Sul',
    'Goiânia, Goiás', 'Belém, Pará', 'Cuiabá, Mato Grosso',
    'Campo Grande, Mato Grosso do Sul', 'Florianópolis, Santa Catarina',
    'Vitória, Espírito Santo', 'Campinas, São Paulo', 'Santos, São Paulo',
    'Uberlândia, Minas Gerais', 'Londrina, Paraná', 'Maringá, Paraná',
    'Joinville, Santa Catarina', 'Blumenau, Santa Catarina',
    'Caxias do Sul, Rio Grande do Sul', 'Pelotas, Rio Grande do Sul',
    'Ribeirão Preto, São Paulo', 'São José dos Campos, São Paulo',
    'Sorocaba, São Paulo', 'Bauru, São Paulo', 'Cascavel, Paraná',
    'Rondonópolis, Mato Grosso', 'Sinop, Mato Grosso', 'Anápolis, Goiás',
    'Juiz de Fora, Minas Gerais', 'Natal, Rio Grande do Norte',
    'Maceió, Alagoas', 'Teresina, Piauí', 'Aracaju, Sergipe',
    'São Luís, Maranhão', 'João Pessoa, Paraíba', 'Porto Velho, Rondônia',
    'Palmas, Tocantins', 'Macapá, Amapá', 'Boa Vista, Roraima',
    'Rio Branco, Acre', 'Osasco, São Paulo', 'Guarulhos, São Paulo',
    'Feira de Santana, Bahia', 'Imperatriz, Maranhão', 'Marabá, Pará',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _ctrl.text = widget.initialValue!;
    }
  }

  void _onChanged(String val) {
    _debounce?.cancel();
    if (val.length < 2) {
      setState(() { _sugestoes = []; _carregando = false; });
      return;
    }

    // Mostra offline imediatamente
    final termo   = val.toLowerCase();
    final offline = _cidadesOffline
        .where((c) => c.toLowerCase().contains(termo))
      .take(8)
        .toList();
    setState(() { _sugestoes = offline; _carregando = true; });

    // Busca no Nominatim após 500ms sem digitar
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final online = await OsmService.sugerirCidades(val);
      if (!mounted) return;

      // Mescla online + offline removendo duplicatas por nome da cidade
      final merged = <String>[];
      final vistos = <String>{};

      void adicionarSeNovo(String cidade) {
        final nomeBase = cidade.split(',').first.trim().toLowerCase();
        if (!vistos.contains(nomeBase)) {
          vistos.add(nomeBase);
          merged.add(cidade);
        }
      }

      for (final cidade in online) {
        adicionarSeNovo(cidade);
      }
      for (final cidade in offline) {
        adicionarSeNovo(cidade);
      }

      setState(() {
        _sugestoes  = merged.take(12).toList();
        _carregando = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(widget.label),
        TextFormField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: _onChanged,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icone, color: widget.iconColor, size: 20),
            suffixIcon: _carregando
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_sugestoes.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: _sugestoes
                  .map((cidade) => InkWell(
                        onTap: () {
                          _ctrl.text = cidade;
                          setState(() => _sugestoes = []);
                          _focus.unfocus();
                          widget.onSelected(cidade);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: AppColors.textHint),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(cidade, style: AppTextStyles.body)),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }
}

// ── Formatação de moeda ──

String formatarReais(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';
}

String formatarKm(double km) {
  return '${km.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )} km';
}
