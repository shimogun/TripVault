import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/trip_info.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';

class EditableTripHeader extends StatefulWidget {
  final TripInfo tripInfo;
  final Function(TripInfo) onTripInfoChanged;

  const EditableTripHeader({
    super.key,
    required this.tripInfo,
    required this.onTripInfoChanged,
  });

  @override
  State<EditableTripHeader> createState() => _EditableTripHeaderState();
}

class _EditableTripHeaderState extends State<EditableTripHeader> {
  late TripInfo _currentTripInfo;
  final TextEditingController _budgetController = TextEditingController();
  bool _isEditingBudget = false;

  @override
  void initState() {
    super.initState();
    _currentTripInfo = widget.tripInfo;
    _budgetController.text = _currentTripInfo.budgetPerPerson.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: DateTimeRange(
        start: _currentTripInfo.startDate,
        end: _currentTripInfo.endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _currentTripInfo = _currentTripInfo.copyWith(
          startDate: picked.start,
          endDate: picked.end,
        );
      });
      widget.onTripInfoChanged(_currentTripInfo);
    }
  }

  void _saveBudget() {
    final budgetText = _budgetController.text.replaceAll(',', '');
    final budget = double.tryParse(budgetText) ?? _currentTripInfo.budgetPerPerson;
    
    setState(() {
      _currentTripInfo = _currentTripInfo.copyWith(budgetPerPerson: budget);
      _isEditingBudget = false;
    });
    widget.onTripInfoChanged(_currentTripInfo);
  }

  void _cancelBudgetEdit() {
    setState(() {
      _budgetController.text = _currentTripInfo.budgetPerPerson.toStringAsFixed(0);
      _isEditingBudget = false;
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '¥${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.itineraryTab,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 16),
          
          // 日程選択セクション
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight, size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '旅行日程',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _currentTripInfo.dateRangeString,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_currentTripInfo.durationInDays}日間',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 予算編集セクション
          InkWell(
            onTap: () {
              setState(() {
                _isEditingBudget = true;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _isEditingBudget 
                        ? _buildBudgetEditField()
                        : _buildBudgetDisplay(),
                  ),
                  if (!_isEditingBudget)
                    const Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 参加者情報
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${_currentTripInfo.participantCount}名参加',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.calculate, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                '総予算: ${_formatCurrency(_currentTripInfo.totalBudget)}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '予算（1人当たり）',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          _formatCurrency(_currentTripInfo.budgetPerPerson),
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetEditField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '予算（1人当たり）',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    final number = int.tryParse(newValue.text.replaceAll(',', ''));
                    if (number == null) return oldValue;
                    final formatter = NumberFormat('#,###');
                    return TextEditingValue(
                      text: formatter.format(number),
                      selection: TextSelection.collapsed(
                        offset: formatter.format(number).length,
                      ),
                    );
                  }),
                ],
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  border: UnderlineInputBorder(),
                  prefixText: '¥',
                  suffixText: '/人',
                ),
                autofocus: true,
                onSubmitted: (_) => _saveBudget(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.check, color: AppTheme.successColor),
              onPressed: _saveBudget,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.errorColor),
              onPressed: _cancelBudgetEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ],
    );
  }
}