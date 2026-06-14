/// Mapping: Users Table
/// UserId     UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID()
/// FullName   NVARCHAR(100) NOT NULL
/// Email      VARCHAR(150)  UNIQUE NOT NULL
/// PasswordHash VARCHAR(255) NOT NULL
/// CreatedAt  DATETIME DEFAULT GETDATE()
class UserModel {
  final String userId;       // UNIQUEIDENTIFIER → String (UUID)
  final String fullName;     // NVARCHAR(100)
  final String email;        // VARCHAR(150)
  final String passwordHash; // VARCHAR(255) – chỉ dùng phía server
  final DateTime createdAt;  // DATETIME

  const UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  // ── Serialization ────────────────────────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['UserId'] as String,
        fullName: json['FullName'] as String,
        email: json['Email'] as String,
        passwordHash: json['PasswordHash'] as String? ?? '',
        createdAt: DateTime.parse(json['CreatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'UserId': userId,
        'FullName': fullName,
        'Email': email,
        'PasswordHash': passwordHash,
        'CreatedAt': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
  }) =>
      UserModel(
        userId: userId ?? this.userId,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() => 'UserModel(userId: $userId, fullName: $fullName, email: $email)';
}
