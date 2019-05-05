#!/bin/sh

PATH='/sbin'

lan='192.168.0.0/24'

# Flush the tables to apply changes
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
iptables -X

# Default policy to drop everything but our output to internet
iptables -P FORWARD DROP
iptables -P INPUT   DROP
iptables -P OUTPUT  ACCEPT

# Allow established connections (the responses to our outgoing traffic)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Autorise traffic sur interface locale lo
iptables -A INPUT -i lo -j ACCEPT

# Accepter le protocole ICMP (notamment le ping) depuis le lan
iptables -A INPUT -s $lan -p icmp -j ACCEPT

# Autorise acces ssh sur port 22 depuis le lan
iptables -A INPUT -s $lan -p tcp --dport 22 -m state --state NEW -j ACCEPT

# Regles de protection complementaires
# DROP paquets autres que SYN
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
# DROP paquets invalides
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
# DROP paquets incomplets
iptables -A INPUT -f -j DROP
# DROP NULL
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# DROP XMAS
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
# DROP SYNFIN
iptables -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP
# DROP FIN scan
iptables -A INPUT -p tcp --tcp-flags ALL FIN -j DROP
# DROP SYN RST
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
# DROP NMAP XMAS
iptables -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j DROP
# DROP NMAP
iptables -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j DROP
# DROP SYN FLOOD
iptables -N SYN-FLOOD
iptables -A SYN-FLOOD -m limit --limit 1/sec --limit-burst 4 -j RETURN
iptables -A SYN-FLOOD -j DROP
# DROP port scans
iptables -N PORT-SCAN
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j PORT-SCAN
iptables -A PORT-SCAN -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A PORT-SCAN -j DROP

# Logging des paquets entrants droppes (acces via dmesg)
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 3/hour -j LOG --log-prefix "IPTABLES_DROP: " --log-level 7
iptables -A LOGGING -j DROP
