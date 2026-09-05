import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Row(
            children: [
              if (wide)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.spa_outlined,
                            size: 88,
                            color: AppColors.brown,
                          ),
                          SizedBox(height: 40),
                          Text(
                            'Ruang untuk\nhari yang lebih baik.',
                            style: TextStyle(
                              fontSize: 44,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Mulai dari langkah kecil.\nSusun rencana, temukan ritmemu.',
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.7,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 40 : 24,
                    vertical: 28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
