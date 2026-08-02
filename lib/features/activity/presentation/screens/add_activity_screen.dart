import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  int _selected = 0;

  static const _labels = [
    'Jogging',
    'Running',
    'Cycling',
    'Yoga',
    'Weights',
    'Swimming',
    'Basketball',
    'Hiking',
    'HIIT',
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircularIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => context.pop(),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add New Activity',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please select activity type',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    itemCount: _labels.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, i) {
                      final selected = i == _selected;
                      return Material(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          onTap: () => setState(() => _selected = i),
                          borderRadius: BorderRadius.circular(22),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_run,
                                size: 32,
                                color: selected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _labels[i],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                PrimaryButton(
                  label: 'Continue',
                  style: PrimaryButtonStyle.orange,
                  showIcon: false,
                  onPressed: () => context.pushNamed(RouteNames.directions),
                ),
                SizedBox(height: bottom + 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
