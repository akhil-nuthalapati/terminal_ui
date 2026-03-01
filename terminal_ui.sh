#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.config/terminal_customax"
STYLE_FILE="$CONFIG_DIR/style.sh"
BANNER_FILE="$CONFIG_DIR/banner.sh"
mkdir -p "$CONFIG_DIR"

CURRENT_SHELL="$(basename "$SHELL")"

case "$CURRENT_SHELL" in
    bash) RC_FILE="$HOME/.bashrc" ;;
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    *) echo "Unsupported shell"; exit 1 ;;
esac

MARK_BEGIN="# >>> TERMINAL_CUSTOMAX >>>"
MARK_END="# <<< TERMINAL_CUSTOMAX <<<"

pause() { read -rp "Press Enter to return to menu..."; }

show_palette() {
    for i in {0..255}; do
        printf "\033[38;5;%sm %3s \033[0m" "$i" "$i"
        (( (i+1)%16 == 0 )) && echo
    done
    echo
}

welcome() {
    clear
    printf "\033[38;5;46m\033[1m"
    figlet -f slant "WELCOME"
    printf "\033[0m\n"
    echo "crafted by : N_AKHIL_CSE-F [1/4]"
    echo
}

inject_loader() {

    sed -i "/$MARK_BEGIN/,/$MARK_END/d" "$RC_FILE"

    cat >> "$RC_FILE" <<EOF

$MARK_BEGIN
if [ -f "$STYLE_FILE" ]; then
    source "$STYLE_FILE"
fi

if [ -f "$BANNER_FILE" ]; then
    bash "$BANNER_FILE"
fi
$MARK_END
EOF
}

configure_style() {

    show_palette
    read -rp "Foreground color: " FG
    read -rp "Background color: " BG
    read -rp "Bold? (yes/no): " BOLD

    if [[ "$CURRENT_SHELL" == "bash" ]]; then

        cat > "$STYLE_FILE" <<EOF
PS1="\[\033[38;5;${FG}m\]\[\033[48;5;${BG}m\]$( [[ "$BOLD" == "yes" ]] && echo '\[\033[1m\]' )\u@\h:\w\\$ \[\033[0m\]"
EOF

    else

cat > "$STYLE_FILE" <<EOF
autoload -Uz add-zsh-hook

set_custom_prompt() {
    PROMPT=\$'%{\e[38;5;${FG}m%}%{\e[48;5;${BG}m%}$( [[ "$BOLD" == "yes" ]] && echo '%{\e[1m%}' )%n@%m:%~ %# %{\e[0m%}'
}

add-zsh-hook precmd set_custom_prompt
EOF

    fi

    inject_loader

    echo
    echo "Style saved."
    echo "Open a NEW terminal to see full effect."
    echo

    pause
}

generate_banner() {

    read -rp "Enter banner text: " TEXT

    mapfile -t FONTS < <(ls /usr/share/figlet/*.flf | xargs -n1 basename | sed 's/.flf//')

    echo
    echo "Fonts Preview (first 10):"
    for i in {0..9}; do
        echo "[$i] ${FONTS[$i]}"
        figlet -f "${FONTS[$i]}" "Sample"
        echo
    done

    read -rp "Select font number: " INDEX
    FONT="${FONTS[$INDEX]}"

    echo
    echo "1) Single Color"
    echo "2) Gradient"
    read -rp "Mode: " MODE

    if [[ "$MODE" == "2" ]]; then

        echo
        figlet -f "$FONT" "$TEXT" | lolcat -p 1 -F 0.2
        echo
        read -rp "Confirm save? (yes/no): " CONFIRM
        [[ "$CONFIRM" != "yes" ]] && return

        cat > "$BANNER_FILE" <<EOF
figlet -f ${FONT} "${TEXT}" | lolcat -p 1 -F 0.2
EOF

    else

        show_palette
        read -rp "Color: " COLOR

        echo
        printf "\033[38;5;%sm" "$COLOR"
        figlet -f "$FONT" "$TEXT"
        printf "\033[0m\n"

        read -rp "Confirm save? (yes/no): " CONFIRM
        [[ "$CONFIRM" != "yes" ]] && return

        cat > "$BANNER_FILE" <<EOF
printf "\\033[38;5;${COLOR}m"
figlet -f ${FONT} "${TEXT}"
printf "\\033[0m"
EOF
    fi

    inject_loader

    echo
    echo "Banner saved. Appears every new terminal."
    echo

    pause
}

reset_all() {
    rm -f "$STYLE_FILE" "$BANNER_FILE"
    sed -i "/$MARK_BEGIN/,/$MARK_END/d" "$RC_FILE"
    echo "Reset complete."
    pause
}

while true; do
    welcome
    echo "1) Configure Terminal Style"
    echo "2) Generate Persistent Banner"
    echo "3) Reset Everything"
    echo "4) Exit"
    echo
    read -rp "Select: " opt

    case "$opt" in
        1) configure_style ;;
        2) generate_banner ;;
        3) reset_all ;;
        4)
            echo
            echo "crafted by : N_AKHIL_CSE-F [1/4]"
            exit 0 ;;
        *) echo "Invalid"; sleep 1 ;;
    esac
done