class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final int price;
  final String features;
  final int userCount;
  final int storageLimit;
  final bool status;
  final int validity;
  final String createdBy;
  final String modifiedBy;
  final String createdDate;
  final String modifiedDate;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    required this.userCount,
    required this.storageLimit,
    required this.status,
    required this.validity,
    required this.createdBy,
    required this.modifiedBy,
    required this.createdDate,
    required this.modifiedDate,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      features: json['features'],
      userCount: json['user_count'],
      storageLimit: json['storage_limit'],
      status: json['status'],
      validity: json['validity'] ?? 0, // Provide a default value of 0 if validity is null
      createdBy: json['created_by'] ?? "", // Handle null value
      modifiedBy: json['modified_by'] ?? " ",
      createdDate: json['created_date'],
      modifiedDate: json['modified_date'],
    );
  }
}
