{
    description = "gb proxy for nixos backup";

    inputs.deploy-rs.url = "github:serokell/deploy-rs";
    inputs.agenix.url = "github:ryantm/agenix";

    outputs = { self, nixpkgs, deploy-rs, agenix }: {
        nixosConfigurations.gb-ovh-system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./configuration.nix agenix.nixosModules.age ];
        };

        deploy.nodes.ovh-vps = {
            hostname = "ovh";#"135.148.149.216";
            autoRollback = true;

            profiles.test = {
                sshUser = "root";
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.gb-ovh-system;
            };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
