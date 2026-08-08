#!/usr/bin/env bash
set -euo pipefail

ISO_PATH="/iso/win10.iso"
ISO_TMP="/iso/win10.iso.part"
DISK_PATH="/data/win10.qcow2"
QEMU_PID=""
NOVNC_PID=""

cleanup() {
  [ -z "$NOVNC_PID" ] || kill "$NOVNC_PID" 2>/dev/null || true
  [ -z "$QEMU_PID" ] || kill "$QEMU_PID" 2>/dev/null || true
  rm -f "$ISO_TMP"
}
trap cleanup EXIT INT TERM

if [ -e /dev/kvm ]; then
  echo "KVM acceleration available"
  KVM_ARGS=(-enable-kvm -cpu host -m 4G -smp 4)
else
  echo "KVM unavailable; using slower TCG emulation"
  KVM_ARGS=(-cpu qemu64 -m 2G -smp 1)
fi

if [ ! -s "$ISO_PATH" ]; then
  rm -f "$ISO_PATH" "$ISO_TMP"
  echo "Downloading Windows 10 ISO"
  wget --progress=dot:giga --tries=3 --timeout=30 "$ISO_URL" -O "$ISO_TMP"
  test -s "$ISO_TMP"
  mv "$ISO_TMP" "$ISO_PATH"
fi

if [ ! -f "$DISK_PATH" ]; then
  echo "Creating 100GB virtual disk"
  qemu-img create -f qcow2 "$DISK_PATH" 100G
fi

qemu-system-x86_64 \
  "${KVM_ARGS[@]}" \
  -machine q35,accel=kvm:tcg \
  -vga std \
  -usb -device usb-tablet \
  -boot order=d,menu=on \
  -drive file="$DISK_PATH",format=qcow2 \
  -drive file="$ISO_PATH",media=cdrom,readonly=on \
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
  -device e1000,netdev=net0 \
  -display vnc=:0 \
  -name Windows10_VM &
QEMU_PID=$!

websockify --web /usr/share/novnc 6080 localhost:5900 &
NOVNC_PID=$!

echo "noVNC: port 6080; RDP after Windows setup: port 3389"
wait -n "$QEMU_PID" "$NOVNC_PID"
echo "QEMU or noVNC exited unexpectedly" >&2
exit 1
