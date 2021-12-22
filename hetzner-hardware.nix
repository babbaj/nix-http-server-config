# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "bcache" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  networking.hostName = "hetzner";

  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (pkgs.linux_testing_bcachefs.override ({
                date = "2021-12-21";
                commit = "d3422f9b18ea3154abe19d859f1a61c4fae9ccdc";
                diffHash = "sha256-skXpBEpUEnXvTRCJPZsOk+393biAQh1IckevD/z1/DY=";
            })));

  fileSystems."/" =
    { device = "/dev/disk/by-id/ata-ST2000NM0033-9ZM175_Z1X0GVYB-part2:/dev/disk/by-id/ata-ST2000NM0033-9ZM175_Z1X0GVAA-part2";
      fsType = "bcachefs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-id/ata-ST2000NM0033-9ZM175_Z1X0GVYB-part1";
      fsType = "ext4";
    };

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs = {
    overlays = [
      (self: super:
        {
            bcachefs-tools = super.bcachefs-tools.overrideAttrs ({...}: {
                src = pkgs.fetchFromGitHub {
                    owner = "koverstreet";
                    repo = "bcachefs-tools";
                    rev = "00f49f23b4c37865618c74a5cb3a65308a9c511d";
                    sha256 = "sha256-77nfbW3Ww4JCOl9LaYXXqD5VhTJzyON6FDGX46rVuoQ=";
                };
            });
        })
    ];
  };
}
