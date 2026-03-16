class CategoryAnalytics {
  final String categoryName;
  final int totalOrders;
  final double totalAmount;

  CategoryAnalytics({
    required this.categoryName,
    required this.totalOrders,
    required this.totalAmount,
  });

  factory CategoryAnalytics.fromJson(Map<String, dynamic> json) {
    return CategoryAnalytics(
      categoryName: (json['categoryName'] ?? json['name'] ?? 'Unknown') as String,
      totalOrders: (json['totalOrders'] ?? json['count'] ?? 0) as int,
      totalAmount: ((json['totalAmount'] ?? json['amount'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'totalOrders': totalOrders,
      'totalAmount': totalAmount,
    };
  }
}

class MonthlyAnalytics {
  final String month;
  final int year;
  final int totalOrders;
  final double totalAmount;
  final int pendingCount;
  final int paidCount;

  MonthlyAnalytics({
    required this.month,
    required this.year,
    required this.totalOrders,
    required this.totalAmount,
    required this.pendingCount,
    required this.paidCount,
  });

  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalytics(
      month: (json['month'] ?? '') as String,
      year: (json['year'] ?? 0) as int,
      totalOrders: (json['totalOrders'] ?? json['total'] ?? 0) as int,
      totalAmount: ((json['totalAmount'] ?? json['amount'] ?? 0) as num).toDouble(),
      pendingCount: (json['pendingCount'] ?? json['pending'] ?? 0) as int,
      paidCount: (json['paidCount'] ?? json['paid'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'totalOrders': totalOrders,
      'totalAmount': totalAmount,
      'pendingCount': pendingCount,
      'paidCount': paidCount,
    };
  }
}
