enum AuditActionType {
  stockIn,
  stockOut,
  addProduct,
  addDebt,
  payDebt,
  importCsv,
}

class AuditLog {
  final String id;
  final AuditActionType actionType;
  final String title;
  final String details;
  final String userName;
  final String userRole;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.actionType,
    required this.title,
    required this.details,
    required this.userName,
    required this.userRole,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'actionType': actionType.index,
        'title': title,
        'details': details,
        'userName': userName,
        'userRole': userRole,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'],
        actionType: AuditActionType.values[json['actionType'] ?? 0],
        title: json['title'],
        details: json['details'] ?? '',
        userName: json['userName'] ?? '',
        userRole: json['userRole'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
      );
}
