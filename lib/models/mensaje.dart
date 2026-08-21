class Mensaje {
  final int? id;
  final int emisorId;
  final int receptorId;
  final String contenido;
  final String fecha;

  Mensaje({
    this.id,            // ← opcional
    required this.emisorId,
    required this.receptorId,
    required this.contenido,
    required this.fecha,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] as int,
      emisorId: json['emisor_id'] as int,
      receptorId: json['receptor_id'] as int,
      contenido: json['contenido'] as String,
      fecha: (json['fecha'] as String?) ?? '',
    );
  }
}
