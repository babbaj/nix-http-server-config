{
    description = "gb proxy for nixos backup";

    inputs.deploy-rs.url = "github:serokell/deploy-rs";
    inputs.agenix.url = "github:ryantm/agenix";

    outputs = { self, nixpkgs, deploy-rs, agenix }: {
        nixosConfigurations.hetzner-system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hetzner-hardware.nix ./configuration.nix agenix.nixosModules.age ];
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
