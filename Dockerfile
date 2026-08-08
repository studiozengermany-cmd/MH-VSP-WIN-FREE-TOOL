FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ISO_URL="https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso"

RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    novnc \
    websockify \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data /iso

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080 3389

CMD ["/entrypoint.sh"]
