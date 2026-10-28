#!/system/bin/sh
# analizar_memoria.sh - Analiza toda la memoria del celular y genera un reporte
# Uso: /system/bin/sh analizar_memoria.sh [output.txt]

OUT="${1:-/sdcard/reporte_memoria.txt}"
SD="/storage/D45F-418D"
INTERNAL="/storage/emulated/0"

echo "=== ANÁLISIS DE MEMORIA DEL CELULAR ==="
echo "Fecha: $(date)"
echo "SD: $SD"
echo "Interno: $INTERNAL"
echo ""

# --- SECCIÓN 1: ÍNDICE DE ARCHIVOS POR TIPO ---
echo "============================================"
echo "SECCIÓN 1: INVENTARIO DE ARCHIVOS POR TIPO"
echo "============================================"

for dir in "$SD" "$INTERNAL"; do
    if [ ! -d "$dir" ]; then continue; fi
    echo ""
    echo "--- Directorio: $dir ---"
    
    # Contar por extensión
    find "$dir" -type f 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | while read count ext; do
        [ -z "$ext" ] && ext="(sin extensión)"
        echo "  .$ext: $count archivos"
    done
done

# --- SECCIÓN 2: ARCHIVOS GRANDES (> 1 MB) ---
echo ""
echo "============================================"
echo "SECCIÓN 2: ARCHIVOS GRANDES (> 1 MB)"
echo "============================================"
for dir in "$SD" "$INTERNAL"; do
    find "$dir" -type f -size +1M 2>/dev/null | while read f; do
        size=$(du -h "$f" 2>/dev/null | cut -f1)
        echo "  $size  $f"
    done
done

# --- SECCIÓN 3: ARCHIVOS DE TEXTO LEÍDOS ---
echo ""
echo "============================================"
echo "SECCIÓN 3: CONTENIDO DE ARCHIVOS DE TEXTO"
echo "============================================"

TEXT_EXTS="txt md json xml html htm css js ts py sh php java kt swift c cpp h go rs rb perl pl lua sql yaml yml ini cfg conf log csv tsv"

for dir in "$SD" "$INTERNAL"; do
    find "$dir" -type f 2>/dev/null | while read f; do
        ext="${f##*.}"
        # Check if extension is in our text list
        is_text=0
        for t in $TEXT_EXTS; do
            if [ "$ext" = "$t" ]; then
                is_text=1
                break
            fi
        done
        
        if [ "$is_text" = "1" ]; then
            size=$(stat -c%s "$f" 2>/dev/null || echo 0)
            # Skip files larger than 100KB
            if [ "$size" -lt 102400 ]; then
                echo ""
                echo "----------------------------------------"
                echo "ARCHIVO: $f ($size bytes)"
                echo "----------------------------------------"
                cat "$f" 2>/dev/null | head -200
                echo ""
                echo "[... fin del archivo ...]"
            else
                echo ""
                echo "ARCHIVO: $f ($size bytes) - DEMASIADO GRANDE, OMITIDO"
            fi
        fi
    done
done

# --- SECCIÓN 4: ARCHIVOS DE INTERÉS ESPECIAL ---
echo ""
echo "============================================"
echo "SECCIÓN 4: ARCHIVOS DE INTERÉS ESPECIAL"
echo "============================================"

for dir in "$SD" "$INTERNAL"; do
    echo ""
    echo "--- En $dir ---"
    find "$dir" -type f \( -name "*.pdf" -o -name "*.docx" -o -name "*.xlsx" -o -name "*.apk" -o -name "*.zip" -o -name "*.rar" -o -name "*.mp4" -o -name "*.mp3" -o -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | while read f; do
        size=$(du -h "$f" 2>/dev/null | cut -f1)
        echo "  $size  $f"
    done
done

# --- SECCIÓN 5: ESTRUCTURA DE DIRECTORIOS ---
echo ""
echo "============================================"
echo "SECCIÓN 5: ESTRUCTURA DE DIRECTORIOS"
echo "============================================"

for dir in "$SD" "$INTERNAL"; do
    echo ""
    echo "--- $dir ---"
    find "$dir" -maxdepth 3 -type d 2>/dev/null | sort | while read d; do
        depth=$(echo "$d" | sed "s|$dir||" | tr -cd '/' | wc -c)
        indent=""
        i=0
        while [ $i -lt $depth ]; do
            indent="$indent  "
            i=$((i+1))
        done
        name=$(basename "$d")
        echo "$indent$name/"
    done
done

echo ""
echo "=== ANÁLISIS COMPLETO ==="
echo "Reporte guardado en: $OUT"
