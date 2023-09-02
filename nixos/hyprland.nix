{
  lib,
  config,
  pkgs,
  host,
  ...
}: let
  cfg = config.iynaix-nixos.hyprland;
in {
  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.gnome.enable = lib.mkForce false;
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;
    # services.xserver.displayManager.sddm.enable = lib.mkForce true;

    # locking with swaylock
    security.pam.services.swaylock = {
      text = "auth include login";
    };

    programs.hyprland.enable = true;

    hm.wayland.windowManager.hyprland = lib.mkMerge [
      {
        enable = true;
        package = pkgs.iynaix.hyprland;
      }
      (lib.mkIf cfg.hyprnstack {
        settings.general.layout = lib.mkForce "nstack";

        # use hyprNStack plugin, the home-manager options do not seem to emit the plugin section
        plugins = [pkgs.iynaix.hyprNStack];
        extraConfig = ''
          plugin {
            nstack {
              layout {
                orientation=left
                new_is_master=0
                stacks=${toString (
            if host == "desktop"
            then 3
            else 2
          )}
                # disable smart gaps
                no_gaps_when_only=0
                # master is the same size as the stacks
                mfact=0
              }
            }
          }
        '';
      })
    ];

    environment.systemPackages = [
      pkgs.iynaix.xdg-desktop-portal-hyprland
    ];
  };
}
