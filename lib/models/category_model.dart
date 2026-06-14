/// Mapping: Categories Table
/// CategoryId   INT IDENTITY(1,1) PRIMARY KEY
/// CategoryName NVARCHAR(100) NOT NULL
/// CategoryType BIT NOT NULL  →  true = Income (Thu), false = Expense (Chi)
/// IconUrl      VARCHAR(255)  NULL
class CategoryModel {
  final int categoryId;       // INT IDENTITY
  final String categoryName;  // NVARCHAR(100)
  final bool categoryType;    // BIT: true = Income, false = Expense
  final String? iconUrl;      // VARCHAR(255) NULL

  const CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    this.iconUrl,
  });

  /// Tiện lợi: kiểm tra thu/chi
  bool get isIncome => categoryType;
  bool get isExpense => !categoryType;

  // ── Serialization ────────────────────────────────────────────────
  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        categoryId: json['CategoryId'] as int,
        categoryName: json['CategoryName'] as String,
        // SQL BIT có thể trả về 1/0 (int) hoặc true/false (bool)
        categoryType: _parseBool(json['CategoryType']),
        iconUrl: json['IconUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'CategoryId': categoryId,
        'CategoryName': categoryName,
        'CategoryType': categoryType ? 1 : 0, // trả về BIT cho SQL
        'IconUrl': iconUrl,
      };

  CategoryModel copyWith({
    int? categoryId,
    String? categoryName,
    bool? categoryType,
    String? iconUrl,
  }) =>
      CategoryModel(
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        categoryType: categoryType ?? this.categoryType,
        iconUrl: iconUrl ?? this.iconUrl,
      );

  @override
  String toString() =>
      'CategoryModel(id: $categoryId, name: $categoryName, type: ${isIncome ? "Thu" : "Chi"})';
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}
