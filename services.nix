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

        miniserve-404 = {
            image = "miniserve";
            autoStart = true;
            volumes = [
                "${./index.html}:/index.html"
            ];
            cmd = [
                "/index.html"
            ];
            ports = [
                "404:8080"
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
                "5021:8100"
            ];
        };
    };
}
