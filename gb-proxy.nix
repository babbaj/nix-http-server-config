{ config, pkgs, ... }: {
  nixpkgs = {
    overlays = [ 
      (self: super: { 
        gb-backup = pkgs.callPackage ./gb.nix {}; 
      }) 
    ];
  };


  environment.systemPackages = with pkgs; [ gb-backup ];
}
