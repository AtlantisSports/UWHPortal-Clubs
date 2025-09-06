/// Base model class following uwhportal data structure patterns
library;

abstract class BaseModel {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const BaseModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Convert model to JSON map for API communication
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  /// Create model from JSON map received from API
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclass');
  }
  
  /// Copy model with updated fields
  BaseModel copyWith();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && runtimeType == other.runtimeType && id == other.id;
  }
  
  @override
  int get hashCode => Object.hash(runtimeType, id);
}
