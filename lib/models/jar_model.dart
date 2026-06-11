/// Mapping: Jars Table
/// JarId           UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID()
/// JarName         NVARCHAR(100) NOT NULL
/// Description     NVARCHAR(255) NULL
/// Budget          DECIMAL(18,2) DEFAULT 0
/// JarType         TINYINT DEFAULT 1   →  1: Personal, 2: Shared/Group
/// CreatedByUserId UNIQUEIDENTIFIER NOT NULL  (FK → Users.UserId)
/// CreatedAt       DATETIME DEFAULT GETDATE()

/// Enum tương ứng JarType TINYINT
enum JarType {
  personal, // 1 - Cá nhân
  shared,   // 2 - Nhóm / Chia sẻ
}

extension JarTypeExtension on JarType {
  int get value => index + 1; // personal=1, shared=2

  static JarType fromValue(int v) {
    switch (v) {
      case 2:
        return JarType.shared;
      default:
        return JarType.personal;
    }
  }

  String get label {
    switch (this) {
      case JarType.personal:
        return 'Cá nhân';
      case JarType.shared:
        return 'Nhóm';
    }
  }
}

class JarModel {
  final String jarId;            // UNIQUEIDENTIFIER → String (UUID)
  final String jarName;          // NVARCHAR(100)
  final String? description;     // NVARCHAR(255) NULL
  final double budget;           // DECIMAL(18,2) – hạn mức / ngân sách
  final JarType jarType;         // TINYINT: 1=Personal, 2=Shared
  final String createdByUserId;  // FK → Users.UserId
  final DateTime createdAt;      // DATETIME

  // ── Trường bổ sung dùng trong UI (không có trong DB) ──────────────
  /// Tổng đã chi trong hũ này (tính từ Transactions)
  double spentAmount;

  JarModel({
    required this.jarId,
    required this.jarName,
    this.description,
    this.budget = 0,
    this.jarType = JarType.personal,
    required this.createdByUserId,
    required this.createdAt,
    this.spentAmount = 0,
  });

  // ── Computed properties ──────────────────────────────────────────
  /// Số tiền còn lại = Budget - SpentAmount
  double get remaining => budget - spentAmount;

  /// Phần trăm đã dùng (0.0 → 1.0)
  double get usagePercent =>
      budget > 0 ? (spentAmount / budget).clamp(0.0, 1.0) : 0.0;

  /// Có vượt ngân sách không?
  bool get isOverBudget => spentAmount > budget;

  // ── Serialization ────────────────────────────────────────────────
  factory JarModel.fromJson(Map<String, dynamic> json) => JarModel(
        jarId: json['JarId'] as String,
        jarName: json['JarName'] as String,
        description: json['Description'] as String?,
        budget: (json['Budget'] as num?)?.toDouble() ?? 0,
        jarType: JarTypeExtension.fromValue(json['JarType'] as int? ?? 1),
        createdByUserId: json['CreatedByUserId'] as String,
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        spentAmount: (json['SpentAmount'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'JarId': jarId,
        'JarName': jarName,
        'Description': description,
        'Budget': budget,
        'JarType': jarType.value,
        'CreatedByUserId': createdByUserId,
        'CreatedAt': createdAt.toIso8601String(),
      };

  JarModel copyWith({
    String? jarId,
    String? jarName,
    String? description,
    double? budget,
    JarType? jarType,
    String? createdByUserId,
    DateTime? createdAt,
    double? spentAmount,
  }) =>
      JarModel(
        jarId: jarId ?? this.jarId,
        jarName: jarName ?? this.jarName,
        description: description ?? this.description,
        budget: budget ?? this.budget,
        jarType: jarType ?? this.jarType,
        createdByUserId: createdByUserId ?? this.createdByUserId,
        createdAt: createdAt ?? this.createdAt,
        spentAmount: spentAmount ?? this.spentAmount,
      );

  @override
  String toString() =>
      'JarModel(jarId: $jarId, jarName: $jarName, budget: $budget, spent: $spentAmount)';
}
