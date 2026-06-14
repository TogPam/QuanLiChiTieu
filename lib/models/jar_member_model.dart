/// Mapping: JarMembers Table  (Bảng quan hệ N-N giữa Jars và Users)
/// JarId    UNIQUEIDENTIFIER NOT NULL  (PK + FK → Jars.JarId)
/// UserId   UNIQUEIDENTIFIER NOT NULL  (PK + FK → Users.UserId)
/// Role     VARCHAR(20) DEFAULT 'Member'  →  'Owner' | 'Co-owner' | 'Member'
/// JoinedAt DATETIME DEFAULT GETDATE()

/// Enum tương ứng cột Role VARCHAR(20)
enum JarMemberRole {
  owner,    // 'Owner'
  coOwner,  // 'Co-owner'
  member,   // 'Member'
}

extension JarMemberRoleExtension on JarMemberRole {
  String get value {
    switch (this) {
      case JarMemberRole.owner:
        return 'Owner';
      case JarMemberRole.coOwner:
        return 'Co-owner';
      case JarMemberRole.member:
        return 'Member';
    }
  }

  static JarMemberRole fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'owner':
        return JarMemberRole.owner;
      case 'co-owner':
        return JarMemberRole.coOwner;
      default:
        return JarMemberRole.member;
    }
  }

  String get label {
    switch (this) {
      case JarMemberRole.owner:
        return 'Chủ hũ';
      case JarMemberRole.coOwner:
        return 'Đồng quản lý';
      case JarMemberRole.member:
        return 'Thành viên';
    }
  }
}

class JarMemberModel {
  final String jarId;    // FK → Jars.JarId
  final String userId;   // FK → Users.UserId
  final JarMemberRole role; // 'Owner' | 'Co-owner' | 'Member'
  final DateTime joinedAt;  // DATETIME

  const JarMemberModel({
    required this.jarId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  // ── Serialization ────────────────────────────────────────────────
  factory JarMemberModel.fromJson(Map<String, dynamic> json) => JarMemberModel(
        jarId: json['JarId'] as String,
        userId: json['UserId'] as String,
        role: JarMemberRoleExtension.fromString(json['Role'] as String?),
        joinedAt: DateTime.parse(json['JoinedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'JarId': jarId,
        'UserId': userId,
        'Role': role.value,
        'JoinedAt': joinedAt.toIso8601String(),
      };

  JarMemberModel copyWith({
    String? jarId,
    String? userId,
    JarMemberRole? role,
    DateTime? joinedAt,
  }) =>
      JarMemberModel(
        jarId: jarId ?? this.jarId,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
      );

  @override
  String toString() =>
      'JarMemberModel(jarId: $jarId, userId: $userId, role: ${role.value})';
}
