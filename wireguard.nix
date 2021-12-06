{ config, pkgs, ... }: 

{
    networking.wireguard.enable = true;

    age.secrets.wgKey.file = ./secrets/wgKey.age;

    networking.firewall.allowedUDPPorts = [ 14031 ];
    #networking.firewall.trustedInterfaces = [ "wg0" ];
    
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
                {
                    allowedIPs = [ "192.168.70.89/32" ];
                    publicKey = "8FpQH1M5vygIPM0jno0upHczJBgL8gue3JgXW2djTgk=";
                }
            ];
        };
    };
}
