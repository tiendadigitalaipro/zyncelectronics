import 'cart_item.dart';

enum GrupoPago { efectivo, digital, credito }
enum EstadoPago { pagado, pendiente }

class Venta {
  final String id;
  final int ticketNum;
  final String cliente;
  final String? clienteId;
  final List<CartItem> items;
  final double subtotal;
  final double iva;
  final double total;
  final String metodo;
  final GrupoPago grupoPago;
  final double recibido;
  final EstadoPago estadoPago;
  final DateTime fecha;

  const Venta({
    required this.id,
    required this.ticketNum,
    required this.cliente,
    this.clienteId,
    required this.items,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.metodo,
    required this.grupoPago,
    required this.recibido,
    required this.estadoPago,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketNum': ticketNum,
        'client': cliente,
        'clientId': clienteId,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'iva': iva,
        'total': total,
        'method': metodo,
        'paymentGroup': grupoPago.name,
        'received': recibido,
        'paymentStatus': estadoPago == EstadoPago.pagado ? 'paid' : 'pending',
        'date': fecha.toIso8601String(),
      };

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
        id: json['id'].toString(),
        ticketNum: json['ticketNum'] ?? 0,
        cliente: json['client'] ?? 'CLIENTE GENÉRICO',
        clienteId: json['clientId'] as String?,
        items: ((json['items'] as List?) ?? [])
            .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        iva: (json['iva'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        metodo: json['method'] ?? '',
        grupoPago: _grupoFromJson(json['paymentGroup']),
        recibido: (json['received'] as num?)?.toDouble() ?? 0,
        estadoPago: json['paymentStatus'] == 'pending' ? EstadoPago.pendiente : EstadoPago.pagado,
        fecha: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );

  static GrupoPago _grupoFromJson(String? v) {
    switch (v) {
      case 'digital':
        return GrupoPago.digital;
      case 'credit':
        return GrupoPago.credito;
      default:
        return GrupoPago.efectivo;
    }
  }
}
