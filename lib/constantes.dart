// Constantes compartidas de la aplicación.

class Constantes {
  /// Constructor privado para evitar instancias.
  Constantes._();

  // ══════════════════════════════════════════════════
  //  DÍAS DE LA SEMANA
  // ══════════════════════════════════════════════════

  /// Lista ordenada de los días de la semana (en minúsculas).
  static const diasSemana = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  /// Nombres legibles de los días de la semana.
  /// La clave es el día en minúsculas sin tildes.
  static const nombresDias = {
    'lunes': 'Lunes',
    'martes': 'Martes',
    'miercoles': 'Miércoles',
    'jueves': 'Jueves',
    'viernes': 'Viernes',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
  };
}