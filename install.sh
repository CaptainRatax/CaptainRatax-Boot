#!/usr/bin/env bash
# Install the Plymouth theme and the optional log forwarder.
# This script does not modify the active boot configuration.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo 'Run this installer as root: sudo ./install.sh' >&2
    exit 1
fi

base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
target=/usr/share/plymouth/themes/captainratax-boot

install -d -m 755 "$target" /usr/local/libexec /etc/systemd/system
install -m 644 "$base/captainratax-boot/"* "$target/"
install -m 755 "$base/boot-log-forwarder" /usr/local/libexec/captainratax-boot-log-forwarder
install -m 644 "$base/systemd/captainratax-boot-logs.service" /etc/systemd/system/captainratax-boot-logs.service
systemctl daemon-reload

printf '\nInstallation complete. No services were enabled, and Limine was not modified.\n'
printf 'Check available themes: plymouth-set-default-theme -l\n'
printf 'Select the new theme: sudo plymouth-set-default-theme captainratax-boot\n'
printf 'Enable boot messages: sudo systemctl enable captainratax-boot-logs.service\n'
printf 'Regenerate Limine/initramfs: sudo limine-mkinitcpio\n'
