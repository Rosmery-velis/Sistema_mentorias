#!/usr/bin/env python3
"""
🔍 BÚSQUEDA INTELIGENTE - Herramienta de búsqueda con contexto
Genera automáticamente un archivo con los resultados.

Ejecucion:
python buscador_global.py
"""

import re
import os
from pathlib import Path
from fnmatch import fnmatch
from datetime import datetime
from functools import lru_cache

# ============================================
# ⚙️ CONFIGURACIÓN (EDITA AQUÍ)
# ============================================

# Palabras clave a buscar (soporta regex)
KEYWORDS = [
    "router",
    "mount",
    "token",
    "userId",
    "authorization",
    "baseUrl",
    "http.get",
    "http.post",
    "http.put",
    "http.delete",
    "fromJson",
    "toJson",
    "initState",
    "Navigator.push",
    "mentor"
]
# Cuántas líneas mostrar antes y después de cada coincidencia
CONTEXT_LINES = 10

# Si hay más de X líneas entre coincidencias, mostrar "..."
GROUP_THRESHOLD = 15

# Directorio donde buscar
SEARCH_DIR = "lib/"

# Archivo de salida
# OUTPUT_FILE = "arhivo.txt"
OUTPUT_FILE = "contexto.txt"
# Extensiones de archivo a incluir
FILE_EXTENSIONS = ["*.dart", "*.py", "*.js", "*.ts", "*.java", "*.c", "*.cpp", "*.jsx", "*.html", "*.css"]

# Patrones a excluir (archivos/carpetas)
EXCLUDE_PATTERNS = ["*env*", "*.freezed.dart", "*tests*", "node_modules/", "__pycache__", "*.pyc", "pycache/", "__init__.py"]

# Búsqueda case-sensitive (True/False)
CASE_SENSITIVE = False # Esto es para 

# Si es True: Agrupa todos los resultados en un solo bloque limpio (Recomendado)
# Si es False: Muestra resultados separados por cada keyword (Modo antiguo)
MODO_AGRUPADO = True  

# ============================================
# 🎯 PRESETS POR LENGUAJE (OPCIONAL)
# ============================================
# Si quieres usar un preset, descomenta y configura:

# PRESET_ACTIVO = "dart"  # o "python", "js"

LANGUAGE_PRESETS = {
    "dart": {
        "extensions": ["*.dart"],
        "exclude": ["*.g.dart", "*.freezed.dart"],
        "dir": "lib/",
    },
    "python": {
        "extensions": ["*.py"],
        "exclude": ["__pycache__", "*.pyc", ".venv"],
        "dir": "src/",
    },
    "js": {
        "extensions": ["*.js", "*.ts"],
        "exclude": ["node_modules", "*.min.js"],
        "dir": "src/",
    },
}

# ============================================
# FIN DE CONFIGURACIÓN
# ============================================

# 🚀 FUNCIÓN CON CACHE: Lee archivo 1 vez, reusa el contenido
@lru_cache(maxsize=80)  # Guarda en memoria los últimos 80 archivos leídos
def leer_archivo_con_cache(ruta_archivo, version=None):
    """Lee un archivo y guarda el contenido en caché para reutilizar"""
    print(f"   🔄 Leyendo desde disco: {ruta_archivo}")  # ← Solo se imprime la 1ra vez
    try:
        return Path(ruta_archivo).read_text(encoding="utf-8", errors="ignore")
    except:
        return ""  # Si falla, retorna vacío para no romper el script


def should_exclude(file_path, exclude_patterns):
    """
    Verifica si un archivo/carpeta debe ser excluido.
    Soporta wildcards: *venv*, *.pyc, node_modules, etc.
    Funciona en CUALQUIER nivel de profundidad.
    """
    file_str = str(file_path)
    file_name = os.path.basename(file_str)

    for pattern in exclude_patterns:
        # 1. Coincidencia contra la ruta completa
        if fnmatch(file_str, f"*{pattern}*"):
            return True
        # 2. Coincidencia contra el nombre del archivo
        if fnmatch(file_name, pattern):
            return True
        # 3. Coincidencia contra CUALQUIER parte de la ruta
        #    (esto hace que funcione en cualquier nivel)
        for part in Path(file_path).parts:
            if fnmatch(part, pattern):
                return True

    return False


def find_all_matches_in_file(file_path, keywords, context_lines, group_threshold, case_sensitive):
    """
    Busca TODAS las keywords en un archivo y devuelve bloques agrupados
    con etiquetas de qué keywords matchearon cada línea.
    """
    try:
        lines = leer_archivo_con_cache(str(file_path)).splitlines()
    except:
        return [], set()  # ← Retornar set vacío también
    
    flags = 0 if case_sensitive else re.IGNORECASE
    
    # Mapa: número_de_línea → lista de keywords que matchean
    line_matches = {}
    keywords_found = set()  # Guardar keywords encontradas en este archivo
    
    for keyword in keywords:
        if keyword.startswith("regex:"):
            pattern = keyword[6:]  # Quitar "regex:" del inicio
        else:
            pattern = re.escape(keyword)  # Para búsqueda literal segura
        for i, line in enumerate(lines, 1):
            if re.search(pattern, line, flags):
                if i not in line_matches:
                    line_matches[i] = []
                    line_matches[i].append(keyword)
                    keywords_found.add(keyword)
    
    if not line_matches:
        return [], set()
    
    # Agrupar líneas con matches cercanos en bloques
    sorted_lines = sorted(line_matches.keys())
    blocks = []
    
    current_block = {
        "start": max(0, sorted_lines[0] - context_lines - 1),
        "end": min(len(lines), sorted_lines[0] + context_lines),
        "match_lines": {sorted_lines[0]: line_matches[sorted_lines[0]]}
    }
    
    for line_num in sorted_lines[1:]:
        new_start = max(0, line_num - context_lines - 1)
        new_end = min(len(lines), line_num + context_lines)
        
        # Si está cerca del bloque actual, extenderlo
        if new_start <= current_block["end"] + group_threshold:
            current_block["start"] = min(current_block["start"], new_start)
            current_block["end"] = max(current_block["end"], new_end)
            current_block["match_lines"][line_num] = line_matches[line_num]
        else:
            blocks.append(current_block)
            current_block = {
                "start": new_start,
                "end": new_end,
                "match_lines": {line_num: line_matches[line_num]}
            }
    
    blocks.append(current_block)
    
    # Formatear resultado con etiquetas de keywords
    results = []
    for i, block in enumerate(blocks):
        formatted_lines = []
        for j in range(block["start"], block["end"]):
            line_num = j + 1
            content = lines[j]
            
            if line_num in block["match_lines"]:
                # Esta línea tiene matches: agregar etiquetas
                matched_keywords = block["match_lines"][line_num]
                formatted_lines.append({
                    "line_num": line_num,
                    "content": content,
                    "is_match": True,
                    "keywords": matched_keywords  # ← Lista de keywords que matchearon
                })
            else:
                formatted_lines.append({
                    "line_num": line_num,
                    "content": content,
                    "is_match": False,
                    "keywords": []
                })
        
        results.append({
            "file": str(file_path),
            "lines": formatted_lines,
            "has_gap": i > 0
        })
    
    return results, keywords_found


def apply_language_preset(preset_name):
    """Aplica configuración desde un preset de lenguaje"""
    if preset_name not in LANGUAGE_PRESETS:
        print(f"⚠️  Preset '{preset_name}' no encontrado")
        return
    
    preset = LANGUAGE_PRESETS[preset_name]
    return {
        "extensions": preset.get("extensions", FILE_EXTENSIONS),
        "exclude": preset.get("exclude", EXCLUDE_PATTERNS),
        "dir": preset.get("dir", SEARCH_DIR),
    }


def find_files_with_pattern(keyword, config):
    """Encuentra archivos únicos que contienen el patrón"""
    files = set()
    search_path = Path(config.get("dir", SEARCH_DIR))
    
    if not search_path.exists():
        print(f"⚠️  Directorio '{search_path}' no existe")
        print(f"   Directorio actual: {Path.cwd().absolute()}")
        return []
    
    print(f"✅ Buscando en: {search_path.absolute()}")
    flags = 0 if CASE_SENSITIVE else re.IGNORECASE
    
    for ext in config.get("extensions", FILE_EXTENSIONS):
        for file_path in search_path.rglob(ext):
            # Filtro de exclusión con soporte de wildcards
            if should_exclude(file_path, config.get("exclude", EXCLUDE_PATTERNS)):
                continue
            
            try:
                mtime = os.path.getmtime(str(file_path))  # ← Obtiene timestamp del archivo
                # ✅ USA LA FUNCIÓN CON CACHE: convierte Path a string primero
                content = leer_archivo_con_cache(str(file_path), version=mtime)
                # ✅ ESCAPE AUTOMÁTICO: Trata la keyword como texto literal
                if re.search(re.escape(keyword), content, flags):
                    files.add(file_path)
            except (PermissionError, UnicodeDecodeError):
                continue
    
    print(f"   📁 Extensiones buscadas: {config.get('extensions', FILE_EXTENSIONS)}")
    print(f"   📊 Archivos encontrados: {len(files)}")

    return sorted(files)


def extract_context_blocks(file_path, keyword, context_lines, group_threshold):
    """Extrae bloques de contexto agrupando coincidencias cercanas"""
    try:
        lines = file_path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except:
        return []
    
    # Encontrar todas las líneas que matchean
    matches = []
    flags = 0 if CASE_SENSITIVE else re.IGNORECASE
    for i, line in enumerate(lines, 1):
        if re.search(re.escape(keyword), line, flags):
            matches.append(i)
    
    if not matches:
        return []
    
    # Agrupar coincidencias cercanas
    blocks = []
    current_block = {
        "start": max(0, matches[0] - context_lines - 1),
        "end": min(len(lines), matches[0] + context_lines),
        "match_lines": [matches[0]]
    }
    
    for match_line in matches[1:]:
        new_start = max(0, match_line - context_lines - 1)
        new_end = min(len(lines), match_line + context_lines)
        
        # Si está cerca del bloque actual, extenderlo
        if new_start <= current_block["end"] + group_threshold:
            current_block["start"] = min(current_block["start"], new_start)
            current_block["end"] = max(current_block["end"], new_end)
            current_block["match_lines"].append(match_line)
        else:
            # Guardar bloque actual y empezar uno nuevo
            blocks.append(current_block)
            current_block = {
                "start": new_start,
                "end": new_end,
                "match_lines": [match_line]
            }
    
    blocks.append(current_block)
    
    # Formatear resultado
    results = []
    for i, block in enumerate(blocks):
        formatted_lines = []
        for j in range(block["start"], block["end"]):
            line_num = j + 1
            content = lines[j]
            is_match = line_num in block["match_lines"]
            formatted_lines.append({
                "line_num": line_num,
                "content": content,
                "is_match": is_match
            })
        results.append({
            "file": str(file_path),
            "lines": formatted_lines,
            "has_gap": i > 0  # Para mostrar "..." entre bloques
        })
    
    return results


def format_output(results, keyword, files_processed, keywords_found=None):
    """Formatea los resultados en estilo visual"""
    output = []

    # Encabezado general (solo para modo no agrupado)
    if keyword != "MÚLTIPLE":
        output.append(f"🔎 Buscando: '{keyword}'")
        output.append("─" * 70)
        output.append("")

    if not results:
        output.append("   ⚠️  No se encontraron coincidencias")
        output.append("")
        return "\n".join(output), files_processed
    
    current_file = None
    
    for result in results:
        # ============================================
        # 📄 CUANDO CAMBIA EL ARCHIVO → Mostrar encabezado específico
        # ============================================
        if result["file"] != current_file:
            if current_file is not None:
                output.append("")
            
            # 🔍 ENCABEZADO POR ARCHIVO (solo en modo agrupado)
            if keyword == "MÚLTIPLE":
                # Recopilar TODAS las keywords encontradas en ESTE archivo
                file_keywords = set()
                for block in results:
                    if block["file"] == result["file"]:
                        for line in block["lines"]:
                            if line["is_match"] and line.get("keywords"):
                                file_keywords.update(line["keywords"])
                
                # Mostrar encabezado con nombre de archivo y sus keywords
                keywords_list = ", ".join(sorted(file_keywords))
                output.append(f"🔎 Buscando en '{result['file']}': [{keywords_list}]")
            else:
                # Modo normal: solo nombre del archivo
                output.append(f"📄 {result['file']}")
            
            output.append("   " + "─" * 50)
            current_file = result["file"]
            files_processed.add(result["file"])
        
        # Mostrar separador si hay gap entre bloques
        if result.get("has_gap"):
            output.append("   ...")
        
        # Mostrar líneas con formato
        for line_info in result["lines"]:
            if line_info["is_match"]:
                # Para líneas con coincidencias: mostramos solo número y contenido, sin corchetes
                output.append(f"   L{line_info['line_num']}- {line_info['content']}")
            else:
                # Para líneas de contexto (sin match) mantenemos el formato original (opcional)
                output.append(f"   {line_info['line_num']}-  {line_info['content']}")
        
        output.append("")
    
    return "\n".join(output), files_processed


def main():
    """Punto de entrada - Ejecución automática sin prompts"""
    start_time = datetime.now()
    
    # Verificar si hay preset activo
    config = {
        "extensions": FILE_EXTENSIONS,
        "exclude": EXCLUDE_PATTERNS,
        "dir": SEARCH_DIR,
    }
    
    # Si hay preset activo, aplicar configuración
    if 'PRESET_ACTIVO' in globals() and PRESET_ACTIVO:
        preset_config = apply_language_preset(PRESET_ACTIVO)
        if preset_config:
            config = preset_config
            print(f"📌 Usando preset: {PRESET_ACTIVO}")
    
    # Encabezado del output
    header = [
        "🔍 BÚSQUEDA INTELIGENTE - Archivos agrupados (sin repeticiones)",
        "=" * 65,
        f"🕐 Generado: {start_time.strftime('%Y-%m-%d %H:%M:%S')}",
        f"📁 Directorio: {config['dir']}",
        f"🔑 Keywords: {len(KEYWORDS)} patrones",
        f"📏 Contexto: {CONTEXT_LINES} líneas antes/después",
        f"🔀 Modo: {'AGRUPADO' if MODO_AGRUPADO else 'SEPARADO'}",
        "",
    ]
    
    all_output = []
    files_processed = set()
    total_matches = 0
    
    print(f"🔍 Iniciando búsqueda en '{config['dir']}'...")
    
    # ============================================
    # 🔀 LÓGICA CONDICIONAL: Agrupado vs Separado
    # ============================================
    
    if MODO_AGRUPADO:
        # ✅ MODO AGRUPADO: Buscar todas las keywords juntas en cada archivo
        print("   📦 Modo agrupado: buscando archivos con coincidencias...")
        
        # Paso 1: Encontrar todos los archivos que tengan AL MENOS una keyword
        all_files = set()
        for keyword in KEYWORDS:
            files = find_files_with_pattern(keyword, config)
            all_files.update(files)
        
        print(f"   📁 Archivos a procesar: {len(all_files)}")
        
        # Paso 2: Para cada archivo, buscar TODAS las keywords a la vez
        for file_path in all_files:
            print(f"\n🐛 DEBUG: Procesando archivo: {file_path}")
            print(f"🐛 Keywords a buscar: {KEYWORDS}")
            blocks, keywords_found = find_all_matches_in_file(
                file_path, 
                KEYWORDS, 
                CONTEXT_LINES, 
                GROUP_THRESHOLD, 
                CASE_SENSITIVE
            )
            

            # ✅ ESTOS PRINTS DEBEN ESTAR AQUÍ (ANTES DEL IF)
            print(f"🐛 Keywords encontradas: {keywords_found}")
            print(f"🐛 Tipo: {type(keywords_found)}")
            print(f"🐛 Cantidad: {len(keywords_found) if keywords_found else 0}")
            if blocks:
                # Usar "MÚLTIPLE" como etiqueta para indicar búsqueda agrupada
                output_section, _ = format_output(
                    blocks, 
                    "MÚLTIPLE", 
                    set(), 
                    keywords_found
                )
                all_output.append(output_section)
                files_processed.add(str(file_path))
                # Contar líneas con matches reales
                for b in blocks:
                    for line in b["lines"]:
                        if line["is_match"]:
                            total_matches += 1
    
    else:
        # ❌ MODO SEPARADO: Lógica original (una keyword a la vez)
        print("   📋 Modo separado: buscando cada keyword individualmente...")
        
        for keyword in KEYWORDS:
            files = find_files_with_pattern(keyword, config)
            
            if not files:
                output_section = f"🔎 Buscando: '{keyword}'\n"
                output_section += "─" * 70 + "\n"
                output_section += "   ⚠️  No se encontraron coincidencias\n\n"
                all_output.append(output_section)
                continue
            
            for file_path in files:
                blocks = extract_context_blocks(
                    file_path, keyword,
                    CONTEXT_LINES,
                    GROUP_THRESHOLD
                )
                if blocks:
                    total_matches += len(blocks)
                
                output_section, files_processed = format_output(
                    blocks, keyword, files_processed
                )
                all_output.append(output_section)
    
    # Footer con estadísticas
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    
    footer = [
        "",
        "=" * 65,
        "✅ RESULTADO LIMPIO",
        "=" * 65,
        "💡 Ventajas:",
        "• Cada archivo aparece SOLO UNA VEZ por keyword",
        "• Coincidencias cercanas se agrupan automáticamente",
        "• Bloques distantes se separan con '...'",
        "• Sin ruido visual de rutas repetidas",
        "",
        f"📊 Estadísticas:",
        f"   • Archivos únicos procesados: {len(files_processed)}",
        f"   • Bloques de contexto encontrados: {total_matches}",
        f"   • Tiempo de ejecución: {duration:.2f} segundos",
        "",
    ]
    
    # Escribir todo al archivo
    full_output = "\n".join(header) + "\n".join(all_output) + "\n".join(footer)
    
    try:
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            f.write(full_output)
        
        print(f"✅ Búsqueda completada!")
        print(f"📄 Resultados guardados en: {OUTPUT_FILE}")
        print(f"📊 {len(files_processed)} archivos, {total_matches} bloques encontrados")
        print(f"⏱️  Tiempo: {duration:.2f} segundos")
        
    except Exception as e:
        print(f"❌ Error al escribir archivo: {e}")


if __name__ == "__main__":
    main()