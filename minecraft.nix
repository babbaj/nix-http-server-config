{ config, pkgs, ... }: 

{
    networking.firewall.allowedTCPPorts = [ 25565 ];

    services.minecraft-server = {
        enable = true;
        package = pkgs.callPackage ./papermc.nix {};
        whitelist = {
            "Babbaj" = "8034d01d-bc3b-49e2-a6f6-29455d0a5f24";
            "Phoenix19" = "b2afba6c-b6e3-44e2-8568-e764a5c91be8";
            "fr1kin" = "21810c8f-d0e5-4cbd-bd9a-c22826b9d97a";
            "HaltAccount" = "95e980b1-e81c-4a24-80d3-d03e823cbf9c";
            "Beanzees" = "881579ba-1afe-416f-8ccc-53e1a7ccd28e";
            "SrgtScythe" = "f4ac6972-4efb-45a3-84d8-4772b2dce187";
        };
        serverProperties = {
            server-port = 25565;
            difficulty = "hard";
            gamemode = "survival";
            max-players = 5;
            motd = "NixOS Minecraft server!";
            white-list = true;
            enable-rcon = true;
            "rcon.password" = "lol";
        };
        declarative = true;
        eula = true;
    };
}
