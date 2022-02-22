{ config, pkgs, ... }: 

{
    services.minecraft-server = {
        enable = true;
        package = pkgs.papermc;
        whitelist = {
            "Babbaj" = "8034d01d-bc3b-49e2-a6f6-29455d0a5f24";
            "Phoenix19" = "b2afba6c-b6e3-44e2-8568-e764a5c91be8";
            "fr1kin" = "21810c8f-d0e5-4cbd-bd9a-c22826b9d97a";
            "HaltAccount" = "95e980b1-e81c-4a24-80d3-d03e823cbf9c";
        };
        openFirewall = true;
        serverProperties = {
            server-port = 25565;
            difficulty = "hard";
            gamemode = "survival";
            max-players = 5;
            motd = "NixOS Minecraft server!";
            white-list = true;
            enable-rcon = true;
            "rcon.password" = "yay!";
        };
        declarative = true;
        eula = true;
    };
}
