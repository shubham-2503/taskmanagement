class Organization {
  final String orgId;
  final String name;
  final String createdTime;
  final String address;
  final int employees;
  bool isSelected;

  Organization({
    required this.orgId,
    required this.name,
    required this.createdTime,
    required this.address,
    required this.employees,
    this.isSelected = false,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      orgId: json['org_id'],
      name: json['name'],
      createdTime: json['created_time'],
      address: json['address'],
      employees: json['employees'],
    );
  }
}
