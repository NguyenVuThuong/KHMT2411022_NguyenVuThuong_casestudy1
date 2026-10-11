import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import '../utils/text_utils.dart';
import 'transaction_category.dart';
import 'transaction_model.dart';

enum TransactionTypeFilter { all, income, expense }

enum DatePreset { all, today, last7Days, thisMonth, custom }

class TransactionFilter {
  const TransactionFilter({
    this.keyword = '',
    this.type = TransactionTypeFilter.all,
    this.categoryName,
    this.preset = DatePreset.all,
    this.customRange,
  });

  final String keyword;
  final TransactionTypeFilter type;

  /// null = tất cả danh mục
  final String? categoryName;
  final DatePreset preset;

  /// Chỉ dùng khi [preset] == DatePreset.custom
  final DateTimeRange? customRange;

  bool get hasAdvancedFilter =>
      type != TransactionTypeFilter.all ||
      categoryName != null ||
      preset != DatePreset.all;

  bool get isFiltering => hasAdvancedFilter || keyword.trim().isNotEmpty;

  TransactionFilter withKeyword(String value) {
    return TransactionFilter(
      keyword: value,
      type: type,
      categoryName: categoryName,
      preset: preset,
      customRange: customRange,
    );
  }

  TransactionFilter withType(TransactionTypeFilter newType) {
    var category = categoryName;
    if (category != null && newType != TransactionTypeFilter.all) {
      final isExpense = newType == TransactionTypeFilter.expense;
      final belongs = TransactionCategory.forType(isExpense)
          .any((c) => c.name == categoryName);
      if (!belongs) category = null;
    }
    return TransactionFilter(
      keyword: keyword,
      type: newType,
      categoryName: category,
      preset: preset,
      customRange: customRange,
    );
  }

  DateTimeRange? resolveRange(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (preset) {
      case DatePreset.all:
        return null;
      case DatePreset.today:
        return DateTimeRange(start: today, end: today);
      case DatePreset.last7Days:
        return DateTimeRange(
          start: DateTime(today.year, today.month, today.day - 6),
          end: today,
        );
      case DatePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case DatePreset.custom:
        return customRange;
    }
  }

  List<TransactionModel> apply(List<TransactionModel> source) {
    final range = resolveRange(DateTime.now());
    // Ngày lưu dạng ISO "yyyy-MM-dd" nên so sánh chuỗi cũng đúng thứ tự thời gian
    final from = range == null ? null : toIsoDate(range.start);
    final to = range == null ? null : toIsoDate(range.end);
    final query = removeDiacritics(keyword.trim());

    return source.where((t) {
      if (type == TransactionTypeFilter.income && !t.isIncome) return false;
      if (type == TransactionTypeFilter.expense && !t.isExpense) return false;
      if (categoryName != null && t.category != categoryName) return false;
      if (from != null && t.date.compareTo(from) < 0) return false;
      if (to != null && t.date.compareTo(to) > 0) return false;
      if (query.isNotEmpty) {
        final haystack = removeDiacritics('${t.title} ${t.category}');
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();
  }
}
