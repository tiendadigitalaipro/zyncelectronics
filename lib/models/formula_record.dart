class FormulaRecord {
  final String id;
  final double total;
  final DateTime fecha;

  const FormulaRecord({required this.id, required this.total, required this.fecha});

  double get p50 => total * 0.5;
  double get p30 => total * 0.3;
  double get p20 => total * 0.2;

  Map<String, dynamic> toJson() => {'id': id, 'total': total, 'date': fecha.toIso8601String()};

  factory FormulaRecord.fromJson(Map<String, dynamic> json) => FormulaRecord(
        id: json['id'].toString(),
        total: (json['total'] as num?)?.toDouble() ?? 0,
        fecha: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );
}
