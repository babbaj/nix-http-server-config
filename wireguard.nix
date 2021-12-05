{ config, pkgs, ... }: 

{
    networking.wireguard.enable = true;

    age.secrets.wgKey.file = ./secrets/wgKey.age;

    networking.firewall.allowedUDPPorts = [ 14031 ];
    
    networking.wireguard.interfaces = {
        wg0 = {
            ips = [ "192.168.70.1/32" ];
            listenPort = 14031;
            privateKeyFile = config.age.secrets.wgKey.path;

            postSetup = ''
                ${pkgs.iptables}/bin/iptables -A FORWARD -i %i -j ACCEPT; ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
             '';

            # This undoes the above command
            postShutdown = ''
                ${pkgs.iptables}/bin/iptables -D FORWARD -i %i -j ACCEPT; ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE
            '';

            peers = [
                {
                    allowedIPs = [ "192.168.70.88/32" ];
                    publicKey = "Q8yPJ7BxP796QeSRgBhm12aVbIi/Upyf5NxntH8bC3A=";
                }
            ];
        };
    };
}
