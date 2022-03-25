{ config, pkgs, gb-src, ... }: {
  nixpkgs = {
    overlays = [
      (self: super: {
        gb-backup = pkgs.callPackage ./gb.nix { src = gb-src; };
      })
    ];
  };


  environment.systemPackages = with pkgs; [ 
    gb-backup
  ];
}
