enum UserRole {
  workshop, // Дополнительно
  retailer, // Магазин гаджетов / Продавец
  wholesaler, // Оптовый поставщик (Дордой/Электроника)
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.retailer:
        return 'Магазин гаджетов / Продавец';
      case UserRole.wholesaler:
        return 'Оптовый поставщик (Дордой)';
      case UserRole.workshop:
        return 'Швейный цех / Производство';
    }
  }

  String get shortCode => this == UserRole.retailer ? 'STORE' : 'WHOLESALER';
}

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String location;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.location,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    UserRole? role,
    String? location,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role.index,
        'location': location,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        role: UserRole.values[json['role'] ?? 0],
        location: json['location'] ?? '',
      );
}
