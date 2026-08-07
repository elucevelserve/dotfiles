# dotfiles

chezmoi-managed dotfiles + provisioning for Arch Linux.

## Fresh install

The provisioning script (`run_once_after_00-plasma.sh`) installs the desktop environment, display manager, audio, and power stack itself, so install a base system with no desktop components. Whether you use `archinstall` or the manual install guide, keep these choices consistent:

- **Desktop:** install no desktop environment or profile — the script installs Plasma.
- **Audio:** may be left unset or set to PipeWire — the script installs PipeWire (`--needed` makes a pre-installed PipeWire a no-op).
- **Network:** install and enable `NetworkManager` during the base install.
- **User:** add your user to the `wheel` group so `sudo` works.

## After first boot

```bash
sudo pacman -S chezmoi
chezmoi init --apply elucevelserve/dotfiles
```

This prompts for git name/email, applies dotfiles, and runs the provisioning scripts once (installs Plasma + `ly` + app packages, enables services, starts `ly` last). Log into **Plasma (Wayland)** at the `ly` greeter.

## After-first-boot provisioning scripts

- `run_once_after_00-plasma.sh` — installs the session stack and starts `ly` (the display manager; `getty@tty1` is disabled so `ly` owns tty1).
- `run_once_after_01-apps.sh` — installs the config-file apps, switches the login shell to zsh, and installs oh-my-zsh.

## kmonad (optional, one-time)

kmonad swaps **Esc and Caps Lock** and targets internal laptop keyboards. It's an opt-in, manual setup that installs `kmonad` and writes a per-user service:

```bash
./scripts/setup-kmonad.sh
```

The resulting `~/.config/kmonad/config.kbd` is **user-owned** and not tracked by chezmoi, so your edits survive `chezmoi update`.

## Notes

- `run_once_` scripts run only once per content version. If one fails partway, fix and force a re-run:
  `chezmoi state delete-bucket --bucket=scriptState`
