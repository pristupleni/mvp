enum ContactRole {
  workshop, // Швейный цех / Покупатель
  supplier, // Поставщик (Дордой / Мадина)
}

class Contact {
  final String id;
  final String name;
  final String phone;
  final ContactRole role;
  final String location; // e.g. "Дордой, проход 12, конт. 850"

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.location = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role.index,
        'location': location,
      };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        role: ContactRole.values[json['role'] ?? 0],
        location: json['location'] ?? '',
      );
}
