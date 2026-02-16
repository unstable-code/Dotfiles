# Dotfiles

Personal configuration files for Linux (Wayland) and Windows environments.

## Structure

```
.
├── Specific/                    # OS-specific configs
│   ├── Linux/General/           # Linux (Wayland)
│   │   ├── .config/
│   │   │   ├── hypr/            # Hyprland window manager
│   │   │   ├── sway/            # Sway window manager (alternative)
│   │   │   ├── waybar/          # Status bar
│   │   │   ├── rofi/            # Application launcher
│   │   │   ├── matugen/         # Material You theme generator
│   │   │   ├── swaync/          # Notification center
│   │   │   ├── nvim/            # Neovim editor
│   │   │   ├── mpv/             # Media player
│   │   │   └── fcitx5/          # Input method (Korean)
│   │   ├── .local/share/
│   │   │   └── wayland-scripts/ # Shared Wayland helper scripts
│   │   ├── .zshrc
│   │   ├── .bashrc
│   │   └── .tmux.conf
│   └── Windows/
│       ├── .glzr/
│       │   ├── glazewm/         # GlazeWM tiling window manager
│       │   └── zebar/           # Zebar status bar (React)
│       └── WSL/                 # WSL-specific configs
├── Universal/                   # Cross-platform configs
│   ├── .claude/                 # Claude Code
│   └── .gemini/                 # Google Gemini
└── Operating System -> Specific/
```

## Linux

| Component | Program |
|-----------|---------|
| Window Manager | Hyprland / Sway |
| Status Bar | Waybar |
| Launcher | Rofi |
| Notifications | Swaync |
| Shell | Zsh (Oh-My-Zsh) |
| Editor | Neovim (Lua) |
| Multiplexer | Tmux |
| Media Player | MPV |
| Input Method | Fcitx5 |
| Theming | Matugen (Material You) |
| Lock Screen | Hyprlock |
| Idle Manager | Hypridle |
| Wallpaper | SWWW |

### Highlights

- **Material You dynamic theming** — Matugen auto-generates Rofi and Waybar colors from the wallpaper
- **Modular per-machine rules** — Machine-specific configs (`rules/`) are gitignored for individual management
- **Unified backend script** — Notifications, wallpaper, sleep, audio, media, and power control in a single script
- **Privacy mode** — Separate privacy lock screen alongside the normal lock screen

## Windows

| Component | Program |
|-----------|---------|
| Window Manager | GlazeWM |
| Status Bar | Zebar |

Includes Zsh and Vim configs for WSL.

## License

[MIT](LICENSE)