class BranchDto {
  final String id;
  final String organizationId;
  final String name;
  final String? address;
  final bool isActive;

  const BranchDto({
    required this.id,
    required this.organizationId,
    required this.name,
    this.address,
    required this.isActive,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) => BranchDto(
        id: json['id'] as String,
        organizationId: json['organizationId'] as String,
        name: json['name'] as String,
        address: json['address'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );
}
