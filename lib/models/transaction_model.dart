/// Mapping: Transactions Table
/// TransactionId   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID()
/// JarId           UNIQUEIDENTIFIER NOT NULL  (FK → Jars.JarId)
/// UserId          UNIQUEIDENTIFIER NOT NULL  (FK → Users.UserId)
/// CategoryId      INT NOT NULL               (FK → Categories.CategoryId)
/// Amount          DECIMAL(18,2) NOT NULL
/// Description     NVARCHAR(500) NULL
/// ReceiptImageUrl VARCHAR(500)  NULL         -- Ảnh chụp hóa đơn
/// TransactionType BIT NOT NULL  →  true = Income (Thu), false = Expense (Chi)
/// TransactionDate DATETIME DEFAULT GETDATE()

class TransactionModel {
  final String transactionId;    // UNIQUEIDENTIFIER → String (UUID)
  final String jarId;            // FK → Jars.JarId
  final String userId;           // FK → Users.UserId
  final int categoryId;          // FK → Categories.CategoryId
  final double amount;           // DECIMAL(18,2)
  final String? description;     // NVARCHAR(500) NULL
  final String? receiptImageUrl; // VARCHAR(500) NULL – link ảnh hóa đơn
  final bool transactionType;    // BIT: true = Income, false = Expense
  final DateTime transactionDate; // DATETIME

  const TransactionModel({
    required this.transactionId,
    required this.jarId,
    required this.userId,
    required this.categoryId,
    required this.amount,
    this.description,
    this.receiptImageUrl,
    required this.transactionType,
    required this.transactionDate,
  });

  // ── Computed helpers ─────────────────────────────────────────────
  /// true = Thu nhập, false = Chi tiêu
  bool get isIncome => transactionType;
  bool get isExpense => !transactionType;

  /// Số tiền có dấu: Thu → dương, Chi → âm
  double get signedAmount => isIncome ? amount : -amount;

  // ── Serialization ────────────────────────────────────────────────
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        transactionId: json['TransactionId'] as String,
        jarId: json['JarId'] as String,
        userId: json['UserId'] as String,
        categoryId: json['CategoryId'] as int,
        amount: (json['Amount'] as num).toDouble(),
        description: json['Description'] as String?,
        receiptImageUrl: json['ReceiptImageUrl'] as String?,
        transactionType: _parseBit(json['TransactionType']),
        transactionDate: DateTime.parse(json['TransactionDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'TransactionId': transactionId,
        'JarId': jarId,
        'UserId': userId,
        'CategoryId': categoryId,
        'Amount': amount,
        'Description': description,
        'ReceiptImageUrl': receiptImageUrl,
        'TransactionType': transactionType ? 1 : 0,
        'TransactionDate': transactionDate.toIso8601String(),
      };

  TransactionModel copyWith({
    String? transactionId,
    String? jarId,
    String? userId,
    int? categoryId,
    double? amount,
    String? description,
    String? receiptImageUrl,
    bool? transactionType,
    DateTime? transactionDate,
  }) =>
      TransactionModel(
        transactionId: transactionId ?? this.transactionId,
        jarId: jarId ?? this.jarId,
        userId: userId ?? this.userId,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
        transactionType: transactionType ?? this.transactionType,
        transactionDate: transactionDate ?? this.transactionDate,
      );

  @override
  String toString() =>
      'TransactionModel(id: $transactionId, amount: $amount, '
      'type: ${isIncome ? "Thu" : "Chi"}, date: $transactionDate)';
}

/// Parse BIT từ SQL (có thể là int 0/1, bool, hoặc String)
bool _parseBit(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}
