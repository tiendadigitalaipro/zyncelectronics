class Devolucion {
  final String id;
  final String saleId;
  final int ticketNum;
  final String cliente;
  final String productoId;
  final String productoDesc;
  final int qty;
  final double total;
  final String motivo;
  final DateTime fecha;

  const Devolucion({
    required this.id,
    required this.saleId,
    required this.ticketNum,
    required this.cliente,
    required this.productoId,
    required this.productoDesc,
    required this.qty,
    required this.total,
    required this.motivo,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'saleId': saleId,
        'ticketNum': ticketNum,
        'client': cliente,
        'productId': productoId,
        'productDesc': productoDesc,
        'qty': qty,
        'total': total,
        'reason': motivo,
        'date': fecha.toIso8601String(),
      };

  factory Devolucion.fromJson(Map<String, dynamic> json) => Devolucion(
        id: json['id'].toString(),
        saleId: json['saleId'].toString(),
        ticketNum: json['ticketNum'] ?? 0,
        cliente: json['client'] ?? 'CLIENTE GENÉRICO',
        productoId: json['productId'].toString(),
        productoDesc: json['productDesc'] ?? '',
        qty: json['qty'] ?? 1,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        motivo: json['reason'] ?? '',
        fecha: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );
}
