#!/bin/bash
set -e

echo "====================================="
echo "   Khởi Động VPS WIN FREE TOOL       "
echo "====================================="

# Check for KVM support
if [ -e /dev/kvm ]; then
  echo "✅ KVM acceleration available (Tốc độ tối đa)"
  KVM_ARG="-enable-kvm"
  CPU_ARG="host"
  MEMORY="4G"
  SMP_CORES=4
else
  echo "⚠️ KVM not available - using slower emulation (Giả lập chậm)"
  KVM_ARG=""
  CPU_ARG="qemu64"
  MEMORY="2G"
  SMP_CORES=2
fi

# Tải ISO nếu chưa có
if [ ! -f /iso/win10.iso ]; then
  echo "📥 Downloading Windows 10 ISO (Đang tải ISO Windows...)"
  wget $ISO_URL -O /iso/win10.iso
fi

# Tạo ổ cứng nếu chưa có
if [ ! -f /data/win10.qcow2 ]; then
  echo "💾 Creating virtual disk 100G (Tạo ổ cứng ảo)..."
  qemu-img create -f qcow2 /data/win10.qcow2 100G
fi

echo "🚀 Starting Windows 10 VM..."
echo "💻 VNC Web Interface: http://localhost:6080/vnc.html"

# Mở noVNC
websockify --web=/novnc --wrap-mode=ignore 6080 localhost:5900 &

# Chạy QEMU
exec qemu-system-x86_64 $KVM_ARG -cpu $CPU_ARG -smp $SMP_CORES -m $MEMORY \
  -drive file=/data/win10.qcow2,if=virtio \
  -cdrom /iso/win10.iso \
  -net nic,model=virtio -net user,hostfwd=tcp::3389-:3389 \
  -vnc :0
