# dotfiles

chezmoi-managed dotfiles + provisioning for Arch Linux.

## Fresh install

The provisioning script (`run_once_after_00-plasma.sh`) installs the desktop environment, display manager, audio, and power stack itself. On a fresh install, only these choices matter — mirrors, locale, keyboard, disk layout, bootloader, and kernel are all orthogonal and can be whatever you prefer.

- **Profile:** `Minimal` (do **not** pick a desktop profile — the script installs Plasma).
- **Audio:** leave unset (the script installs PipeWire).
- **Network:** `NetworkManager` (the script enables it).
- **User:** create your user in the `wheel` group so `sudo` works.

Do **not** install a desktop environment, display manager (sddm/gdm/lightdm), display server, or sound server ahead of time — the script owns all of those.

## After first boot

```bash
sudo pacman -S chezmoi
chezmoi init --apply elucevelserve/dotfiles
```

This prompts for git name/email, applies dotfiles, and runs the Plasma provisioning script once (installs Plasma + `ly`, enables services, starts `ly` last). Log into **Plasma (Wayland)** at the `ly` greeter.

## Notes

- The `run_once_` script runs only once per content version. If it fails partway, fix and force a re-run:
  `chezmoi state delete-bucket --bucket=scriptState`
- `ly` is the display manager (not SDDM). SDDM is disabled and `getty@tty1` is disabled so `ly` owns tty1.
- Bluetooth is enabled only if hardware is present.
