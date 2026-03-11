import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch_dto.dart';
import '../../../core/models/user.dart';
import '../../../core/theme/pos_theme.dart';
import '../providers/auth_provider.dart';

class BranchSelectionScreen extends ConsumerStatefulWidget {
  final User user;
  final List<BranchDto> branches;

  const BranchSelectionScreen({
    super.key,
    required this.user,
    required this.branches,
  });

  @override
  ConsumerState<BranchSelectionScreen> createState() =>
      _BranchSelectionScreenState();
}

class _BranchSelectionScreenState
    extends ConsumerState<BranchSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedBranchId;
  late final List<AnimationController> _cardControllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    // Staggered card animations
    _cardControllers = List.generate(
      widget.branches.length,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _fadeAnimations = _cardControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOut);
    }).toList();

    _slideAnimations = _cardControllers.map((c) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    }).toList();

    // Stagger start
    for (var i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onBranchSelected(BranchDto branch) async {
    if (_selectedBranchId != null) return; // Prevent double-tap

    setState(() => _selectedBranchId = branch.id);

    // Brief delay for selection animation
    await Future.delayed(const Duration(milliseconds: 300));

    await ref.read(authProvider.notifier).selectBranch(branch.id);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final maxWidth = isTablet ? 480.0 : double.infinity;
    final horizontalPadding = isTablet ? 0.0 : 24.0;

    return Scaffold(
      backgroundColor: PosTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo / Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [PosTheme.primaryBlue, PosTheme.secondaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PosTheme.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Select your branch',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Choose the location you\'re working at today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PosTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Branch cards
                  Expanded(
                    flex: 5,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: widget.branches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final branch = widget.branches[index];
                        final isSelected = _selectedBranchId == branch.id;

                        return FadeTransition(
                          opacity: _fadeAnimations[index],
                          child: SlideTransition(
                            position: _slideAnimations[index],
                            child: _BranchCard(
                              branch: branch,
                              isSelected: isSelected,
                              isDisabled:
                                  _selectedBranchId != null && !isSelected,
                              onTap: () => _onBranchSelected(branch),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Logged in as
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Logged in as ${widget.user.email}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final BranchDto branch;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Select ${branch.name} branch',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? PosTheme.primaryBlue.withValues(alpha: 0.04)
              : PosTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? PosTheme.primaryBlue : PosTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PosTheme.primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [PosTheme.shadowSm],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Active indicator
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PosTheme.successGreen,
                      boxShadow: [
                        BoxShadow(
                          color:
                              PosTheme.successGreen.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Branch info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (branch.address != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            branch.address!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: PosTheme.textSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Selection indicator
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            key: ValueKey('check'),
                            color: PosTheme.primaryBlue,
                            size: 24,
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            key: const ValueKey('chevron'),
                            color: PosTheme.textSecondary
                                .withValues(alpha: 0.5),
                            size: 24,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
