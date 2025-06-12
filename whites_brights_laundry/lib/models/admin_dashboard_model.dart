class AdminDashboardModel {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double revenue;
  final int totalUsers;

  AdminDashboardModel({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.revenue,
    required this.totalUsers,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      revenue: (json['revenue'] is int)
          ? (json['revenue'] as int).toDouble()
          : json['revenue']?.toDouble() ?? 0.0,
      totalUsers: json['totalUsers'] ?? 0,
    );
  }
}
