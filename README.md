# dotfiles

chezmoi-managed dotfiles + provisioning for Arch Linux.

## Fresh install

The provisioning script (`run_once_after_00-plasma.sh`) installs the desktop environment, display manager, audio, and power stack itself, so install a base system with no desktop components. Whether you use `archinstall` or the manual install guide, keep these choices consistent:

- **Desktop:** install no desktop environment or profile — the script installs Plasma.
- **Display server / sound server:** none — the script installs the display manager and PipeWire.
- **Network:** install and enable `NetworkManager` during the base install.
- **User:** add your user to the `wheel` group so `sudo` works.

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
