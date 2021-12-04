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
                "-base" "/home/babbaj/Pictures"
                "-listen" "0.0.0.0:7893"
            ];
            # doesn't actually do anything
            Volumes = {
                "/opt/gb/" = {};
            };
        };
    };

    simple-http-image = pkgs.dockerTools.buildImage {
        name = "simple-http";
        tag = "latest";

        config = {
            EntryPoint = [
                "${pkgs.python3}/bin/python3"
            ];
            Cmd = [
                "-m" "http.server"
                "--directory" "/var/data"
                "5021"
            ];
        };
    };

in
{
    virtualisation.docker.enable = true;

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
                "7893:7893"
            ];
        };

        simple-http = {
            image = "simple-http";
            imageFile = simple-http-image;
            autoStart = true;
            volumes = [
                "/root/public:/var/data"
            ];
            ports = [
                "5021:5021"
            ];
        };
    };

}
