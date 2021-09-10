FROM nvidia/cuda:11.0-base-ubuntu20.04
RUN apt update && apt install -y ffmpeg cron
RUN mkdir /ffmpeg
RUN mkdir /config

COPY Files/root /etc/cron.d/nvidia-ffmpeg
COPY Files/encode.sh /config/encode.sh
COPY Files/files.txt /config/files.txt
RUN chmod u+x /config/encode.sh
VOLUME [/config /watch /output]
RUN chmod 0644 /etc/cron.d/nvidia-ffmpeg && crontab /etc/cron.d/nvidia-ffmpeg
CMD ["cron","-f", "-l", "2"]