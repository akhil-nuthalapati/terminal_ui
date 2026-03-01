Terminal Personalization System

Cross-shell the Bash and Zsh framework to safely display ASCII banners with gradients and style prompts.

Features include one-command reset, safe RC injection, bold text, persistent banners (figlet + lolcat), 256-color prompts, and no telemetry.

How It Works: Zsh: precmd hook; Bash: PS1 override. session-aware to stop banners from appearing repeatedly. The configuration is ~/.config/terminal_customax/.

Configure:

Install figlet lolcat using sudo apt

Kali, Ubuntu, Debian, Arch, and POSIX Unix are all supported.

Why: Lightweight, manages theme overrides, seamless across shells, and clean removal.

Design: shell-safe, defensive, with few dependencies
