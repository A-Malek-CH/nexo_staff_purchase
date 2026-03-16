class OrderStats {
  final int total;
  final int pending;
  final int confirmed;
  final int paid;

  OrderStats({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.paid,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      total: (json['total'] ?? 0) as int,
      pending: (json['pending'] ?? 0) as int,
      confirmed: (json['confirmed'] ?? 0) as int,
      paid: (json['paid'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'confirmed': confirmed,
      'paid': paid,
    };
  }

  OrderStats copyWith({
    int? total,
    int? pending,
    int? confirmed,
    int? paid,
  }) {
    return OrderStats(
      total: total ?? this.total,
      pending: pending ?? this.pending,
      confirmed: confirmed ?? this.confirmed,
      paid: paid ?? this.paid,
    );
  }
}

class MonthlyData {
  final String month;
  final int year;
  final int total;
  final double spending;

  MonthlyData({
    required this.month,
    required this.year,
    required this.total,
    required this.spending,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: (json['month'] ?? '') as String,
      year: (json['year'] ?? 0) as int,
      total: (json['total'] ?? 0) as int,
      spending: ((json['spending'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'total': total,
      'spending': spending,
    };
  }
}

class OrderAnalytics {
  final List<MonthlyData> monthlyData;

  OrderAnalytics({required this.monthlyData});

  factory OrderAnalytics.fromJson(Map<String, dynamic> json) {
    final list = json['monthlyData'] as List<dynamic>? ?? [];
    return OrderAnalytics(
      monthlyData: list.map((e) => MonthlyData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyData': monthlyData.map((e) => e.toJson()).toList(),
    };
  }
}
