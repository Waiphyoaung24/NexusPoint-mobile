class TableDto {
  final String id;
  final String organizationId;
  final String branchId;
  final int number;
  final String? label;
  final int seats;
  final String shape;
  final int positionX;
  final int positionY;
  final String status;
  final DateTime updatedAt;

  const TableDto({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.number,
    this.label,
    required this.seats,
    required this.shape,
    required this.positionX,
    required this.positionY,
    required this.status,
    required this.updatedAt,
  });

  factory TableDto.fromJson(Map<String, dynamic> json) => TableDto(
    id: json['id'] as String,
    organizationId: json['organizationId'] as String,
    branchId: json['branchId'] as String,
    number: json['number'] as int,
    label: json['label'] as String?,
    seats: json['seats'] as int,
    shape: json['shape'] as String,
    positionX: double.parse(json['positionX'].toString()).toInt(),
    positionY: double.parse(json['positionY'].toString()).toInt(),
    status: json['status'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class TableStatusDto {
  final String id;
  final String status;

  const TableStatusDto({required this.id, required this.status});

  factory TableStatusDto.fromJson(Map<String, dynamic> json) => TableStatusDto(
    id: json['id'] as String,
    status: json['status'] as String,
  );
}
