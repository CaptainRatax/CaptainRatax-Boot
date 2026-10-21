# CaptainRatax Boot

A custom Plymouth boot splash for **CachyOS**, featuring a personal wallpaper, a centered logo, a green progress bar, and a panel showing recent boot messages.

The theme is intended for systems using **Limine** and has been packaged so that it can coexist with existing Plymouth themes such as `cachyos-mac-style`.

> **Testing status:** The files have been prepared and the Bash scripts checked for syntax errors, but the Plymouth theme has **not** been tested on a physical CachyOS boot. Always test carefully and keep an alternative boot entry available.

## Features

- Full-screen wallpaper, converted to PNG for Plymouth.
- Centered personal logo.
- Green Plymouth progress bar.
- A display panel for the eight most recent messages received by the theme.
- Optional systemd service that forwards journal messages to Plymouth while the splash is running.
- A separate theme directory, leaving the existing Plymouth theme untouched.

## Project structure

```text
captainratax-boot-theme/
├── README.md
├── install.sh
├── boot-log-forwarder
├── captainratax-boot/
│   ├── captainratax-boot.plymouth
│   ├── captainratax-boot.script
│   ├── background.png
│   ├── logo.png
│   ├── logs-panel.png
│   ├── password-panel.png
│   ├── progress-fill.png
│   └── progress-track.png
└── systemd/
    └── captainratax-boot-logs.service
```

## Requirements

- Linux with Plymouth and systemd installed.
- The Plymouth **script** module.
- `journalctl`, for the optional log forwarding service.
- CachyOS with Limine and `limine-mkinitcpio` if following the bootloader instructions below.

## Installation

Extract the archive, open the project directory, and install its files:

```bash
sudo ./install.sh
```

Check that Plymouth can see the theme:

```bash
plymouth-set-default-theme -l | grep captainratax-boot
```

The installer **does not** change the active Plymouth theme, enable the log service, edit your kernel command line, or regenerate your initramfs.

## Enable the theme

Select the new theme (without using `-R`):

```bash
sudo plymouth-set-default-theme captainratax-boot
```

Optionally enable live boot messages:

```bash
sudo systemctl enable captainratax-boot-logs.service
```

### Limine boot parameters

Edit `/etc/default/limine` and verify that your existing `KERNEL_CMDLINE[default]` includes `splash` and does **not** include `plymouth.enable=0`.

Typically, `quiet` is used to keep the raw kernel messages from appearing over the graphical splash. Preserve all existing storage, root filesystem, and Btrfs parameters.

For example, a **template** for a Btrfs root filesystem looks like this:

```ini
KERNEL_CMDLINE[default]+="quiet nowatchdog splash rw rootflags=subvol=/@ root=UUID=<YOUR-ROOT-FILESYSTEM-UUID>"
```

**Do not paste this template verbatim.** Keep the real `root=`, `rootflags=`, and any other required parameters from your working configuration.

Apply the Plymouth and Limine changes:

```bash
sudo limine-mkinitcpio
```

Only reboot after the command completes successfully. Do not edit `/boot/limine.conf` manually just to apply these settings.

## Restore the previous theme

To return to the original `cachyos-mac-style` theme:

```bash
sudo systemctl disable --now captainratax-boot-logs.service
sudo plymouth-set-default-theme cachyos-mac-style
sudo limine-mkinitcpio
```

Ensure the Limine kernel command line still enables Plymouth (`splash` and no `plymouth.enable=0`). Keep your existing Limine/Snapper recovery entries intact.

## Troubleshooting

Check the log forwarding service:

```bash
systemctl status captainratax-boot-logs.service
journalctl -b -u captainratax-boot-logs.service --no-pager
```

Review the full boot journal separately:

```bash
journalctl -b --no-pager
```

If the graphics render but the text is missing, check that Plymouth can render the selected font in your initramfs, that Plymouth's hooks are configured properly, and that your initramfs has been regenerated.

### Restore the original wallpaper resolution

The bundled `background.png` is a PNG conversion of the supplied wallpaper, resized to 2048 x 1152 to reduce the theme size. If the original 3840 x 2160 JPEG is available, you can replace the installed PNG with ImageMagick:

```bash
sudo magick '/path/to/Wallpaper_background.jpg' -strip \
  /usr/share/plymouth/themes/captainratax-boot/background.png
sudo limine-mkinitcpio
```

Plymouth's script image loader expects PNG assets, so the original JPEG should not be referenced directly by `Image(...)` in the script.

## Important limitations

- **Not a complete boot log viewer:** The theme displays up to eight recent messages. The optional forwarder uses `journalctl -b -n 6 -f --no-pager -o short-monotonic`, and therefore starts collecting messages only once its systemd service runs.
- **Early boot events are not guaranteed to appear:** Firmware, bootloader, and early kernel/initramfs messages may not be visible in the panel.
- **A full system freeze can stop the display:** The last visible message is not necessarily the component responsible for a freeze.
- **The bar is an estimate:** Plymouth's progress callbacks do not guarantee that all boot tasks have completed.
- **Privacy:** Some journal entries can contain sensitive operational information. Messages are displayed on the physical screen during boot; avoid forwarding logs on untrusted displays. The forwarder sanitizes control characters and truncates lines to 105 characters but does not redact secrets.

## Publishing on GitHub

The included wallpaper and logo are user-provided assets. Review their publication permissions before committing them to a public repository. No open-source license is assigned automatically to the code or artwork; choose and document licensing terms explicitly if you plan to publish the repository.
