#!/usr/bin/env python3
"""
📂 EXTRACTOR DE ESTRUCTURA DE DIRECTORIOS
Genera un árbol visual de carpetas y archivos con estadísticas.

Ejecución:
    python estructura_proyecto.py
"""

import os
from pathlib import Path
from fnmatch import fnmatch
from datetime import datetime

# ============================================
# ⚙️ CONFIGURACIÓN (EDITA AQUÍ)
# ============================================

# Directorio a analizar
SEARCH_DIR = "lib/"

# Nivel de profundidad (0 = solo raíz, -1 = sin límite)
MAX_DEPTH = -1

# Archivo de salida
OUTPUT_FILE = "estructura1.txt"

# ── Exclusiones ──
EXCLUDE_PATTERNS = [
    # Carpetas comunes
    "node_modules",
    "__pycache__",
    ".git",
    ".vscode",
    ".idea",
    "venv",
    ".venv",
    "env",
    "dist",
    "build",
    ".next",
    ".nuxt",
    "coverage",
    ".pytest_cache",
    ".mypy_cache",

    # Archivos comunes
    "*.pyc",
    "*.pyo",
    "*.egg-info",
    "*.log",
    ".DS_Store",
    "Thumbs.db",
    "*.freezed.dart",
    "*.g.dart",
]

# Extensiones a incluir (vacío = todas)
INCLUDE_EXTENSIONS = []
# Ejemplo: [".py", ".js", ".jsx", ".ts", ".tsx", ".dart", ".html", ".css"]

# Extensiones a excluir
EXCLUDE_EXTENSIONS = [
    ".pyc",
    ".pyo",
    ".class",
    ".o",
    ".so",
    ".dll",
    ".exe",
]

# ── Opciones de visualización ──

# Mostrar tamaño de archivos
SHOW_FILE_SIZE = False

# Mostrar cantidad de líneas en archivos de texto
SHOW_LINE_COUNT = True

# Mostrar estadísticas por carpeta
SHOW_FOLDER_STATS = True

# Mostrar archivos ocultos (empiezan con .)
SHOW_HIDDEN_FILES = False

# Colores en terminal (True/False)
USE_COLORS = True

# Estilo del árbol
TREE_STYLE = "unicode"  # "unicode", "ascii", "simple"

# Caracteres del árbol según estilo
TREE_CHARS = {
    "unicode": {
        "branch": "├── ",
        "last": "└── ",
        "pipe": "│   ",
        "space": "    ",
    },
    "ascii": {
        "branch": "|-- ",
        "last": "`-- ",
        "pipe": "|   ",
        "space": "    ",
    },
    "simple": {
        "branch": "|-- ",
        "last": "\\-- ",
        "pipe": "|   ",
        "space": "    ",
    },
}

# ============================================
# 🔧 FUNCIONES
# ============================================


def should_exclude(path, exclude_patterns):
    """Verifica si un archivo/carpeta debe ser excluido."""
    name = os.path.basename(str(path))

    for pattern in exclude_patterns:
        if fnmatch(name, pattern):
            return True
        # Verificar contra partes de la ruta
        for part in Path(path).parts:
            if fnmatch(part, pattern):
                return True
    return False


def should_include_by_extension(file_path, include_extensions, exclude_extensions):
    """Verifica si un archivo pasa el filtro de extensiones."""
    ext = Path(file_path).suffix.lower()

    # Si hay lista de inclusiones, solo incluir esas
    if include_extensions:
        return ext in include_extensions

    # Si hay lista de exclusiones, excluir esas
    if exclude_extensions:
        return ext not in exclude_extensions

    # Sin filtros, incluir todo
    return True


def is_text_file(file_path):
    """Determina si un archivo es de texto (para contar líneas)."""
    text_extensions = {
        ".py", ".js", ".ts", ".jsx", ".tsx", ".dart",
        ".html", ".css", ".scss", ".sass", ".less",
        ".json", ".yaml", ".yml", ".toml", ".xml",
        ".md", ".txt", ".csv", ".sql", ".sh", ".bash",
        ".java", ".c", ".cpp", ".h", ".hpp", ".cs",
        ".rb", ".go", ".rs", ".php", ".swift", ".kt",
        ".env", ".cfg", ".ini", ".conf", ".config",
        ".gitignore", ".dockerignore", ".editorconfig",
        ".vue", ".svelte",
    }
    ext = Path(file_path).suffix.lower()
    return ext in text_extensions


def format_size(size_bytes):
    """Formatea el tamaño de archivo a formato legible."""
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 ** 2:
        return f"{size_bytes / 1024:.1f} KB"
    elif size_bytes < 1024 ** 3:
        return f"{size_bytes / (1024 ** 2):.1f} MB"
    else:
        return f"{size_bytes / (1024 ** 3):.1f} GB"


def count_lines_safe(file_path):
    """Cuenta líneas de un archivo de forma segura."""
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            return sum(1 for _ in f)
    except:
        return None


def get_folder_stats(folder_path):
    """Obtiene estadísticas de una carpeta."""
    file_count = 0
    folder_count = 0
    total_size = 0

    try:
        for item in os.listdir(folder_path):
            full_path = os.path.join(folder_path, item)
            if os.path.isfile(full_path):
                file_count += 1
                try:
                    total_size += os.path.getsize(full_path)
                except:
                    pass
            elif os.path.isdir(full_path):
                folder_count += 1
    except:
        pass

    return {
        "files": file_count,
        "folders": folder_count,
        "size": total_size,
    }


def get_file_icon(file_name):
    return ""


def get_folder_icon():
    """Devuelve el ícono para carpetas."""
    return ""


# ============================================
# 🌳 GENERADOR DEL ÁRBOL
# ============================================


class TreeBuilder:
    """Construye el árbol de directorios."""

    def __init__(self, config):
        self.config = config
        self.chars = TREE_CHARS[config["tree_style"]]
        self.stats = {
            "total_files": 0,
            "total_folders": 0,
            "total_size": 0,
            "total_lines": 0,
            "by_extension": {},
            "deepest_level": 0,
            "largest_file": ("", 0),
        }

    def _update_stats(self, file_path, size):
        """Actualiza las estadísticas globales."""
        self.stats["total_files"] += 1
        self.stats["total_size"] += size

        ext = Path(file_path).suffix.lower() or "(sin ext)"
        if ext not in self.stats["by_extension"]:
            self.stats["by_extension"][ext] = {"count": 0, "size": 0}
        self.stats["by_extension"][ext]["count"] += 1
        self.stats["by_extension"][ext]["size"] += size

        # Archivo más grande
        if size > self.stats["largest_file"][1]:
            self.stats["largest_file"] = (str(file_path), size)

        # Contar líneas si es archivo de texto
        if self.config["show_line_count"] and is_text_file(file_path):
            lines = count_lines_safe(file_path)
            if lines is not None:
                self.stats["total_lines"] += lines
                self.stats["by_extension"][ext]["lines"] = \
                    self.stats["by_extension"][ext].get("lines", 0) + lines

    def build(self, directory, prefix="", depth=0, is_last_group=False):
        """Construye el árbol recursivamente."""
        output = []
        directory = Path(directory)

        if not directory.exists():
            return [f"❌ Directorio no encontrado: {directory}"]

        # Verificar límite de profundidad
        max_depth = self.config["max_depth"]
        if max_depth >= 0 and depth > max_depth:
            return []

        # Actualizar nivel más profundo
        if depth > self.stats["deepest_level"]:
            self.stats["deepest_level"] = depth

        try:
            entries = sorted(os.listdir(directory))
        except PermissionError:
            return [f"{prefix}⚠️  [Sin permisos de lectura]"]
        except Exception as e:
            return [f"{prefix}⚠️  [Error: {e}]"]

        # ── Separar y filtrar carpetas y archivos ──
        folders = []
        files = []

        for entry in entries:
            full_path = directory / entry

            # Excluir archivos/carpetas ocultos
            if not self.config["show_hidden_files"] and entry.startswith("."):
                continue

            # Excluir por patrones
            if should_exclude(full_path, self.config["exclude_patterns"]):
                continue

            if full_path.is_dir():
                folders.append(full_path)
            elif full_path.is_file():
                # Filtrar por extensión
                if should_include_by_extension(
                    full_path,
                    self.config["include_extensions"],
                    self.config["exclude_extensions"]
                ):
                    files.append(full_path)

        # ── Combinar: carpetas primero, luego archivos ──
        all_entries = folders + files
        total = len(all_entries)

        for i, entry in enumerate(all_entries):
            is_last = (i == total - 1)
            connector = self.chars["last"] if is_last else self.chars["branch"]
            next_prefix = prefix + self.chars["space"] if is_last else prefix + self.chars["pipe"]

            if entry.is_dir():
                # ── Es una CARPETA ──
                self.stats["total_folders"] += 1

                # Info de la carpeta
                folder_name = entry.name
                icon = get_folder_icon()

                # Estadísticas de la carpeta
                folder_info = ""
                if self.config["show_folder_stats"]:
                    fs = get_folder_stats(str(entry))
                    parts = []
                    if fs["files"] > 0:
                        parts.append(f"{fs['files']} archivos")
                    if fs["folders"] > 0:
                        parts.append(f"{fs['folders']} carpetas")
                    if parts:
                        folder_info = f"  ({', '.join(parts)})"

                output.append(f"{prefix}{connector}{icon} {folder_name}/{folder_info}")

                # Recursión
                sub_output = self.build(
                    entry,
                    next_prefix,
                    depth + 1,
                    is_last
                )
                output.extend(sub_output)

            else:
                # ── Es un ARCHIVO ──
                file_name = entry.name
                icon = get_file_icon(file_name)

                try:
                    size = os.path.getsize(str(entry))
                except:
                    size = 0

                self._update_stats(entry, size)

                # Info adicional del archivo
                info_parts = []

                if self.config["show_file_size"]:
                    info_parts.append(format_size(size))

                if self.config["show_line_count"] and is_text_file(entry):
                    lines = count_lines_safe(str(entry))
                    if lines is not None:
                        info_parts.append(f"{lines} líneas")

                info_str = f"  [{', '.join(info_parts)}]" if info_parts else ""

                output.append(f"{prefix}{connector}{icon} {file_name}{info_str}")

        return output

    def get_stats_output(self):
        """Genera el reporte de estadísticas."""
        output = []
        s = self.stats

        output.append("")
        output.append("=" * 60)
        output.append("📊 ESTADÍSTICAS DEL PROYECTO")
        output.append("=" * 60)
        output.append("")

        # Resumen general
        output.append("📋 Resumen:")
        output.append(f"   📁 Carpetas        : {s['total_folders']}")
        output.append(f"   📄 Archivos        : {s['total_files']}")
        output.append(f"   📏 Líneas totales  : {s['total_lines']:,}")
        output.append(f"   📐 Nivel más profundo: {s['deepest_level']}")
        output.append("")

        output.append("")
        return output


# ============================================
# 🚀 EJECUCIÓN PRINCIPAL
# ============================================


def main():
    """Punto de entrada del script."""
    start_time = datetime.now()

    # ── Configuración ──
    config = {
        "search_dir": SEARCH_DIR,
        "max_depth": MAX_DEPTH,
        "output_file": OUTPUT_FILE,
        "exclude_patterns": EXCLUDE_PATTERNS,
        "include_extensions": INCLUDE_EXTENSIONS,
        "exclude_extensions": EXCLUDE_EXTENSIONS,
        "show_file_size": SHOW_FILE_SIZE,
        "show_line_count": SHOW_LINE_COUNT,
        "show_folder_stats": SHOW_FOLDER_STATS,
        "show_hidden_files": SHOW_HIDDEN_FILES,
        "tree_style": TREE_STYLE,
    }

    search_path = Path(SEARCH_DIR).resolve()

    print("📂 Extractor de estructura de directorios")
    print("─" * 45)
    print(f"📁 Directorio: {search_path}")

    if not search_path.exists():
        print(f"❌ El directorio '{SEARCH_DIR}' no existe.")
        print(f"   Directorio actual: {Path.cwd().absolute()}")
        return

    # ── Construir árbol ──
    print(f"🔍 Analizando estructura...")

    builder = TreeBuilder(config)

    # Encabezado del archivo
    header = []
    header.append("📂 ESTRUCTURA DEL PROYECTO")
    header.append("=" * 60)
    header.append(f"🕐 Generado   : {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    header.append(f"📁 Directorio : {search_path}")
    header.append(f"📐 Profundidad: {'Sin límite' if MAX_DEPTH < 0 else MAX_DEPTH}")
    header.append(f"🚫 Excluidos  : {len(EXCLUDE_PATTERNS)} patrones")
    header.append("=" * 60)
    header.append("")

    # Nombre de la raíz
    root_name = search_path.name
    header.append(f"{root_name}/")

    # Generar árbol
    tree_lines = builder.build(search_path)
    stats_lines = builder.get_stats_output()

    # Pie de página
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()

    footer = [
        "",
        "=" * 60,
        f"⏱️  Tiempo de ejecución: {duration:.2f} segundos",
        "=" * 60,
    ]

    # ── Unir todo ──
    full_output = (
        "\n".join(header)
        + "\n".join(tree_lines)
        + "\n".join(stats_lines)
        + "\n".join(footer)
    )

    # ── Guardar archivo ──
    try:
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            f.write(full_output)

        print(f"\n✅ ¡Estructura generada!")
        print(f"📄 Archivo: {OUTPUT_FILE}")
        print(f"📁 {builder.stats['total_folders']} carpetas, "
              f"{builder.stats['total_files']} archivos")
        print(f"⏱️  Tiempo: {duration:.2f} segundos")

    except Exception as e:
        print(f"❌ Error al escribir: {e}")


if __name__ == "__main__":
    main()