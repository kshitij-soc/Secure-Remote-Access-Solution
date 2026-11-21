#!/usr/bin/env bash
# PROPOSED CONTROL - not validated in the lab (finding A-09).
# Moves the FORWARD chain to default-deny and re-allows only the documented paths.
# Review the variables, run on the console (not over the VPN), and keep the rollback timer.
set -euo pipefail

VPN_IF="tun0"
VPN_USER_IP="10.8.0.10"      # vpnuser fixed address (evidence T6-29)
APP_ZONE="10.10.3.10"        # app zone, TCP 8080
RDP_HOST="10.10.5.10"        # win-rdp, TCP 3389 (RDP) and 445 (SMB)

iptables-save > "/root/iptables.pre-forward-drop.$(date +%F-%H%M)"
# Auto-rollback after 120 s unless cancelled with: pkill -f 'sleep 120'
( sleep 120; iptables-restore < "$(ls -t /root/iptables.pre-forward-drop.* | head -1)" ) &

iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i "$VPN_IF" -s "$VPN_USER_IP" -d "$APP_ZONE" -p tcp --dport 8080 -j ACCEPT
iptables -A FORWARD -i "$VPN_IF" -s "$VPN_USER_IP" -d "$RDP_HOST" -p tcp -m multiport --dports 3389,445 -j ACCEPT
iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "FWD-DROP: "
iptables -P FORWARD DROP

echo "FORWARD policy is now DROP. Retest every allowed path, then cancel the rollback and save:"
echo "  pkill -f 'sleep 120' && netfilter-persistent save"
