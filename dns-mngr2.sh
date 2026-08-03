#!/usr/bin/env bash

# ==============================================================================
# DNS-MANR (dns-mngr.sh) v1.0.0
# Cross-Platform Comprehensive DNS Manager
# Supports: Dynamic OS Guide, Auto-Backup/Restore, DoT/DoH Presets & Latency Sorting
# ==============================================================================

# Colors & Formatting
BOLD='\033[1m'
RED='\033[0;31m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BYELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Backup directory
BACKUP_DIR="${HOME}/.dns_manager_backups"
mkdir -p "$BACKUP_DIR" 2>/dev/null

# ---------------------------------------------------------------------------
# OS Detection
# ---------------------------------------------------------------------------
detect_os() {
    case "$(uname -s 2>/dev/null)" in
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*)  echo "mac" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}
OS="$(detect_os)"

if [ "$OS" == "windows" ]; then
    export MSYS_NO_PATHCONV=1
    export MSYS2_ARG_CONV_EXCL="*"
fi

# ---------------------------------------------------------------------------
# Data Arrays: Iranian DNS Providers (Anti-Sanction & Gaming)
# Format: Name | Primary IP | Secondary IP | DoT Host | DoH URL | Description
# ---------------------------------------------------------------------------
IRAN_DNS_LIST=(
"Shecan|178.22.122.100|185.51.200.2|free.shecan.ir|https://free.shecan.ir/dns-query|General anti-sanction & anti-filtering DNS"
"Begzar|185.55.226.26|185.55.225.25|dns.begzar.ir|https://dns.begzar.ir/dns-query|Anti-sanction for web browsing & gaming"
"Radar Game|10.202.10.10|10.202.10.11|dns.radargame.ir|https://dns.radargame.ir/dns-query|Low latency DNS optimized for online gaming"
"403 Online|10.202.10.202|10.202.10.102|dns.403.online|https://dns.403.online/dns-query|Specialized for developers & tech sanctions bypass"
"Electro|78.157.42.100|78.157.42.101|dns.elctro.ir|https://elctro.ir/dns-query|Anti-sanction for software updates & gaming"
"Vanilla|194.146.68.68|194.146.68.66|dns.vanillapp.ir|https://dns.vanillapp.ir/dns-query|Anti-sanction DNS by Vanilla App"
"Shelter|94.103.125.157|94.103.125.158|-|-|Gaming specialized DNS service"
"Beshkan|181.41.194.177|181.41.194.186|free.beshkanapp.ir|-|Anti-sanction DNS service"
"Pishgaman|5.202.100.100|5.202.100.101|-|-|Pishgaman ISP DNS server"
"HostIran|172.29.0.100|172.29.0.200|dns.hostiran.net|https://dns.hostiran.net/dns-query|HostIran public DNS service"
"Shatel|85.15.1.14|85.15.1.15|-|-|Shatel ISP DNS server"
"DNS Pro|10.202.10.100|10.202.10.101|dns.dnspro.ir|https://dns.dnspro.ir/dns-query|Anti-sanction DNS service"
"Server.ir|193.105.234.12|193.105.234.13|-|-|Server.ir public DNS"
"PPro|185.231.182.126|185.231.182.127|-|-|Anti-sanction DNS service"
"Gamer DNS|10.202.10.20|10.202.10.21|-|-|Gaming DNS service"
"Asiatech|194.225.70.30|194.225.70.40|-|-|Asiatech ISP DNS server"
"Level 15|10.10.10.10|10.10.10.11|-|-|Low ping domestic DNS"
)

# ---------------------------------------------------------------------------
# Data Arrays: Global & International DNS Providers
# Format: Name | Primary IP | Secondary IP | DoT Host | DoH URL | Description
# ---------------------------------------------------------------------------
GLOBAL_DNS_LIST=(
"Cloudflare|1.1.1.1|1.0.0.1|cloudflare-dns.com|https://cloudflare-dns.com/dns-query|Ultra-fast global DNS, high privacy & speed"
"Google Public DNS|8.8.8.8|8.8.4.4|dns.google|https://dns.google/dns-query|Highly stable & reliable global DNS"
"Quad9|9.9.9.9|149.112.112.112|dns.quad9.net|https://dns.quad9.net/dns-query|High security & malicious site blocking"
"OpenDNS (Cisco)|208.67.222.222|208.67.220.220|dns.opendns.com|https://doh.opendns.com/dns-query|Excellent reliability & download speed boost"
"NextDNS|45.90.28.190|45.90.30.190|dns.nextdns.io|https://dns.nextdns.io|Customizable security & anti-tracking DNS"
"AdGuard DNS|94.140.14.14|94.140.15.15|dns.adguard.com|https://dns.adguard.com/dns-query|Blocks ads, trackers & phishing sites"
"Level3 / UltraDNS|209.244.0.3|209.244.0.4|-|-|Great for large file downloads & network stability"
"Comodo Secure DNS|8.26.56.26|8.20.247.20|-|-|Additional security layer against malware"
"NTT DNS|129.250.35.250|129.250.35.251|-|-|Good download speeds on specific regional ISPs"
"CleanBrowsing|185.228.168.9|185.228.169.9|security-filter-dns.cleanbrowsing.org|https://doh.cleanbrowsing.org/doh/security-filter/|Filters malicious & adult content"
"Alternate DNS|76.76.19.19|76.223.122.150|-|-|Lightweight ad-blocking DNS"
"SafeDNS|195.46.39.39|195.46.39.40|-|-|Smart web filtering & security"
"UncensoredDNS|91.239.100.100|89.233.43.71|unicast.censurfridns.dk|https://doh.censurfridns.dk/dns-query|Uncensored & privacy-focused DNS (Denmark)"
"DNS.WATCH|84.200.69.80|84.200.70.40|resolv.dns.watch|-|Fast, no-logs DNS server"
"Verisign|64.6.64.6|64.6.65.6|-|-|High availability & secure infrastructure DNS"
"Neustar|156.154.70.1|156.154.71.1|-|-|Enterprise-grade DNS for large downloads"
"OpenNIC|94.16.114.254|94.247.43.254|-|-|Open & decentralized DNS network"
"FreeDNS|45.33.97.5|37.235.1.177|-|-|Public & unrestricted DNS"
"Yandex.DNS|77.88.8.8|77.88.8.1|common.dns.yandex.ru|https://common.dns.yandex.ru/dns-query|Servers located close to Middle East/Europe"
)

# ---------------------------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------------------------
read_input() {
    local prompt="$1"
    local var_name="$2"
    if [ -t 0 ]; then
        read -rp "$prompt" "$var_name"
    else
        read -rp "$prompt" "$var_name" < /dev/tty
    fi
}

pause_screen() {
    echo ""
    read_input "Press [Enter] to continue..." unused
}

print_banner() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    echo "  ██████╗ ███╗   ██╗███████╗    ███╗   ███╗ █████╗ ███╗   ██╗██████╗ "
    echo "  ██╔══██╗████╗  ██║██╔════╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗"
    echo "  ██║  ██║██╔██╗ ██║███████╗    ██╔████╔██║███████║██╔██╗ ██║██████╔╝"
    echo "  ██║  ██║██║╚██╗██║╚════██║    ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██╗"
    echo "  ██████╔╝██║ ╚████║███████║    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║"
    echo "  ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${BOLD}         --- DNS-MANR (dns-mngr.sh) v1.0.0 ---${NC}"
    echo -e "                 Detected OS: ${CYAN}${OS}${NC}"
    echo "  ------------------------------------------------------------------"
    echo ""
}

run_quiet() {
    local desc="$1"; shift
    local output status
    output=$("$@" 2>&1)
    status=$?
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}[✓] ${desc}${NC}"
    else
        echo -e "${RED}[×] ${desc} — failed.${NC}"
        if [ -n "$output" ]; then
            echo -e "${RED}    $(echo "$output" | head -n 3 | tr '\n' ' ')${NC}"
        fi
    fi
    return $status
}

get_ping_ms() {
    local target_ip="$1"
    local res=""
    if [ "$OS" == "windows" ]; then
        res=$(ping -n 1 -w 1000 "$target_ip" 2>/dev/null | grep -iE "time[=<]" | awk '{print $5}' | tr -d 'ms')
    else
        res=$(ping -c 1 -W 1 "$target_ip" 2>/dev/null | grep -iE "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
    fi

    if [ -n "$res" ]; then
        printf "%.0f" "$res" 2>/dev/null || echo "9999"
    else
        echo "9999"
    fi
}

lookup_dns_name() {
    local ip="$1"
    local COMBINED_LIST=("${IRAN_DNS_LIST[@]}" "${GLOBAL_DNS_LIST[@]}")
    for entry in "${COMBINED_LIST[@]}"; do
        IFS='|' read -r name primary secondary _ _ _ <<< "$entry"
        if [ "$ip" == "$primary" ] || [ "$ip" == "$secondary" ]; then
            echo "$name"
            return
        fi
    done
    echo ""
}

format_dns_display() {
    local dns="$1"
    if [ -z "$dns" ]; then
        echo -e "${GREEN}Not set ${BYELLOW}(Automatic DNS / DHCP)${NC}"
        return
    fi
    local first_ip="${dns%%[, ]*}"
    local provider
    provider=$(lookup_dns_name "$first_ip")
    if [ -n "$provider" ]; then
        echo -e "${YELLOW}${dns}  ${BYELLOW}(${provider})${NC}"
    else
        echo -e "${YELLOW}${dns}  ${BYELLOW}(Custom / Unknown)${NC}"
    fi
}

print_manual_notes() {
    echo -e "${CYAN}💡 Manual Configuration Note for ${BOLD}${OS}${NC}${CYAN}:${NC}"
    case "$OS" in
        windows)
            echo -e "   ${BLUE}Control Panel / Settings -> Network & Internet -> Wi-Fi/Ethernet -> Edit DNS IP assignment.${NC}\n"
            ;;
        mac)
            echo -e "   ${BLUE}System Settings -> Network -> Select Interface -> Advanced -> DNS tab.${NC}\n"
            ;;
        linux|wsl)
            echo -e "   ${BLUE}Edit /etc/resolv.conf or via NetworkManager GUI / nmcli connection editor.${NC}\n"
            ;;
    esac
}

print_network_entry() {
    local name="$1" status_colored="$2" dns_display="$3"
    printf "  ${YELLOW}%-16s${NC} %b\n" "Interface Name:" "${BOLD}${name}${NC}"
    printf "  ${YELLOW}%-16s${NC} %b\n" "Status:" "${status_colored}"
    printf "  ${YELLOW}%-16s${NC} %b\n" "Current DNS:" "${dns_display}"
    echo "  ------------------------------------------------------------------"
}

show_current_dns() {
    echo -e "${YELLOW}[ Active Networks & Current DNS ]${NC}\n"
    case "$OS" in
        linux|wsl)
            if command -v nmcli >/dev/null 2>&1; then
                local found=0
                while IFS=: read -r dev dtype state con; do
                    [ -z "$dev" ] && continue
                    [ "$dtype" == "loopback" ] && continue
                    found=1
                    local status_colored
                    [ "$state" == "connected" ] && status_colored="${GREEN}Connected${NC}" || status_colored="${RED}Disconnected${NC}"
                    local display_name="${con:-$dev}"
                    [ "$display_name" == "--" ] && display_name="$dev"
                    local dns=""
                    [ -n "$con" ] && [ "$con" != "--" ] && dns=$(nmcli -g ipv4.dns connection show "$con" 2>/dev/null)
                    print_network_entry "$display_name" "$status_colored" "$(format_dns_display "$dns")"
                done < <(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status)
                [ "$found" -eq 0 ] && echo -e "${RED}No network interfaces found.${NC}"
            else
                echo -e "${BLUE}DNS (/etc/resolv.conf):${NC}"
                cat /etc/resolv.conf 2>/dev/null || echo -e "${RED}resolv.conf not found${NC}"
            fi
            ;;
        mac)
            while IFS= read -r service; do
                [ -z "$service" ] && continue
                local info ip_line ip_val status_colored
                info=$(networksetup -getinfo "$service" 2>/dev/null)
                ip_line=$(echo "$info" | grep -m1 "^IP address:")
                ip_val=$(echo "$ip_line" | awk -F': ' '{print $2}' | xargs)
                [ -z "$ip_val" ] || [ "$ip_val" == "none" ] && status_colored="${RED}Disconnected${NC}" || status_colored="${GREEN}Connected${NC}"
                local dns_raw dns_joined
                dns_raw=$(networksetup -getdnsservers "$service" 2>/dev/null)
                [[ "$dns_raw" == *"aren't any"* || -z "$dns_raw" ]] && dns_joined="" || dns_joined=$(echo "$dns_raw" | tr '\n' ' ' | xargs)
                print_network_entry "$service" "$status_colored" "$(format_dns_display "$dns_joined")"
            done < <(networksetup -listallnetworkservices | tail -n +2)
            ;;
        windows)
            local found=0
            while IFS= read -r line; do
                local iface_state name
                iface_state=$(echo "$line" | awk '{print $2}')
                name=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i}' | sed 's/[[:space:]]*$//')
                [ -z "$name" ] && continue
                found=1
                [ "$iface_state" == "Connected" ] && status_colored="${GREEN}Connected${NC}" || status_colored="${RED}Disconnected${NC}"
                local dns_out dns_joined=""
                dns_out=$(netsh interface ipv4 show dnsservers name="$name" 2>&1)
                if echo "$dns_out" | grep -qi "Statically Configured"; then
                    dns_joined=$(echo "$dns_out" | awk '/DNS Servers:/{flag=1} /Register/{flag=0} flag' \
                        | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | paste -sd' ' -)
                fi
                print_network_entry "$name" "$status_colored" "$(format_dns_display "$dns_joined")"
            done < <(netsh interface show interface | tail -n +4)
            [ "$found" -eq 0 ] && echo -e "${RED}No network interfaces found.${NC}"
            ;;
    esac
}

display_table_list() {
    local title="$1"
    shift
    local list=("$@")
    echo -e "${YELLOW}[ ${title} ]${NC}\n"
    local i=1
    for entry in "${list[@]}"; do
        IFS='|' read -r name primary secondary dot_dom doh_url notes <<< "$entry"
        echo -e "  ${CYAN}$(printf "%2d" $i))${NC} ${BOLD}$(printf "%-22s" "$name")${NC} Primary: ${GREEN}$(printf "%-15s" "$primary")${NC} Sec: ${GREEN}$(printf "%-15s" "${secondary:--}")${NC}"
        if [ "$dot_dom" != "-" ] || [ "$doh_url" != "-" ]; then
            echo -e "      ${MAGENTA}DoT:${NC} ${dot_dom:-N/A}  |  ${MAGENTA}DoH:${NC} ${doh_url:-N/A}"
        fi
        echo -e "      ${BLUE}${notes}${NC}\n"
        i=$((i+1))
    done
}

get_networks_with_info() {
    NETWORKS=()
    NETWORKS_INFO=()
    case "$OS" in
        linux|wsl)
            if command -v nmcli >/dev/null 2>&1; then
                while IFS= read -r line; do
                    [ -z "$line" ] && continue
                    NETWORKS+=("$line")
                    local dns
                    dns=$(nmcli -g ipv4.dns connection show "$line" 2>/dev/null)
                    if [ -n "$dns" ]; then
                        local prov
                        prov=$(lookup_dns_name "${dns%%[, ]*}")
                        NETWORKS_INFO+=("${YELLOW}${dns}${prov:+ ($prov)}${NC}")
                    else
                        NETWORKS_INFO+=("${GREEN}Automatic ${BYELLOW}(DHCP)${NC}")
                    fi
                done < <(nmcli -t -f NAME connection show)
            fi

            if [ "${#NETWORKS[@]}" -eq 0 ]; then
                NETWORKS+=("System Default (/etc/resolv.conf)")
                NETWORKS_INFO+=("${YELLOW}Direct Config File${NC}")
            fi
            ;;
        mac)
            while IFS= read -r service; do
                [ -z "$service" ] && continue
                NETWORKS+=("$service")
                local dns_raw
                dns_raw=$(networksetup -getdnsservers "$service" 2>/dev/null)
                if [[ "$dns_raw" == *"aren't any"* || -z "$dns_raw" ]]; then
                    NETWORKS_INFO+=("${GREEN}Automatic ${BYELLOW}(DHCP)${NC}")
                else
                    local dns_joined
                    dns_joined=$(echo "$dns_raw" | tr '\n' ' ' | xargs)
                    local prov
                    prov=$(lookup_dns_name "${dns_joined%%[, ]*}")
                    NETWORKS_INFO+=("${YELLOW}${dns_joined}${prov:+ ($prov)}${NC}")
                fi
            done < <(networksetup -listallnetworkservices | tail -n +2)
            ;;
        windows)
            while IFS= read -r line; do
                name=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i}' | sed 's/[[:space:]]*$//')
                [ -z "$name" ] && continue
                NETWORKS+=("$name")
                local dns_out
                dns_out=$(netsh interface ipv4 show dnsservers name="$name" 2>&1)
                if echo "$dns_out" | grep -qi "Statically Configured"; then
                    local dns_joined
                    dns_joined=$(echo "$dns_out" | awk '/DNS Servers:/{flag=1} /Register/{flag=0} flag' \
                        | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | paste -sd' ' -)
                    local prov
                    prov=$(lookup_dns_name "${dns_joined%%[, ]*}")
                    NETWORKS_INFO+=("${YELLOW}${dns_joined}${prov:+ ($prov)}${NC}")
                else
                    NETWORKS_INFO+=("${GREEN}Automatic ${BYELLOW}(DHCP)${NC}")
                fi
            done < <(netsh interface show interface | tail -n +4)
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Backup & Restore Logic
# ---------------------------------------------------------------------------
backup_dns_state() {
    local net_name="$1"
    local safe_name
    safe_name=$(echo "$net_name" | tr -cd 'a-zA-Z0-9_-')
    local bfile="${BACKUP_DIR}/dns_${safe_name}.bak"

    case "$OS" in
        linux|wsl)
            if command -v nmcli >/dev/null 2>&1 && [ "$net_name" != "System Default (/etc/resolv.conf)" ]; then
                local current_dns
                current_dns=$(nmcli -g ipv4.dns connection show "$net_name" 2>/dev/null)
                echo "NMCLI|${net_name}|${current_dns}" > "$bfile"
            else
                [ -f /etc/resolv.conf ] && cp /etc/resolv.conf "${bfile}_resolv"
                echo "FILE|/etc/resolv.conf" > "$bfile"
            fi
            ;;
        mac)
            local current_dns
            current_dns=$(networksetup -getdnsservers "$net_name" 2>/dev/null)
            echo "MAC|${net_name}|${current_dns}" > "$bfile"
            ;;
        windows)
            local dns_out
            dns_out=$(netsh interface ipv4 show dnsservers name="$net_name" 2>&1)
            echo "WIN|${net_name}|${dns_out}" > "$bfile"
            ;;
    esac
    echo -e "${GREEN}[✓] Backup snapshot created for '${net_name}'${NC}"
}

restore_dns_state() {
    print_banner
    echo -e "${YELLOW}[ Restore DNS Configuration from Backup ]${NC}\n"
    local backups=("$BACKUP_DIR"/dns_*.bak)
    if [ ! -e "${backups[0]}" ]; then
        echo -e "${RED}[!] No backup files found.${NC}"
        pause_screen
        return
    fi

    local i=1
    local file_list=()
    for b in "${BACKUP_DIR}"/dns_*.bak; do
        [ -f "$b" ] || continue
        file_list+=("$b")
        local fname
        fname=$(basename "$b")
        echo -e "  ${CYAN}${i})${NC} Backup File: ${BOLD}${fname}${NC}"
        i=$((i+1))
    done
    echo -e "  ${BRED}0) Return to Main Menu${NC}"
    echo ""
    read_input "Select backup to restore [0-$((i-1))]: " rsel
    if ! [[ "$rsel" =~ ^[0-9]+$ ]] || [ "$rsel" -eq 0 ] || (( rsel < 1 || rsel > ${#file_list[@]} )); then
        return
    fi

    local selected_file="${file_list[$((rsel-1))]}"
    IFS='|' read -r type target_net data < "$selected_file"

    echo ""
    case "$type" in
        NMCLI)
            local cur_before
            cur_before=$(nmcli -g ipv4.dns connection show "$target_net" 2>/dev/null)
            [ -z "$cur_before" ] && cur_before="DHCP"
            local target_after="${data:-DHCP}"

            echo -e "${CYAN}Restoring '${target_net}'...${NC}"
            echo -e "  ${RED}Previous State:${NC} ${cur_before}"
            echo -e "  ${GREEN}Restoring To:${NC}     ${target_after}\n"

            if [ -z "$data" ]; then
                run_quiet "Restored '${target_net}' to DHCP" bash -c "sudo nmcli connection modify '$target_net' ipv4.ignore-auto-dns no && sudo nmcli connection modify '$target_net' ipv4.dns '' && sudo nmcli connection up '$target_net'"
            else
                run_quiet "Restored '${target_net}' to static DNS" bash -c "sudo nmcli connection modify '$target_net' ipv4.dns '$data' && sudo nmcli connection up '$target_net'"
            fi
            ;;
        FILE)
            echo -e "${CYAN}Restoring /etc/resolv.conf file backup...${NC}"
            if [ -f "${selected_file}_resolv" ]; then
                run_quiet "Restored /etc/resolv.conf content" sudo cp "${selected_file}_resolv" /etc/resolv.conf
            fi
            ;;
        MAC)
            local cur_before
            cur_before=$(networksetup -getdnsservers "$target_net" 2>/dev/null | tr '\n' ' ')
            [[ "$cur_before" == *"aren't any"* || -z "$cur_before" ]] && cur_before="DHCP"
            local target_after="${data:-DHCP}"

            echo -e "${CYAN}Restoring macOS interface '${target_net}'...${NC}"
            echo -e "  ${RED}Previous State:${NC} ${cur_before}"
            echo -e "  ${GREEN}Restoring To:${NC}     ${target_after}\n"

            if [[ "$data" == *"aren't any"* || -z "$data" ]]; then
                run_quiet "Restored '${target_net}' to DHCP" sudo networksetup -setdnsservers "$target_net" empty
            else
                run_quiet "Restored '${target_net}' to static DNS" sudo networksetup -setdnsservers "$target_net" $data
            fi
            ;;
        WIN)
            echo -e "${CYAN}Restoring Windows interface '${target_net}'...${NC}"
            if echo "$data" | grep -qi "Statically Configured"; then
                local ips
                ips=$(echo "$data" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
                local primary=$(echo "$ips" | head -n 1)
                echo -e "  ${GREEN}Restoring To:${NC} Static IP ($primary)\n"
                run_quiet "Restored Windows Static DNS" netsh interface ipv4 set dnsservers name="$target_net" source=static address="$primary"
            else
                echo -e "  ${GREEN}Restoring To:${NC} Automatic (DHCP)\n"
                run_quiet "Restored Windows DHCP" netsh interface ipv4 set dnsservers name="$target_net" source=dhcp
            fi
            ;;
    esac
    pause_screen
}

# ---------------------------------------------------------------------------
# DoT / DoH Configuration (OS-Specific Guide & Universal List)
# ---------------------------------------------------------------------------
action_configure_dot_doh() {
    print_banner
    echo -e "${YELLOW}[ Secure DNS: DoT (DNS over TLS) / DoH (DNS over HTTPS) ]${NC}\n"

    # 1. OS-Specific Manual Instructions
    echo -e "${CYAN}💡 Manual Configuration Guide for ${BOLD}${OS}${NC}${CYAN}:${NC}"
    case "$OS" in
        windows)
            echo -e "  * ${BOLD}Windows 11:${NC} Settings -> Network & Internet -> Wi-Fi/Ethernet -> Edit DNS -> Select 'Encrypted (DoH)'."
            echo -e "  * ${BOLD}Browsers:${NC} Open Chrome/Firefox/Edge settings -> Privacy & Security -> Enable 'Use Secure DNS' and paste DoH URL."
            ;;
        mac)
            echo -e "  * ${BOLD}macOS System-wide:${NC} Requires installing a signed ${YELLOW}.mobileconfig${NC} profile for DoT/DoH."
            echo -e "  * ${BOLD}Browsers:${NC} Open Chrome/Firefox/Edge settings -> Privacy & Security -> Enable 'Use Secure DNS' and paste DoH URL."
            ;;
        linux|wsl)
            echo -e "  * ${BOLD}Linux System-wide:${NC} Handled via systemd-resolved (${BLUE}/etc/systemd/resolved.conf.d/${NC}) or stub resolver."
            echo -e "  * ${BOLD}Browsers:${NC} Open Chrome/Firefox/Edge settings -> Privacy & Security -> Enable 'Use Secure DNS' and paste DoH URL."
            ;;
        *)
            echo -e "  * ${BOLD}Browsers:${NC} Open Chrome/Firefox/Edge settings -> Privacy & Security -> Enable 'Use Secure DNS' and paste DoH URL."
            ;;
    esac
    echo "  ------------------------------------------------------------------"
    echo ""

    # 2. Automated status check
    local auto_supported=0
    if [ "$OS" == "linux" ] && command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        auto_supported=1
        echo -e "${GREEN}[✓] Automated DoT configuration is supported on this system (systemd-resolved).${NC}\n"
    else
        echo -e "${BYELLOW}[!] Automated OS-level DoT/DoH is not supported natively for ${OS}.${NC}"
        echo -e "${BLUE}    Please select a server below to view its details for manual setup in Settings/Browser:${NC}\n"
    fi

    # 3. Collect & Display DoT/DoH enabled servers
    local COMBINED_LIST=("${IRAN_DNS_LIST[@]}" "${GLOBAL_DNS_LIST[@]}")
    local dot_presets=()

    for entry in "${COMBINED_LIST[@]}"; do
        IFS='|' read -r name primary secondary dot_dom doh_url notes <<< "$entry"
        if [ -n "$dot_dom" ] && [ "$dot_dom" != "-" ]; then
            dot_presets+=("${entry}")
        fi
    done

    echo -e "${BOLD}Available Secure DNS Presets (DoT / DoH):${NC}\n"
    local i=1
    for p in "${dot_presets[@]}"; do
        IFS='|' read -r name primary _ dot_dom doh_url _ <<< "$p"
        echo -e "  ${CYAN}$(printf "%2d" $i))${NC} ${BOLD}$(printf "%-18s" "$name")${NC} IP: ${GREEN}$(printf "%-15s" "$primary")${NC}"
        echo -e "      ${MAGENTA}DoT Host:${NC} ${dot_dom:-N/A}"
        echo -e "      ${MAGENTA}DoH URL :${NC} ${doh_url:-N/A}\n"
        i=$((i+1))
    done

    if [ "$auto_supported" -eq 1 ]; then
        echo -e "  ${CYAN}$(printf "%2d" $i))${NC} ${BYELLOW}Custom (Enter IP and Hostname manually)${NC}"
    fi
    echo -e "  ${BRED} 0) Return to Main Menu${NC}"
    echo ""

    read_input "Select option [0-${i}]: " dot_choice
    if ! [[ "$dot_choice" =~ ^[0-9]+$ ]] || [ "$dot_choice" -eq 0 ] || (( dot_choice > i )); then
        return
    fi

    if [ "$auto_supported" -eq 1 ]; then
        local dot_ip=""
        local dot_host=""

        if [ "$dot_choice" -eq "$i" ]; then
            echo ""
            read_input "Enter DoT Server IP (e.g. 1.1.1.1): " dot_ip
            read_input "Enter DoT Hostname (e.g. cloudflare-dns.com): " dot_host
        else
            local sel_preset="${dot_presets[$((dot_choice-1))]}"
            IFS='|' read -r _ dot_ip _ dot_host _ _ <<< "$sel_preset"
        fi

        if [ -n "$dot_ip" ] && [ -n "$dot_host" ]; then
            echo ""
            local conf="/etc/systemd/resolved.conf.d/dot.conf"
            sudo mkdir -p /etc/systemd/resolved.conf.d/
            echo -e "[Resolve]\nDNS=${dot_ip}#${dot_host}\nDNSOverTLS=yes" | sudo tee "$conf" >/dev/null
            run_quiet "Enabled DoT in systemd-resolved (${dot_ip}#${dot_host})" sudo systemctl restart systemd-resolved
        fi
    else
        if [ "$dot_choice" -ge 1 ] && [ "$dot_choice" -lt "$i" ]; then
            local sel_preset="${dot_presets[$((dot_choice-1))]}"
            IFS='|' read -r name primary secondary dot_dom doh_url _ <<< "$sel_preset"
            print_banner
            echo -e "${YELLOW}[ Details for Manual Configuration: ${BOLD}${name}${NC}${YELLOW} ]${NC}\n"
            echo -e "  ${BOLD}Primary IP :${NC} ${GREEN}${primary}${NC}"
            echo -e "  ${BOLD}Secondary IP:${NC} ${GREEN}${secondary:--}${NC}"
            echo -e "  ${BOLD}DoT Hostname:${NC} ${MAGENTA}${dot_dom}${NC}"
            echo -e "  ${BOLD}DoH URL     :${NC} ${MAGENTA}${doh_url}${NC}"
            echo ""
            echo -e "${CYAN}Copy the DoH URL or DoT Host above and paste it into your ${OS} system settings or browser DNS settings.${NC}"
        fi
    fi

    pause_screen
}

select_option_with_info() {
    local prompt=$1
    echo -e "${BOLD}${prompt}${NC}\n"
    local i=1
    for idx in "${!NETWORKS[@]}"; do
        echo -e "  ${CYAN}${i})${NC} ${BOLD}${NETWORKS[$idx]}${NC} -> Current: ${NETWORKS_INFO[$idx]}"
        i=$((i+1))
    done
    echo -e "  ${BRED}0) Cancel / Return${NC}"
    echo ""
    read_input "Select an option [0-$((i-1))]: " sel
    if ! [[ "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -eq 0 ] || (( sel < 1 || sel > ${#NETWORKS[@]} )); then
        echo -e "\n${YELLOW}[!] Cancelled.${NC}"
        SELECTED_INDEX=-1
        SELECTED_VALUE=""
        return 1
    fi
    SELECTED_INDEX=$((sel-1))
    SELECTED_VALUE="${NETWORKS[$SELECTED_INDEX]}"
    return 0
}

select_dns_from_category() {
    echo -e "${BOLD}Choose DNS Category:${NC}\n"
    echo -e "  ${CYAN}1)${NC} Iranian ${BYELLOW}(Anti-Sanction & Gaming)${NC}"
    echo -e "  ${CYAN}2)${NC} Global ${BYELLOW}(International & Security)${NC}"
    echo -e "  ${BRED}0) Cancel / Return${NC}"
    echo ""
    read_input "Select category [0-2]: " cat_choice

    local TARGET_ARRAY=()
    case "$cat_choice" in
        1) TARGET_ARRAY=("${IRAN_DNS_LIST[@]}") ;;
        2) TARGET_ARRAY=("${GLOBAL_DNS_LIST[@]}") ;;
        *) return 1 ;;
    esac

    print_banner
    echo -e "${YELLOW}[ Testing Latency & Sorting DNS Servers... Please Wait ]${NC}\n"

    local temp_list=()
    for entry in "${TARGET_ARRAY[@]}"; do
        IFS='|' read -r name primary _ _ _ _ <<< "$entry"
        local ms
        ms=$(get_ping_ms "$primary")
        temp_list+=("${ms}|${entry}")
    done

    IFS=$'\n' sorted_temp=($(sort -n -t'|' -k1 <<<"${temp_list[*]}"))
    unset IFS

    print_banner
    echo -e "${BOLD}Select a DNS provider ${BYELLOW}(Sorted by Lowest Latency)${NC}:\n"
    local SORTED_ARRAY=()
    local i=1
    for item in "${sorted_temp[@]}"; do
        local ms="${item%%|*}"
        local entry="${item#*|}"
        SORTED_ARRAY+=("$entry")

        IFS='|' read -r name primary secondary _ _ notes <<< "$entry"
        local ping_disp
        if [ "$ms" -eq 9999 ]; then
            ping_disp="${RED}Timeout${NC}"
        else
            ping_disp="${GREEN}${ms} ms${NC}"
        fi

        echo -e "  ${CYAN}$(printf "%2d" $i))${NC} ${BOLD}$(printf "%-22s" "$name")${NC} IP: ${GREEN}$(printf "%-15s" "$primary")${NC} Ping: [${ping_disp}]"
        i=$((i+1))
    done
    echo -e "  ${BRED} 0) Cancel / Return${NC}"
    echo ""
    read_input "Select an option [0-${#SORTED_ARRAY[@]}]: " sel
    if ! [[ "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -eq 0 ] || (( sel < 1 || sel > ${#SORTED_ARRAY[@]} )); then
        echo -e "\n${YELLOW}[!] Cancelled.${NC}"
        SELECTED_DNS_NAME=""
        return 1
    fi
    IFS='|' read -r SELECTED_DNS_NAME SELECTED_DNS_PRIMARY SELECTED_DNS_SECONDARY _ _ _ <<< "${SORTED_ARRAY[$((sel-1))]}"
    return 0
}

flush_dns_action() {
    case "$OS" in
        linux|wsl)
            if command -v resolvectl >/dev/null 2>&1; then
                run_quiet "DNS cache flushed (resolvectl)" sudo resolvectl flush-caches
            elif command -v systemd-resolve >/dev/null 2>&1; then
                run_quiet "DNS cache flushed (systemd-resolve)" sudo systemd-resolve --flush-caches
            elif systemctl list-units --type=service 2>/dev/null 2>&1 | grep -q nscd; then
                run_quiet "DNS cache flushed (nscd)" sudo systemctl restart nscd
            else
                echo -e "${RED}[!] Caching resolver not found, cache clear skipped.${NC}"
            fi
            ;;
        mac)
            run_quiet "DNS cache flushed (dscacheutil)" bash -c "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
            ;;
        windows)
            run_quiet "DNS cache flushed (ipconfig /flushdns)" ipconfig /flushdns
            ;;
    esac
}

offer_flush() {
    echo ""
    read_input "Flush system DNS cache now? [y/N]: " ans
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
        echo ""
        flush_dns_action
    fi
}

action_set_dns() {
    while true; do
        print_banner
        echo -e "${YELLOW}[ Set DNS — Step 1: Select Network Interface ]${NC}\n"
        print_manual_notes

        get_networks_with_info
        if [ "${#NETWORKS[@]}" -eq 0 ]; then
            echo -e "${RED}[!] No network interfaces found.${NC}"
            pause_screen
            return
        fi

        select_option_with_info "Select the network/interface to configure:" || return
        local network="$SELECTED_VALUE"

        backup_dns_state "$network"

        print_banner
        echo -e "${YELLOW}[ Set DNS — Step 2: Select DNS Provider ]${NC}"
        echo -e "Target Interface: ${BOLD}${network}${NC}\n"
        select_dns_from_category
        if [ $? -ne 0 ]; then
            sleep 1
            continue
        fi

        print_banner
        echo -e "${YELLOW}[ Set DNS — Confirmation ]${NC}\n"
        echo -e "  Interface:  ${BOLD}${network}${NC}"
        echo -e "  Provider:   ${BOLD}${SELECTED_DNS_NAME}${NC}"
        echo -e "  Primary IP: ${GREEN}${SELECTED_DNS_PRIMARY}${NC}"
        echo -e "  Secondary:  ${GREEN}${SELECTED_DNS_SECONDARY:--}${NC}"
        echo ""
        read_input "Apply this DNS? [y/N]: " confirm
        [[ "$confirm" != "y" && "$confirm" != "Y" ]] && { echo -e "\n${YELLOW}[!] Cancelled.${NC}"; pause_screen; return; }
        echo ""

        case "$OS" in
            linux|wsl)
                if command -v nmcli >/dev/null 2>&1 && [ "$network" != "System Default (/etc/resolv.conf)" ]; then
                    local q_net q_dns
                    q_net=$(printf %q "$network")
                    q_dns=$(printf %q "${SELECTED_DNS_PRIMARY} ${SELECTED_DNS_SECONDARY}")
                    run_quiet "DNS set on '${network}'" \
                        bash -c "sudo nmcli connection modify $q_net ipv4.dns $q_dns && sudo nmcli connection modify $q_net ipv4.ignore-auto-dns yes && sudo nmcli connection up $q_net"
                else
                    run_quiet "DNS written to /etc/resolv.conf" \
                        sudo bash -c "echo 'nameserver ${SELECTED_DNS_PRIMARY}' > /etc/resolv.conf && [ -n '${SELECTED_DNS_SECONDARY}' ] && echo 'nameserver ${SELECTED_DNS_SECONDARY}' >> /etc/resolv.conf"
                fi
                ;;
            mac)
                if [ -n "$SELECTED_DNS_SECONDARY" ]; then
                    run_quiet "DNS set on '${network}'" sudo networksetup -setdnsservers "$network" "$SELECTED_DNS_PRIMARY" "$SELECTED_DNS_SECONDARY"
                else
                    run_quiet "DNS set on '${network}'" sudo networksetup -setdnsservers "$network" "$SELECTED_DNS_PRIMARY"
                fi
                ;;
            windows)
                run_quiet "Primary DNS applied to '${network}'" \
                    netsh interface ipv4 set dnsservers name="$network" source=static address="$SELECTED_DNS_PRIMARY" register=primary validate=no
                if [ -n "$SELECTED_DNS_SECONDARY" ] && [ "$SELECTED_DNS_SECONDARY" != "-" ]; then
                    run_quiet "Secondary DNS applied to '${network}'" \
                        netsh interface ipv4 add dnsservers name="$network" address="$SELECTED_DNS_SECONDARY" index=2 validate=no
                fi
                ;;
        esac

        offer_flush
        pause_screen
        return
    done
}

action_unset_dns() {
    print_banner
    echo -e "${YELLOW}[ Unset DNS — Revert to Automatic DHCP ]${NC}\n"
    print_manual_notes

    get_networks_with_info
    if [ "${#NETWORKS[@]}" -eq 0 ]; then
        echo -e "${RED}[!] No network interfaces found.${NC}"
        pause_screen
        return
    fi

    select_option_with_info "Select network to reset back to DHCP:" || return
    local network="$SELECTED_VALUE"

    backup_dns_state "$network"

    echo ""
    read_input "Revert '${network}' back to DHCP? [y/N]: " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && { echo -e "\n${YELLOW}[!] Cancelled.${NC}"; pause_screen; return; }
    echo ""

    case "$OS" in
        linux|wsl)
            if command -v nmcli >/dev/null 2>&1 && [ "$network" != "System Default (/etc/resolv.conf)" ]; then
                local q_net=$(printf %q "$network")
                run_quiet "Reset '${network}' to DHCP" \
                    bash -c "sudo nmcli connection modify $q_net ipv4.ignore-auto-dns no && sudo nmcli connection modify $q_net ipv4.dns '' && sudo nmcli connection up $q_net"
            else
                echo -e "${YELLOW}[!] Manual cleanup required for /etc/resolv.conf if not managed by NetworkManager.${NC}"
            fi
            ;;
        mac)
            run_quiet "Reset '${network}' to DHCP" sudo networksetup -setdnsservers "$network" empty
            ;;
        windows)
            run_quiet "Reset '${network}' to DHCP" netsh interface ipv4 set dnsservers name="$network" source=dhcp
            ;;
    esac

    offer_flush
    pause_screen
}

benchmark_dns_servers() {
    print_banner
    echo -e "${YELLOW}[ DNS Latency Benchmark / Ping Test ]${NC}\n"
    echo -e "Testing response time of all Primary DNS IPs...\n"
    printf "  %-22s %-18s %-12s\n" "Provider Name" "Primary IP" "Latency"
    echo "  ------------------------------------------------------------"

    local COMBINED_LIST=("${IRAN_DNS_LIST[@]}" "${GLOBAL_DNS_LIST[@]}")
    for entry in "${COMBINED_LIST[@]}"; do
        IFS='|' read -r name primary _ _ _ _ <<< "$entry"
        local ms
        ms=$(get_ping_ms "$primary")
        if [ "$ms" -ne 9999 ]; then
            printf "  %-22s %-18s ${GREEN}%s ms${NC}\n" "$name" "$primary" "$ms"
        else
            printf "  %-22s %-18s ${RED}Timeout / Blocked${NC}\n" "$name" "$primary"
        fi
    done
    pause_screen
}

menu_view_dns() {
    while true; do
        print_banner
        echo -e "${YELLOW}[ View Supported DNS Providers ]${NC}\n"
        echo -e "  ${CYAN}1)${NC} View Iranian DNS Servers ${BYELLOW}(Anti-Sanction & Gaming)${NC}"
        echo -e "  ${CYAN}2)${NC} View Global DNS Servers ${BYELLOW}(International & Security)${NC}"
        echo -e "  ${BRED}0) Return to Main Menu${NC}"
        echo ""
        read_input "Select option [0-2]: " vchoice
        case "$vchoice" in
            1) print_banner; display_table_list "Iranian DNS Providers" "${IRAN_DNS_LIST[@]}"; pause_screen ;;
            2) print_banner; display_table_list "Global DNS Providers" "${GLOBAL_DNS_LIST[@]}"; pause_screen ;;
            0) return ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}

menu_change_dns() {
    while true; do
        print_banner
        echo -e "${YELLOW}[ Change DNS Configuration ]${NC}\n"
        echo -e "  ${CYAN}1)${NC} Set DNS ${BYELLOW}(Select and Apply)${NC}"
        echo -e "  ${CYAN}2)${NC} Unset DNS ${BYELLOW}(Revert to Automatic DHCP)${NC}"
        echo -e "  ${BRED}0) Return to Main Menu${NC}"
        echo ""
        read_input "Select option [0-2]: " sub_choice
        case "$sub_choice" in
            1) action_set_dns ;;
            2) action_unset_dns ;;
            0) return ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}
 
main_menu() {
    while true; do
        print_banner
        echo -e "${BOLD}Main Menu — Select an option:${NC}\n"
        echo -e "  ${CYAN}1)${NC} Show active networks & current active DNS"
        echo -e "  ${CYAN}2)${NC} Browse DNS Database ${BYELLOW}(Iranian Anti-Sanction & Global Lists)${NC}"
        echo -e "  ${CYAN}3)${NC} Change DNS Configuration ${BYELLOW}(Set / Unset DNS)${NC}"
        echo -e "  ${CYAN}4)${NC} Restore DNS from Backup ${BYELLOW}(Rollback Changes)${NC}"
        echo -e "  ${CYAN}5)${NC} Configure DoT / DoH ${BYELLOW}(Encrypted DNS Settings)${NC}"
        echo -e "  ${CYAN}6)${NC} Run DNS Latency Benchmark ${BYELLOW}(Find fastest DNS)${NC}"
        echo -e "  ${CYAN}7)${NC} Refresh Network & Flush DNS Cache"
        echo -e "  ${BRED}0) Exit${NC}"
        echo ""
        read_input "Select option [0-7]: " choice
        echo ""
        case "$choice" in
            1) show_current_dns; pause_screen ;;
            2) menu_view_dns ;;
            3) menu_change_dns ;;
            4) restore_dns_state ;;
            5) action_configure_dot_doh ;;
            6) benchmark_dns_servers ;;
            7) flush_dns_action; pause_screen ;;
            0) echo -e "\n${YELLOW}Exiting. Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}

main_menu