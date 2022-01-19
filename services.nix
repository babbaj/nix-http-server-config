{ config, pkgs, ... }: 


let
    # I'm only running this in docker for security lol
    gb-image = pkgs.dockerTools.buildImage {
        name = "gb-proxy";
        tag = "latest";

        config = {
            Env = [
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
            EntryPoint = [
                "${pkgs.gb-backup}/bin/gb"
            ];
            Cmd = [
                "-database-file" "/opt/gb/.gb.db"
                "proxy"
                "-label" "nixos backblaze"
                "-base" "/"
                "-listen" "0.0.0.0:7893"
            ];
        };
    };

    goserve-image = pkgs.dockerTools.buildImage {
        name = "goserve";
        tag = "latest";

        config = {
            EntryPoint = [
                "${pkgs.callPackage ./go-serve.nix {}}/bin/serve"
            ];
            Cmd = [
               "-d" "/var/data"
            ];
            Volumes = {
                "/tmp" = {};
            };
        };
    };
in
{
    #virtualisation.docker.enable = true;

    age.secrets.piaLoginEnv.file = ./secrets/piaLoginEnv.age;
    
    #virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = {
        gb-proxy = {
            image = "gb-proxy";
            imageFile = gb-image;
            autoStart = true;
            volumes = [
                "/opt/gb:/opt/gb"
            ];
            # apparently ExposedPorts does nothing
            ports = [
                "127.0.0.1:7893:7893"
            ];
        };

        miniserve-404 = {
            image = "svenstaro/miniserve";
            autoStart = true;
            volumes = [
                "${./index.html}:/index.html"
            ];
            cmd = [
                "/index.html"
            ];
            ports = [
                "127.0.0.1:404:8080"
            ];
        };

        go-serve = {
            image = "goserve";
            imageFile = goserve-image;
            autoStart = true;
            volumes = [
                "/root/public:/var/data"
            ];
            ports = [
                "127.0.0.1:5021:8100"
            ];
        };

        qbittorrent = {
            image = "guillaumedsde/alpine-qbittorrent-openvpn";
            autoStart = true;
            volumes = [
                "/torrents:/downloads"
                "/root/qbittorrent_config:/config"
            ];
            ports = [
                "127.0.0.1:6969:8080"
            ];

            extraOptions = [ "--cap-add=NET_ADMIN" ];
            environment = {
                OPENVPN_PROVIDER = "PIA";
                OPENVPN_CONFIG = "de_frankfurt";
                LAN = "192.168.70.0/24"; # wireguard
                PUID = "1000";
                PGID = "1000";
            };
            environmentFiles = [
                config.age.secrets.piaLoginEnv.path
            ];
        };
        
        miniserve-torrents = {
            image = "svenstaro/miniserve";
            autoStart = true;
            volumes = [
                "/torrents:/data"
            ];
            cmd = [
                "/data"
            ];
            ports = [
                "127.0.0.1:2222:8080"
            ];
        };

        miniserve-skyrender = {
            image = "svenstaro/miniserve";
            autoStart = true;
            volumes = [
                "/root/skyrender:/data"
            ];
            cmd = [
                "--index" "index.html"
                "/data"
            ];
            ports = [
                "127.0.0.1:2147:8080"
            ];
        };
    };
}
