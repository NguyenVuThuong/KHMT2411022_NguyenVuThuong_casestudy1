import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../models/transaction_category.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_chip.dart';
import '../widgets/donut_chart.dart';

enum StatsPeriod { thisMonth, lastMonth, thisYear }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.thisMonth;

  DateTimeRange _rangeFor(StatsPeriod period, DateTime now) {
    return switch (period) {
      StatsPeriod.thisMonth => DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0), // ngày cuối tháng
      ),
      StatsPeriod.lastMonth => DateTimeRange(
        start: DateTime(now.year, now.month - 1, 1),
        end: DateTime(now.year, now.month, 0), // ngày cuối tháng trước
      ),
      StatsPeriod.thisYear => DateTimeRange(
        start: DateTime(now.year, 1, 1),
        end: DateTime(now.year, 12, 31),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = TransactionController.instance;

    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final range = _rangeFor(_period, DateTime.now());
          final from = toIsoDate(range.start);
          final to = toIsoDate(range.end);

          // Gom tổng chi tiêu theo danh mục trong khoảng thời gian đã chọn
          final byCategory = <String, double>{};
          for (final t in controller.items) {
            if (!t.isExpense) continue;
            if (t.date.compareTo(from) < 0 || t.date.compareTo(to) > 0) {
              continue;
            }
            byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
          }

          // Danh mục chi nhiều nhất xếp trên cùng
          final entries = byCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final total = entries.fold<double>(0, (sum, e) => sum + e.value);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppChip(
                    label: 'Tháng này',
                    selected: _period == StatsPeriod.thisMonth,
                    onTap: () =>
                        setState(() => _period = StatsPeriod.thisMonth),
                  ),
                  AppChip(
                    label: 'Tháng trước',
                    selected: _period == StatsPeriod.lastMonth,
                    onTap: () =>
                        setState(() => _period = StatsPeriod.lastMonth),
                  ),
                  AppChip(
                    label: 'Năm nay',
                    selected: _period == StatsPeriod.thisYear,
                    onTap: () => setState(() => _period = StatsPeriod.thisYear),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${formatDate(range.start)} – ${formatDate(range.end)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: DonutChart(
                  values: [for (final e in entries) e.value],
                  colors: [
                    for (final e in entries)
                      TransactionCategory.find(e.key, isExpense: true).color,
                  ],
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatCurrency(total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tổng chi tiêu',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Chưa có khoản chi nào trong khoảng thời gian này.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                for (final e in entries)
                  _LegendRow(
                    color: TransactionCategory.find(
                      e.key,
                      isExpense: true,
                    ).color,
                    name: e.key,
                    amount: e.value,
                    percent: (e.value / total * 100).round(),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.amount,
    required this.percent,
  });

  final Color color;
  final String name;
  final double amount;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            formatCurrency(amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
