#!/bin/bash

echo -e "\n=========== YouTube Audio & Video Extractor ==========="


# === Verificar yt-dlp ===
if ! command -v yt-dlp &> /dev/null; then
    echo -e "\n[INFO] yt-dlp no está instalado. Instalando..."
    sudo apt update && sudo apt install -y wget
    sudo wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
    sudo chmod +x /usr/local/bin/yt-dlp
    echo "[OK] yt-dlp instalado correctamente."
else
    echo "[✔️ OK] yt-dlp ya está instalado."
fi

# === Verificar ffmpeg ===
if ! command -v ffmpeg &> /dev/null; then
    echo -e "\n[INFO] ffmpeg no está instalado. Instalando..."
    sudo apt update && sudo apt install -y ffmpeg
    echo "[OK] ffmpeg instalado correctamente."
else
    echo "[✔️ OK] ffmpeg ya está instalado."
fi

# === Pedir URL ===
echo
read -p "👉 Introduce la URL del vídeo de YouTube: " url

# === Mostrar formatos disponibles ===
echo -e "\n🎞️ Formatos de vídeo disponibles:\n"
yt-dlp -F "$url"

# === Elegir formato de vídeo (sin audio) ===
read -p "🧠 Introduce el código del formato de vídeo (sin audio): " video_format

# === Nombre base de los archivos de salida ===
output_name="output_$(date +%s)"

# === Descargar audio MP3 ===
echo -e "\n🎧 Descargando audio en MP3..."
yt-dlp -f bestaudio -x --audio-format mp3 -o "${output_name}.mp3" "$url"

# === Descargar vídeo sin audio (y reempaquetar correctamente) ===
echo -e "\n📽️ Descargando vídeo sin audio..."
yt-dlp -f "$video_format" -o "${output_name}.video.mp4" --merge-output-format mp4 "$url"

# === Comprimir y eliminar audio del vídeo ===
echo -e "\n⚙️ Eliminando audio y comprimiendo vídeo..."
ffmpeg -i "${output_name}.video.mp4" -an -vcodec libx265 -crf 28 "${output_name}_video_noaudio.mp4"

# === Mostrar info del audio ===
echo -e "\n📄 Información del archivo de audio:"
ffmpeg -i "${output_name}.mp3" 2>&1 | grep -E 'Duration|Stream'

# === Mostrar info del vídeo ===
echo -e "\n📄 Información del archivo de vídeo sin audio:"
ffmpeg -i "${output_name}_video_noaudio.mp4" 2>&1 | grep -E 'Duration|Stream'

echo -e "\n✅ Proceso finalizado con éxito."
