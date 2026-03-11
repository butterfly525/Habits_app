import 'package:flutter/material.dart';

import '../../../../core/cyberpunk_theme.dart';
import '../../../../core/habit_palette.dart';
import '../../domain/entities/habit.dart';

enum HabitSettingsAction { save, delete }

typedef HabitSettingsResult =
    ({
      HabitSettingsAction action,
      String title,
      int colorValue,
      int targetCount,
      HabitGoalPeriod targetPeriod,
    });

class HabitSettingsScreen extends StatefulWidget {
  const HabitSettingsScreen({
    super.key,
    this.initialTitle,
    this.initialColorValue,
    this.initialTargetCount,
    this.initialTargetPeriod,
  });

  final String? initialTitle;
  final int? initialColorValue;
  final int? initialTargetCount;
  final HabitGoalPeriod? initialTargetPeriod;

  @override
  State<HabitSettingsScreen> createState() => _HabitSettingsScreenState();
}

class _HabitSettingsScreenState extends State<HabitSettingsScreen> {
  late final TextEditingController _titleController;
  int _selectedColorValue = habitColorOptions.first.value;
  int _targetCount = 3;
  HabitGoalPeriod _targetPeriod = HabitGoalPeriod.week;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedColorValue = widget.initialColorValue ?? habitColorOptions.first.value;
    _targetCount = widget.initialTargetCount ?? 3;
    _targetPeriod = widget.initialTargetPeriod ?? HabitGoalPeriod.week;
    _targetCount = _targetCount.clamp(1, _maxTargetFor(_targetPeriod));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = habitColorFromValue(_selectedColorValue);
    final scheme = Theme.of(context).colorScheme;
    final availableCounts = List<int>.generate(_maxTargetFor(_targetPeriod), (index) => index + 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialTitle == null ? 'Новая привычка' : 'Изменить привычку',
        ),
        actions: const [
          ThemeModeToggleButton(),
        ],
      ),
      body: CyberpunkBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        hintText: 'Например: Выпить воду',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Цвет карточки',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: habitColorOptions.map((option) {
                        final isSelected = option.value == _selectedColorValue;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _selectedColorValue = option.value;
                            });
                          },
                          child: Container(
                            width: 96,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: habitColorFromValue(option.value).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? habitColorFromValue(option.value)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: habitColorFromValue(option.value),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  option.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Цель выполнения',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: selectedColor.withValues(alpha: 0.30)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _targetCount,
                                  decoration: const InputDecoration(
                                    labelText: 'Количество дней',
                                  ),
                                  items: availableCounts
                                      .map(
                                        (count) => DropdownMenuItem<int>(
                                          value: count,
                                          child: Text('$count'),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _targetCount = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<HabitGoalPeriod>(
                            segments: const [
                              ButtonSegment<HabitGoalPeriod>(
                                value: HabitGoalPeriod.week,
                                label: Text('Неделя'),
                              ),
                              ButtonSegment<HabitGoalPeriod>(
                                value: HabitGoalPeriod.month,
                                label: Text('Месяц'),
                              ),
                              ButtonSegment<HabitGoalPeriod>(
                                value: HabitGoalPeriod.year,
                                label: Text('Год'),
                              ),
                            ],
                            selected: <HabitGoalPeriod>{_targetPeriod},
                            onSelectionChanged: (selection) {
                              setState(() {
                                _targetPeriod = selection.first;
                                final maxTarget = _maxTargetFor(_targetPeriod);
                                if (_targetCount > maxTarget) {
                                  _targetCount = maxTarget;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Цель: $_targetCount раз ${_targetPeriod.label}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Максимум: ${_maxTargetFor(_targetPeriod)} раз ${_targetPeriod.label}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.72),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: _save,
                      child: Text(
                        widget.initialTitle == null ? 'Создать привычку' : 'Сохранить изменения',
                      ),
                    ),
                    if (widget.initialTitle != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
                        ),
                        child: const Text('Удалить привычку'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название привычки')),
      );
      return;
    }

    final maxTarget = _maxTargetFor(_targetPeriod);
    if (_targetCount > maxTarget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Нельзя поставить цель больше $maxTarget раз ${_targetPeriod.label}',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      (
        action: HabitSettingsAction.save,
        title: title,
        colorValue: _selectedColorValue,
        targetCount: _targetCount,
        targetPeriod: _targetPeriod,
      ),
    );
  }

  void _delete() {
    Navigator.of(context).pop(
      (
        action: HabitSettingsAction.delete,
        title: _titleController.text.trim(),
        colorValue: _selectedColorValue,
        targetCount: _targetCount,
        targetPeriod: _targetPeriod,
      ),
    );
  }

  int _maxTargetFor(HabitGoalPeriod period) {
    switch (period) {
      case HabitGoalPeriod.week:
        return 7;
      case HabitGoalPeriod.month:
        return 31;
      case HabitGoalPeriod.year:
        return 366;
    }
  }
}
