#!/bin/bash

# ── Couleurs ───────────────────────────────────────────
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
MAGENTA=$'\033[1;35m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# ── Cadre & animation ─────────────────────────────────
W=44
FRAME_TOP="  ╔$(printf '═%.0s' $(seq 1 $((W+2))))╗"
FRAME_BOT="  ╚$(printf '═%.0s' $(seq 1 $((W+2))))╝"
GC='@#!?<>|~^░▒▓*+=' GCL=${#GC}

frame_top()    { printf '%s%s\n'   "$GREEN" "$FRAME_TOP"; }
frame_bottom() { printf '%s%s%s\n' "$GREEN" "$FRAME_BOT" "$RESET"; }
frame_line()   { local sp; printf -v sp '%*s' $(( W - ${#1} )) ''; printf '%s  ║ %s%s ║\n' "$GREEN" "$1" "$sp"; }

frame_centered() {
        local l=$(( (W - ${#1}) / 2 )) pl pr
        printf -v pl '%*s' "$l" ''; printf -v pr '%*s' $(( W - ${#1} - l )) ''
        printf '%s  ║%s%s%s%s%s  ║\n' "$GREEN" "$pl" "${2:-$GREEN}" "$1" "$GREEN" "$pr"
}

section_title() {
        local full="$1$2" l=$(( (W - ${#1} - ${#2}) / 2 )) pl pr
        printf -v pl '%*s' "$l" ''; printf -v pr '%*s' $(( W - ${#full} - l )) ''
        frame_top
        printf '%s  ║%s%s%s%s%s%s%s  ║\n' "$GREEN" "$pl" "$GREEN$BOLD" "$1" "$RESET$YELLOW" "$2" "$RESET$GREEN" "$pr"
        frame_bottom
}

# glitch $1=ligne [$2=reveal] — scramble seul ou avec révélation
glitch() {
        local line="$1" reveal="${2:-false}" len=${#1} glitched revealed ch i g r
        for ((r=0; r<2; r++)); do
                glitched=""
                for ((i=0; i<len; i++)); do
                        ch="${line:$i:1}"
                        [[ "$ch" == " " ]] && glitched+=" " || glitched+="${GC:$(( RANDOM % GCL )):1}"
                done
                printf '\r%s%s%s' "$MAGENTA" "$glitched" "$RESET"; sleep 0.02
        done
        [[ "$reveal" != "true" ]] && return
        for ((i=0; i<=len; i+=2)); do
                revealed="${GREEN}${line:0:$i}"
                if (( i < len )); then
                        revealed+="$MAGENTA"
                        for ((g=0; g < ( (len-i)<4 ? (len-i) : 4 ); g++)); do
                                ch="${line:$((i+g)):1}"
                                [[ "$ch" == " " ]] && revealed+=" " || revealed+="${GC:$(( RANDOM % GCL )):1}"
                        done
                fi
                printf '\r%s%s' "$revealed" "$RESET"; sleep 0.004
        done
        printf '\r%s%s%s\n' "$GREEN" "$line" "$RESET"
}

# ── Bannière ─────────────────────────────────────────────
BANNER_LINES=(
        ""
        "  ██████╗ ██╗ ██████╗     ███████╗██╗  ██╗"
        "  ██╔══██╗██║██╔════╝     ██╔════╝██║  ██║"
        "  ██║  ██║██║██║  ███╗ ██ ███████╗███████║"
        "  ██║  ██║██║██║   ██║    ╚════██║██╔══██║"
        "  ██████╔╝██║╚██████╔╝    ███████║██║  ██║"
        "  ╚═════╝ ╚═╝ ╚═════╝     ╚══════╝╚═╝  ╚═╝"
        ""
)

show_banner() {
        local animated="${1:-false}" ver="v2.1  " by="by Allen" sp vpad
        printf -v vpad '%*s' $(( W - ${#ver} - ${#by} )) ''

        frame_top
        for line in "${BANNER_LINES[@]}"; do
                printf -v sp '%*s' $(( W - ${#line} )) ''
                [[ "$animated" == "true" ]] && glitch "  ║ ${line}${sp} ║" true || frame_line "$line"
        done
        [[ "$animated" == "true" ]] && glitch "  ║ ${vpad}${ver}${by} ║"
        printf '\r%s  ║ %s%s%s%s%s%s ║%s\n' "$GREEN" "$vpad" "$GREEN" "$ver" "$YELLOW" "$by" "$GREEN" "$RESET"
        frame_line ""; frame_bottom; echo ""
}

# ── Menu ───────────────────────────────────────────────
show_menu() {
        echo ""
        frame_top
        frame_centered "On continue de creuser ?" "$GREEN$BOLD"
        frame_line ""
        frame_centered "[whois]    [ds]    [exit]" "$YELLOW"
        frame_line ""; frame_bottom
        printf '  %s→ Nouveau domaine ou commande :%s ' "$GREEN$BOLD" "$RESET"
}

# ── Champ dig ──────────────────────────────────────────
dig_field() { printf '\n%s  %s:%s\n' "$GREEN" "$1" "$RESET"; eval "$2"; }

# ── Navigation ─────────────────────────────────────────
prompt_menu() { show_menu; read -e c; handle_choice "$c"; }

handle_choice() {
        case "$1" in
                exit)        clear; printf '\n  %sAu revoir !%s\n\n' "$GREEN" "$RESET"; exit 0 ;;
                whois|WHOIS) printf '\n'; section_title "WHOIS : " "$domaine"; echo ""; whois "$domaine"; echo "" ;;
                ds|DS)       printf '\n'; section_title "Dig DS : " "$domaine"; echo ""; dig ds "$domaine" +short; echo "" ;;
                *)           clear; exec ./dig.sh "$1" ;;
        esac
        prompt_menu
}

# ── Lancement ──────────────────────────────────────────
clear
if [ -z "$1" ]; then
        show_banner true
        printf '  %s→ Domaine :%s ' "$GREEN$BOLD" "$RESET"
        read -e domaine
else
        domaine=$1
fi

# ── Résultats ──────────────────────────────────────────
clear; show_banner
section_title "Domaine : " "$domaine"

dig_field "Champ A"    "dig $domaine +short"
dig_field "Champ AAAA" "dig aaaa $domaine +short"
dig_field "Champ Host" "ip=\$(dig $domaine +short | head -1); host \$ip 2>/dev/null"
dig_field "Champs NS"  "dig ns $domaine +short"
dig_field "Champs MX"  "dig mx $domaine +short"
dig_field "Champs TXT" "dig txt $domaine +short"
dig_field "Champ SRV"  "dig srv _autodiscover._tcp.$domaine +short"
dig_field "Champ CAA"  "dig caa $domaine +short"

echo ""; section_title "Sous-domaine : " "www.$domaine"

dig_field "Champ A (www)"    "dig www.$domaine +short"
dig_field "Champ AAAA (www)" "dig aaaa www.$domaine +short"
dig_field "Champ Host (www)" "ip=\$(dig www.$domaine +short | head -1); host \$ip 2>/dev/null"
dig_field "Champs TXT (www)" "dig txt www.$domaine +short"

prompt_menu
