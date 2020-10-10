TWITCH_TOKEN="${1:-${TWITCH_TOKEN}}"
YOUTUBE_TOKEN="${2:-${YOUTUBE_TOKEN}}"
YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_TOKEN}"  # URL de base RTMP youtube
TWITCH_URL="rtmp://live-prg.twitch.tv/app/${TWITCH_TOKEN}"

ffmpeg -i http://space.radio.mynoise.net -c:a aac -f x11grab -framerate 30 -video_size 1920x1080 \
        -i :0.0+0,0 -flags +global_header -c:v libx264 -preset veryfast -b:v 1984k -maxrate 1984k -bufsize 3968k \
        -vf "format=yuv420p" -g 60 -c:a aac -b:a 128k -ar 44100 \
        -f tee -map 0:a -map 1:v "[f=flv:onfail=ignore]${TWITCH_URL}|[f=flv:onfail=ignore]${YOUTUBE_URL}"
