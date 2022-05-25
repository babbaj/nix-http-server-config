{
    description = "gb proxy for nixos backup";

    inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    inputs.deploy-rs.url = "github:serokell/deploy-rs";
    inputs.agenix.url = "github:ryantm/agenix";
    inputs.gb-src = {
        url = "github:leijurv/gb";
        flake = false;
    };
    inputs.gb-pr21-src = {
        url = "github:leijurv/gb?ref=pull/21/head";
        flake = false;
    };
    inputs.home-manager.url = "github:nix-community/home-manager";
    inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
    inputs.nixos-config.url = "github:babbaj/nix-config";

    outputs = { self, nixpkgs, deploy-rs, agenix, gb-src, gb-pr21-src, home-manager, nixos-config }:
    let
        home-module = {
            home-manager = {
                users.root = {
                    imports = [
                        # TODO: organize these into "shell config" list
                        "${nixos-config}/home/zsh.nix"
                        "${nixos-config}/home/bash.nix"
                        "${nixos-config}/home/fzf.nix"
                        "${nixos-config}/home/htop.nix"
                        "${nixos-config}/home/starship.nix"
                        "${nixos-config}/home/zoxide.nix"
                    ];
                };
                useUserPackages = true;
                useGlobalPkgs = true;
                verbose = true;
            };
        };

        pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
        nixosConfigurations.hetzner-system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./hetzner-hardware.nix
                ./configuration.nix
                agenix.nixosModules.age
                home-manager.nixosModules.home-manager
                home-module
            ];
            inherit pkgs;
            specialArgs = {
                inherit gb-src;
                inherit gb-pr21-src;
            };
        };

        deploy.nodes.hetzner-dedicated = {
            hostname = "h";
            autoRollback = true;

            profiles.main = {
                sshUser = "root";
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hetzner-system;
            };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
