class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String rol;
  final String habilidadesAprender;
  final String habilidadesEnsenar;
  final String objetivos;
  final String experiencia;
  final int nivel;
  final int nivelEnsenar;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.habilidadesAprender = '',
    this.habilidadesEnsenar = '',
    this.objetivos = '',
    this.experiencia = '',
    this.nivel = 1,
    this.nivelEnsenar = 1,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      rol: json['rol'] as String,
      habilidadesAprender: (json['habilidades_aprender'] as String?) ?? '',
      habilidadesEnsenar: (json['habilidades_ensenar'] as String?) ?? '',
      objetivos: (json['objetivos'] as String?) ?? '',
      experiencia: (json['experiencia'] as String?) ?? '',
      nivel: (json['nivel'] as int?) ?? 1,
      nivelEnsenar: (json['nivel_ensenar'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'correo': correo,
        'rol': rol,
        'habilidades_aprender': habilidadesAprender,
        'habilidades_ensenar': habilidadesEnsenar,
        'objetivos': objetivos,
        'experiencia': experiencia,
        'nivel': nivel,
        'nivel_ensenar': nivelEnsenar,
      };
}
