Vas a ayudarme a desarrollar el MVP (Producto Mínimo Viable) de una plataforma web de mentoría virtual para que corra de forma local en mi computadora.
Contexto del Proyecto:
El sistema conecta estudiantes con mentores (profesionales) según sus habilidades y objetivos.
Stack Tecnológico (Local):
Base de Datos: SQLite (archivos locales, sin servidores externos).
Reglas de desarrollo:
El enfoque es que funcione localmente, sin configuraciones en la nube por ahora.
Funcionalidades principales del MVP:
Registro y Login:
Dos roles: Estudiante y Mentor.
Registro básico (Nombre, correo, contraseña, rol).
Login que verifique credenciales contra la base de datos local y redirija según el rol.
Perfiles y Niveles:
Estudiante: Define objetivos, habilidades que quiere aprender y tiene un campo numérico llamado "Nivel" (empieza en 1).
Mentor: Define habilidades que enseña, experiencia y un campo "Nivel que enseña" (ej. puede enseñar a nivel 1 y 2).
Emparejamiento (Match simple):
El estudiante busca mentores. El sistema filtra en la base de datos donde la "habilidad del estudiante" = "habilidad del mentor" Y el "Nivel del estudiante" = "Nivel que enseña el mentor".
Sistema de Evaluación y Avance de Nivel (Lógica clave):
Después de una sesión de mentoría, el Mentor debe poder evaluar al estudiante (Aprobado / Reprobado).
Si es Aprobado: El sistema automáticamente suma +1 al campo "Nivel" del estudiante en la base de datos.
Si es Reprobado: El nivel del estudiante no cambia y debe seguir practicando.
Mensajería Básica:
Un chat simple que guarde mensajes de texto en la base de datos SQLite entre el estudiante y su mentor.