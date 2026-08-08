FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt QEMU, KVM, noVNC và các thư viện mạng
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    novnc \
    websockify \
    wget \
    curl \
    net-tools \
    python3 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data /iso /novnc

# Cài noVNC master
RUN wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/noVNC.zip && \
    unzip /tmp/noVNC.zip -d /tmp && \
    mv /tmp/noVNC-master/* /novnc && \
    rm -rf /tmp/noVNC.zip /tmp/noVNC-master

# Link gốc tải ISO Windows 10
ENV ISO_URL=https://archive.org/download/windows-10-111/Win10_22H2_English_x64.iso

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# VNC Web (6080) và RDP (3389)
EXPOSE 5900 6080 3389

CMD ["/entrypoint.sh"]
