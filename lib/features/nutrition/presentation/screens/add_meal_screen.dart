import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/nutrition_repository.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _name = TextEditingController();
  MealEntryMethod _method = MealEntryMethod.manual;
  MealType _type = MealType.dinner;
  double _protein = 20;
  double _carbs = 25;
  double _fat = 15;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final draft = await context.read<NutritionRepository>().getDefaultMealDraft();
    if (!mounted) return;
    setState(() {
      _type = draft.type;
      _protein = draft.protein;
      _carbs = draft.carbs;
      _fat = draft.fat;
      _method = draft.method;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 20),
            decoration: const BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularIconButton(
                  icon: Icons.arrow_back,
                  backgroundColor: Colors.white12,
                  iconColor: AppColors.white,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add New Meal',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _Tab(
                        label: 'Manual',
                        selected: _method == MealEntryMethod.manual,
                        onTap: () =>
                            setState(() => _method = MealEntryMethod.manual),
                      ),
                      _Tab(
                        label: 'AI Scan',
                        selected: _method == MealEntryMethod.aiScan,
                        onTap: () {
                          setState(() => _method = MealEntryMethod.aiScan);
                          context.pushNamed(RouteNames.mealScan);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveConstrained(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meal Name',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        hintText: 'Enter your meal name...',
                        prefixIcon: const Icon(Icons.restaurant),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Meal Type',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        _TypeChip(
                          label: 'Breakfast',
                          selected: _type == MealType.breakfast,
                          onTap: () =>
                              setState(() => _type = MealType.breakfast),
                        ),
                        _TypeChip(
                          label: 'Dinner',
                          selected: _type == MealType.dinner,
                          onTap: () => setState(() => _type = MealType.dinner),
                        ),
                        _TypeChip(
                          label: 'Snack',
                          selected: _type == MealType.snack,
                          onTap: () => setState(() => _type = MealType.snack),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _MacroSlider(
                      label: 'Total Protein',
                      value: _protein,
                      onChanged: (v) => setState(() => _protein = v),
                    ),
                    const SizedBox(height: 18),
                    _MacroSlider(
                      label: 'Total Carbs',
                      value: _carbs,
                      onChanged: (v) => setState(() => _carbs = v),
                    ),
                    const SizedBox(height: 18),
                    _MacroSlider(
                      label: 'Total Fats',
                      value: _fat,
                      onChanged: (v) => setState(() => _fat = v),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: () async {
                        await context.read<NutritionRepository>().saveMeal(
                              MealDraft(
                                name: _name.text,
                                type: _type,
                                protein: _protein,
                                carbs: _carbs,
                                fat: _fat,
                                method: _method,
                              ),
                            );
                        if (!context.mounted) return;
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? const Color(0xFF3A3A3A) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.chartBlue : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.check_box_outline_blank,
                size: 18,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroSlider extends StatelessWidget {
  const _MacroSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('gram', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceAlt,
            thumbColor: AppColors.primary,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 0,
            ),
          ),
          child: Slider(
            min: 10,
            max: 30,
            value: value.clamp(10, 30),
            onChanged: onChanged,
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10'),
            Text('20'),
            Text('30'),
          ],
        ),
      ],
    );
  }
}
