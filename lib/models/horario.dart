class Horario {
  final int id;
  final int mentorId;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.id,
    required this.mentorId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'] as int,
      mentorId: json['mentor_id'] as int,
      diaSemana: json['dia_semana'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mentor_id': mentorId,
        'dia_semana': diaSemana,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
      };
}