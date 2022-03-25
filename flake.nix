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

    outputs = { self, nixpkgs, deploy-rs, agenix, gb-src, gb-pr21-src }:
    {
        nixosConfigurations.hetzner-system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hetzner-hardware.nix ./configuration.nix agenix.nixosModules.age ];
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
