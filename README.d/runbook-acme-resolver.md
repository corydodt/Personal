# acme resolver vm


clone from rocky-template
ssh to acme-resolver
sudo dnf -y install wireguard-tools
sudo systemctl enable --now systemd-resolved

get acme-resolver.conf from warpspeed vpn instance
sudo cp acme-resolver.conf /etc/wireguard/
sudo systemctl enable --now wg-quick@acme-resolver
curl ifconfig.co
