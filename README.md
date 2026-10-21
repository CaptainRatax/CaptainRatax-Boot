# CaptainRatax Boot

**Version 7** of the custom Plymouth splash for CachyOS and Arch Linux. It displays a personalized wallpaper, a centered logo, a green progress bar, and a panel with recent boot messages.

This package is intended for use with **Plymouth + systemd**, including CachyOS installations using **Limine**. It does not replace or modify existing Limine/Snapper snapshots.

## What changed in v7

- **The 1440p layout is unchanged** from v6, including the logo, progress bar,
  log panel size, text size, and spacing.
- The 1080p layout now uses the **1440p geometry as its master**, scaled
  uniformly by **0.75** for a native 1920 × 1080 Plymouth viewport.
- The 1080p panel is therefore larger than in v6, and the entire composition
  sits at the same relative vertical and horizontal positions as the 1440p version.
- The 1920 × 1080 wallpaper is now downscaled directly from the unchanged
  2560 × 1440 wallpaper using aspect-preserving Lanczos resampling.
- Plymouth window changes still trigger layout updates; log forwarding,
  installation scripts, systemd unit and 1440p visual assets are unchanged.

> **Display behavior:** Plymouth chooses the background and layout using the
> viewport size *reported by Plymouth*, which may differ from the resolution in
> your desktop session while drivers are initializing. At native 1080p and
> 1440p, both layouts use the same 16:9 composition. Other viewport sizes are
> handled on a best-effort basis.

## Files

```text
CaptainRatax-Boot-v7/
├── README.md
├── install.sh
├── boot-log-forwarder
├── captainratax-boot/
│   ├── captainratax-boot.plymouth
│   ├── captainratax-boot.script
│   ├── background-1080.png
│   ├── background-1440.png
│   ├── logo.png
│   ├── logs-panel.png
│   ├── password-panel.png
│   ├── progress-fill.png
│   └── progress-track.png
└── systemd/
    └── captainratax-boot-logs.service
```

## Requirements

- Plymouth with the `script` plugin, systemd, and journalctl.
- On CachyOS with Limine, the `limine-mkinitcpio` command and the `plymouth` mkinitcpio hook.
- Root permission to install system theme files and regenerate the initramfs.

## Upgrade from v6 (CachyOS + Limine)

Extract the archive and enter its top-level directory:

```bash
cd ~/Downloads
tar -xzf CaptainRatax-Boot-v7.tar.gz
cd CaptainRatax-Boot-v7
sudo ./install.sh
sudo plymouth-set-default-theme captainratax-boot
sudo systemctl enable captainratax-boot-logs.service
sudo limine-mkinitcpio
```

The installer **only copies files** and reloads the systemd unit definitions. It does not enable a service, change the active theme, edit Limine kernel parameters, or rebuild the initramfs by itself. Wait for a successful `limine-mkinitcpio` build before rebooting.

Make sure `/etc/default/limine` still enables Plymouth with `splash` and does not contain `plymouth.enable=0`. Preserve all existing root/Btrfs identifiers and kernel options. Do not replace your working kernel command line with a generic example.

## Verify

```bash
plymouth-set-default-theme
systemctl is-enabled captainratax-boot-logs.service
```

To examine full logs after boot:

```bash
journalctl -b --no-pager
journalctl -b -u captainratax-boot-logs.service --no-pager
```

## Roll back to your previous Plymouth theme

```bash
sudo systemctl disable --now captainratax-boot-logs.service
sudo plymouth-set-default-theme cachyos-mac-style
sudo limine-mkinitcpio
```

If you have a local copy of v6, reinstall that version to restore its previous 1080p layout before regenerating the initramfs. Alternatively, use `cachyos-mac-style` as a known working option.

## Limitations and privacy

- Plymouth provides estimated boot progress, not a guarantee that startup is complete.
- The log forwarder only streams journal messages **after its systemd service starts**. This is not a full early-kernel log console; the last visible line does not identify the cause of a freeze.
- The log panel may also be visible during shutdown; full journal output remains accessible through `journalctl` after boot.
- Journal messages may contain operational details. Do not use this display on screens visible to untrusted viewers without reviewing the forwarding script.
- The original wallpaper provided in this conversation was available as a 2048 × 1152 image, and the two assets in this package were resampled from that file. Use the original 3840 × 2160 wallpaper when available if you want to rebuild these files from the highest-quality source.

## GitHub publishing

The script and README are written in English. Review the usage rights for the personal logo and wallpaper separately from the repository's source-code license before redistributing the assets.

## Testing

The code structure and installer can be checked offline, and the background dimensions and aspect ratios can be verified exactly. Real output should still be tested on both your 1080p and 1440p monitors during a normal boot and shutdown. This package has not been tested inside your running Plymouth environment.
