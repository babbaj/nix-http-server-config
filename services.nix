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
        };
    };

    miniserve-image = pkgs.dockerTools.buildImage {
        name = "miniserve";
        tag = "latest";

        config = {
            EntryPoint = [
                "${pkgs.miniserve}/bin/miniserve"
            ];
            Cmd = [
                "-p" "5021"
                "--index" "${./index.html}" # 404
                "/var/data"
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

        miniserve = {
            image = "miniserve";
            imageFile = miniserve-image;
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
