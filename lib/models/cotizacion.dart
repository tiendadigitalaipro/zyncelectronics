import 'cart_item.dart';

enum EstadoCotizacion { pendiente, convertida }

class Cotizacion {
  final String id;
  final String numero;
  final String cliente;
  final List<CartItem> items;
  final double total;
  final EstadoCotizacion status;
  final DateTime creadaEn;

  const Cotizacion({
    required this.id,
    required this.numero,
    required this.cliente,
    required this.items,
    required this.total,
    this.status = EstadoCotizacion.pendiente,
    required this.creadaEn,
  });

  Cotizacion copyWith({EstadoCotizacion? status}) => Cotizacion(
        id: id,
        numero: numero,
        cliente: cliente,
        items: items,
        total: total,
        status: status ?? this.status,
        creadaEn: creadaEn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'num': numero,
        'client': cliente,
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'status': status == EstadoCotizacion.convertida ? 'converted' : 'pending',
        'createdAt': creadaEn.toIso8601String(),
      };

  factory Cotizacion.fromJson(Map<String, dynamic> json) => Cotizacion(
        id: json['id'].toString(),
        numero: json['num'] ?? '00000',
        cliente: json['client'] ?? 'CLIENTE GENÉRICO',
        items: ((json['items'] as List?) ?? []).map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList(),
        total: (json['total'] as num?)?.toDouble() ?? 0,
        status: json['status'] == 'converted' ? EstadoCotizacion.convertida : EstadoCotizacion.pendiente,
        creadaEn: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}
