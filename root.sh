#!/bin/sh

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
max_retries=50
timeout=1
ARCH=$(uname -m)

# Determine architecture
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=x86_64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=aarch64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                               Alpine Miniroot Installer"
  echo "#"
  echo "#                           Copyright (C) 2024, YourName"
  echo "#"
  echo "#######################################################################################"

  install_alpine=YES
fi

case $install_alpine in
  [yY][eE][sS])
    echo "Downloading Alpine Miniroot tarball..."
    curl --retry $max_retries --retry-delay $timeout -L -o /tmp/rootfs.tar.gz \
      "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/${ARCH_ALT}/alpine-minirootfs-3.18.4-${ARCH_ALT}.tar.gz"

    echo "Extracting Alpine Miniroot tarball..."
    mkdir -p "$ROOTFS_DIR"
    tar -xzf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
    ;;
  *)
    echo "Skipping Alpine installation."
    ;;
esac

# Install Proot
if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  mkdir -p "$ROOTFS_DIR/usr/local/bin"
  echo "Downloading Proot binary..."
  curl --retry $max_retries --retry-delay $timeout -L -o "$ROOTFS_DIR/usr/local/bin/proot" \
    "https://github.com/2B3G/root/raw/refs/heads/main/proot-${ARCH}"

  # Retry logic for Proot download
  while [ ! -s "$ROOTFS_DIR/usr/local/bin/proot" ]; do
    echo "Retrying download for Proot binary..."
    rm -f "$ROOTFS_DIR/usr/local/bin/proot"
    curl --retry $max_retries --retry-delay $timeout -L -o "$ROOTFS_DIR/usr/local/bin/proot" \
      "https://github.com/2B3G/root/raw/refs/heads/main/proot-${ARCH}"

    if [ -s "$ROOTFS_DIR/usr/local/bin/proot" ]; then
      chmod 755 "$ROOTFS_DIR/usr/local/bin/proot"
      break
    fi
    sleep 1
  done

  chmod 755 "$ROOTFS_DIR/usr/local/bin/proot"
fi

# Set up network and finalize installation
if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  echo "Configuring network..."
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > "${ROOTFS_DIR}/etc/resolv.conf"

  echo "Cleaning up temporary files..."
  rm -f /tmp/rootfs.tar.gz
  touch "$ROOTFS_DIR/.installed"
fi

# Color codes for display
CYAN='\e[0;36m'
WHITE='\e[0;37m'
RESET_COLOR='\e[0m'

# Completion message
display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Mission Completed ! <----${RESET_COLOR}"
  echo -e ""
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
}

clear
display_gg

# Start Alpine Miniroot with Proot
"$ROOTFS_DIR/usr/local/bin/proot" \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit
