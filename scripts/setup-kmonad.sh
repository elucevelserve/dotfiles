#!/bin/bash
set -euo pipefail
# One-time kmonad setup for internal laptop keyboards.
# Opt-in: run this manually. The resulting config is user-owned and is NOT
# tracked by chezmoi, so your edits survive `chezmoi update`.

sudo pacman -S --needed --noconfirm kmonad
sudo usermod -aG input,uinput "$USER"

mkdir -p ~/.config/kmonad
cat > ~/.config/kmonad/config.kbd <<'EOF'
(defcfg
	input  (device-name "AT Translated Set 2 keyboard")
	output (uinput-sink "KMonad kbd")
	fallthrough true
)

(defsrc
	esc
	caps
)

(deflayer switch
	caps
	esc
)
EOF

mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/kmonad.service <<'EOF'
[Unit]
Description=KMonad keyboard config

[Service]
Restart=always
RestartSec=3
ExecStart=/usr/bin/kmonad %h/.config/kmonad/config.kbd
Nice=-20

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now kmonad.service

echo "kmonad setup complete. Esc and Caps Lock are swapped."
echo "Edit ~/.config/kmonad/config.kbd to customize; it is user-owned."
