# dotfiles

chezmoi-managed dotfiles + provisioning for Arch Linux.

## Fresh install

The provisioning scripts install the desktop environment, display manager, audio, power stack, apps, and AUR packages themselves, so install a base system with no desktop components. Whether you use `archinstall` or the manual install guide, keep these choices consistent:

- **Desktop:** install no desktop environment or profile — the scripts install Plasma + niri.
- **Audio:** may be left unset or set to PipeWire — the scripts install PipeWire (`--needed` makes a pre-installed PipeWire a no-op).
- **Firewall:** may be left unset or set to Firewalld — the scripts install Firewalld (`--needed` makes a pre-installed Firewalld a no-op). Selecting UFW instead would conflict with the Firewalld the scripts install.
- **Network:** install and enable `NetworkManager` during the base install.
- **User:** add your user to the `wheel` group so `sudo` works.

## After first boot

```bash
sudo pacman -S chezmoi
chezmoi init --apply elucevelserve/dotfiles
```

This prompts for git name/email, applies dotfiles, and runs the provisioning scripts once (installs Plasma + `ly` + niri + app packages, enables services, starts `ly` last).

## After-first-boot provisioning scripts

- `run_once_before_00-pacman.sh` — enables parallel downloads in pacman.
- `run_once_before_01-packages.sh` — installs all official-repo packages (base-devel, Plasma, niri stack, apps, docker).
- `run_once_before_02-ohmyzsh.sh` — installs oh-my-zsh (runs before dotfiles are applied so the tracked `.zshrc` isn't clobbered).
- `run_once_after_00-system_setup.sh` — enables system/user services (tuned-ppd, pipewire, docker socket activation, zsh as login shell).
- `run_once_after_01-yay.sh` — bootstraps yay (AUR) and installs `wl-gammarelay-rs` (blue-light filter daemon) + `onlyoffice-bin`.
- `run_once_after_02-kmonad.sh` — optional kmonad setup (see below).
- `run_once_after_99-ly.sh` — starts `ly` (the display manager; `getty@tty1` is disabled so `ly` owns tty1).

## kmonad (optional)

kmonad swaps **Esc and Caps Lock** and targets internal laptop keyboards. It's opt-in: answer **y** to the kmonad prompt during `chezmoi init` (default is off). When enabled, the config is applied and `run_once_after_02-kmonad.sh` installs kmonad, adds your user to the `input,uinput` groups, and enables a per-user service. On machines that opt out, no kmonad config or service is created.

## Plasma config

Plasma writes its config live to `~/.config/` (KConfig INI files). The stable files are tracked: `kdeglobals`, `kwinrc`, `kwinrulesrc`, `kglobalshortcutsrc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `plasma-localerc`. After changing settings, capture the change with `chezmoi re-add ~/.config/<file>`.

Not tracked (machine-specific or churn): `kwinoutputconfig.json` (EDID/connector/brightness), `kactivitymanagerdrc` (activity UUIDs), `kconf_updaterc` (migration bookkeeping), `kded5rc`/`kdedefaults/`.

## Portals (niri session)

Portal routing lives in `~/.config/xdg-desktop-portal/niri-portals.conf`:

- `default=kde` — everything (FileChooser, Settings, Print, ...) goes to the KDE backend.
- `org.freedesktop.impl.portal.Secret=kwallet` — the KDE backend doesn't implement Secret; KWallet 6's `ksecretd` does.
- `org.freedesktop.impl.portal.ScreenCast=wlr` and `org.freedesktop.impl.portal.Screenshot=wlr` — the KDE backend implements these via KWin over D-Bus, which doesn't exist in niri. `xdg-desktop-portal-wlr` handles them via `zwlr_screencopy` with a slurp crosshair (monitor-only: niri lacks the ext image-capture protocols for window casting; that would require `xdg-desktop-portal-gnome` and its GNOME stack).

## KWallet unlock ordering (niri)

`plasma-kwallet-pam.service` unlocks the wallet with the login password. Its stock unit depends on `plasma-kwin_wayland.service`, which doesn't exist in niri, so it can race niri at login and miss the unlock. A drop-in `~/.config/systemd/user/plasma-kwallet-pam.service.d/override.conf` adds `After=niri.service` to fix the ordering; it's inert in Plasma.

A wallet named `kdewallet` is created automatically at session start in either the niri or Plasma session (PAM and manual unlock both work as long as its password matches the login password).

## Notes

- `run_once_` scripts run only once per content version. If one fails partway, fix and force a re-run:
  `chezmoi state delete-bucket --bucket=scriptState`
- The niri session uses quickshell as its bar; the polkit auth agent (`plasma-polkit-agent`), `plasma-kwallet-pam`, and `wl-gammarelay` are started as user services via `niri.service.wants`.
