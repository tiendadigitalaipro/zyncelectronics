class Fiado {
  final String id;
  final String? saleId;
  final int? ticketNum;
  final String nombre;
  final String? ci;
  final double monto;
  final String desc;
  final double abonado;
  final DateTime fecha;

  const Fiado({
    required this.id,
    this.saleId,
    this.ticketNum,
    required this.nombre,
    this.ci,
    required this.monto,
    required this.desc,
    this.abonado = 0,
    required this.fecha,
  });

  double get saldo => monto - abonado;
  bool get saldado => saldo <= 0;

  Fiado copyWith({double? abonado}) => Fiado(
        id: id,
        saleId: saleId,
        ticketNum: ticketNum,
        nombre: nombre,
        ci: ci,
        monto: monto,
        desc: desc,
        abonado: abonado ?? this.abonado,
        fecha: fecha,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'saleId': saleId,
        'ticketNum': ticketNum,
        'nombre': nombre,
        'ci': ci,
        'monto': monto,
        'desc': desc,
        'abonado': abonado,
        'fecha': fecha.millisecondsSinceEpoch,
      };

  factory Fiado.fromJson(Map<String, dynamic> json) => Fiado(
        id: json['id'].toString(),
        saleId: json['saleId'] as String?,
        ticketNum: json['ticketNum'] as int?,
        nombre: json['nombre'] ?? '',
        ci: json['ci'] as String?,
        monto: (json['monto'] as num?)?.toDouble() ?? 0,
        desc: json['desc'] ?? '',
        abonado: (json['abonado'] as num?)?.toDouble() ?? 0,
        fecha: json['fecha'] is int
            ? DateTime.fromMillisecondsSinceEpoch(json['fecha'])
            : DateTime.now(),
      );
}
