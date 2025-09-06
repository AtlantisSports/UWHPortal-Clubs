/// Base model class following uwhportal data structure patterns
library;

abstract class BaseModel {
  /// Convert model to JSON map for API communication
  Map<String, dynamic> toJson();
  
  /// Create model from JSON map received from API
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclass');
  }
  
  /// Copy model with updated fields
  BaseModel copyWith();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && runtimeType == other.runtimeType;
  }
  
  @override
  int get hashCode => runtimeType.hashCode;
}
