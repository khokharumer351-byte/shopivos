import 'json_utils.dart';

class Profile {
  const Profile({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.role = 'customer',
    this.createdAt,
  });

  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String role;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  String get displayName {
    final name = fullName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    return email?.split('@').first ?? 'Shopper';
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'] as String,
    email: map['email'] as String?,
    fullName: map['full_name'] as String?,
    phone: map['phone'] as String?,
    address: map['address'] as String?,
    city: map['city'] as String?,
    postalCode: map['postal_code'] as String?,
    country: map['country'] as String?,
    role: (map['role'] ?? 'customer') as String,
    createdAt: toDate(map['created_at']),
  );

  Profile copyWith({
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? role,
  }) => Profile(
    id: id,
    email: email,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    city: city ?? this.city,
    postalCode: postalCode ?? this.postalCode,
    country: country ?? this.country,
    role: role ?? this.role,
    createdAt: createdAt,
  );

  Map<String, dynamic> toUpdateMap() => {
    'full_name': fullName,
    'phone': phone,
    'address': address,
    'city': city,
    'postal_code': postalCode,
    'country': country,
  };
}
