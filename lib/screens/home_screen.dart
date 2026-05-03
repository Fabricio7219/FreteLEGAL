import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'calcular_screen.dart';
import 'other_screens.dart';

// ─────────────────────────────────────────────
//  TELA HOME — Dashboard principal
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PerfilVeiculo         _perfil   = const PerfilVeiculo();
  List<ResultadoFrete>  _historico = [];
  int                   _tabIndex  = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final perfil    = await StorageService.carregarPerfil();
    final historico = await StorageService.carregarHistorico();
    setState(() {
      _perfil    = perfil;
      _historico = historico;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _tabIndex == 0
          ? _buildHome()
          : _tabIndex == 1
              ? const CalcularScreen()
              : _tabIndex == 2
                  ? const HistoricoScreen()
                  : _tabIndex == 3
                      ? const TabelaScreen()
                      : const PerfilScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildTabelaAtiva(),
            const SizedBox(height: AppSpacing.md),
            _buildAcoesRapidas(),
            const SizedBox(height: AppSpacing.md),
            if (_historico.isNotEmpty) _buildUltimoCalculo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Frete Legal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.primary,
                  )),
              Text('Piso minimo ${DateTime.now().year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.accent,
                  )),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: AppRadius.full,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _perfil.apelido,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabelaAtiva() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tabela atualizada',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  )),
              Text(
                  'Portaria ${TabelaAntt.versao} · ${TabelaAntt.dataPublicacao}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success.withOpacity(0.8),
                  )),
            ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcoesRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Ações rápidas'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _AcaoBtn(
              icone: Icons.calculate_outlined,
              label: 'Calcular\nfrete',
              cor: AppColors.primary,
              onTap: () => setState(() => _tabIndex = 1),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _AcaoBtn(
              icone: Icons.table_chart_outlined,
              label: 'Ver tabela\nANTT',
              cor: AppColors.accent,
              onTap: () => setState(() => _tabIndex = 3),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _AcaoBtn(
              icone: Icons.history,
              label: 'Histórico\nde fretes',
              cor: const Color(0xFF546E7A),
              onTap: () => setState(() => _tabIndex = 2),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _AcaoBtn(
              icone: Icons.local_shipping_outlined,
              label: 'Meu\nveículo',
              cor: const Color(0xFF37474F),
              onTap: () => setState(() => _tabIndex = 4),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildUltimoCalculo() {
    final ultimo = _historico.first;
    return AppCard(
      onTap: () => setState(() => _tabIndex = 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Último cálculo', style: AppTextStyles.label),
              Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: 8),
          Text(ultimo.rota, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Row(
            children: [
              AppBadge.blue(formatarKm(ultimo.distanciaKm)),
              const SizedBox(width: 8),
              AppBadge.green(formatarReais(ultimo.pisoMinimo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _tabIndex,
      onTap: (i) => setState(() => _tabIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate_outlined),
          activeIcon: Icon(Icons.calculate),
          label: 'Calcular',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Histórico',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_chart_outlined),
          activeIcon: Icon(Icons.table_chart),
          label: 'Tabela',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping),
          label: 'Veículo',
        ),
      ],
    );
  }
}

class _AcaoBtn extends StatelessWidget {
  final IconData icone;
  final String label;
  final Color cor;
  final VoidCallback onTap;

  const _AcaoBtn({
    required this.icone,
    required this.label,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: AppRadius.sm,
              ),
              child: Icon(icone, color: cor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                )),
          ],
        ),
      ),
    );
  }
}
