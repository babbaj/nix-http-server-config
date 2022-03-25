{ config, pkgs, gb-pr21-src, ... }:

{
  age.secrets.nitwitIp.file = ./secrets/nitwitIp.age;

  systemd.services.update-sky = 
  let
  mapcrafterConfig = pkgs.writeText "mapcrafter-config" ''
    output_dir = /tmp/mapcrafter-output

    [world:world]
    input_dir = /tmp/skyexport/world

    [map:world]
    name = SkyMasons
    world = world
    rotations = top-left top-right bottom-right bottom-left
    texture_size = 16

    [map:world_top_down]
    name = SkyMasons top down
    world = world
    render_view = topdown
    texture_size = 16
  '';

  script = pkgs.writeScript "skycache-update.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    set -x
    
    function cleanup {
        echo "Removing /tmp dirs"
        rmdir --ignore-fail-on-non-empty $skycache
        rm -r /tmp/skyexport /tmp/mapcrafter-output
    }
    trap cleanup EXIT
    rsyncargs="-rpt" # recursive, perms, time

    echo 'yay'
    dirname="skycache-$(date +%s)"
    skycache="/root/skycache/$dirname"
    mkdir $skycache

    rsync $rsyncargs -e "ssh -i /etc/ssh/ssh_host_ed25519_key" root@$(cat ${config.age.secrets.nitwitIp.path}):/opt/slave/skymason/ $skycache

    mkdir /tmp/skyexport
    echo "Running exporter with $skycache"
    sky-cache-exporter $skycache /tmp/skyexport
    
    mkdir /tmp/mapcrafter-output

    echo 'Running mapcrafter'
    time mapcrafter -c ${mapcrafterConfig} -j 4

    rsync $rsyncargs -a --delete /tmp/mapcrafter-output/ /root/skyrender/
    gb --config-file=/root/.gb.conf backup --no-database-history $skycache
  '';

  sky-exporter = pkgs.callPackage ./SkyCacheExporter.nix {};
  mapcrafter = pkgs.callPackage ./mapcrafter.nix {};
  gb-patched = pkgs.callPackage ./gb.nix { src = gb-pr21-src; };
  in {
    description = "Download chunk cache and update mapcrafter render";
    startAt = "hourly";
    path = with pkgs; [ rsync openssh mapcrafter sky-exporter gb-patched ];
    serviceConfig = {
      ExecStart = "${script}";
    };
  };
}
