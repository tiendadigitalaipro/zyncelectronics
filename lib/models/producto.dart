class Producto {
  final String id;
  final String sku;
  final String cat;
  final String desc;
  final double? bulkCost;
  final int? bulkUnits;
  final double cost;
  final double price;
  final int iva;
  final int stock;
  final int min;
  final bool fraccionable;
  final String? photo;

  const Producto({
    required this.id,
    required this.sku,
    required this.cat,
    required this.desc,
    this.bulkCost,
    this.bulkUnits,
    required this.cost,
    required this.price,
    this.iva = 0,
    this.stock = 0,
    this.min = 0,
    this.fraccionable = false,
    this.photo,
  });

  bool get stockBajo => stock <= min;

  Producto copyWith({
    String? sku,
    String? cat,
    String? desc,
    double? bulkCost,
    int? bulkUnits,
    double? cost,
    double? price,
    int? iva,
    int? stock,
    int? min,
    bool? fraccionable,
    String? photo,
  }) {
    return Producto(
      id: id,
      sku: sku ?? this.sku,
      cat: cat ?? this.cat,
      desc: desc ?? this.desc,
      bulkCost: bulkCost ?? this.bulkCost,
      bulkUnits: bulkUnits ?? this.bulkUnits,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      iva: iva ?? this.iva,
      stock: stock ?? this.stock,
      min: min ?? this.min,
      fraccionable: fraccionable ?? this.fraccionable,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'cat': cat,
        'desc': desc,
        'bulkCost': bulkCost,
        'bulkUnits': bulkUnits,
        'cost': cost,
        'price': price,
        'iva': iva,
        'stock': stock,
        'min': min,
        'fraccionable': fraccionable,
        'photo': photo,
      };

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'].toString(),
        sku: json['sku'] ?? 'S/C',
        cat: json['cat'] ?? '',
        desc: json['desc'] ?? '',
        bulkCost: (json['bulkCost'] as num?)?.toDouble(),
        bulkUnits: json['bulkUnits'] as int?,
        cost: (json['cost'] as num?)?.toDouble() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        iva: json['iva'] ?? 0,
        stock: json['stock'] ?? 0,
        min: json['min'] ?? 0,
        fraccionable: json['fraccionable'] ?? false,
        photo: json['photo'] as String?,
      );
}
