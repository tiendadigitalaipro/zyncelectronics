class CartItem {
  final String id;
  final String sku;
  final String desc;
  final double price;
  final int iva;
  final int qty;

  /// Solo para items de Pesaje: producto real del inventario del que se
  /// descuenta stock, y cantidad exacta en gramos/ml a descontar (el stock
  /// de un producto fraccionable se guarda en gramos, no en unidades).
  final String? sourceProductId;
  final int? stockQty;

  const CartItem({
    required this.id,
    required this.sku,
    required this.desc,
    required this.price,
    this.iva = 0,
    this.qty = 1,
    this.sourceProductId,
    this.stockQty,
  });

  double get subtotal => price * qty;
  double get ivaMonto => subtotal * (iva / 100);
  double get total => subtotal + ivaMonto;

  CartItem copyWith({int? qty}) => CartItem(
        id: id,
        sku: sku,
        desc: desc,
        price: price,
        iva: iva,
        qty: qty ?? this.qty,
        sourceProductId: sourceProductId,
        stockQty: stockQty,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'desc': desc,
        'price': price,
        'iva': iva,
        'qty': qty,
        'sourceProductId': sourceProductId,
        'stockQty': stockQty,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'].toString(),
        sku: json['sku'] ?? 'S/C',
        desc: json['desc'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        iva: json['iva'] ?? 0,
        qty: json['qty'] ?? 1,
        sourceProductId: json['sourceProductId'] as String?,
        stockQty: json['stockQty'] as int?,
      );
}
