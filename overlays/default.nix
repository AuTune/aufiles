{...}: {
  nixpkgs.overlays = [
    (
      self: super: {
        # patch imv to not repeat keypresses causing waybar to launch infinitely
        # https://github.com/eXeC64/imv/issues/207#issuecomment-604076888
        imv = super.imv.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or []) ++ [./imv-disable-key-repeat-timer.patch];
        });

        # add default font to silence null font errors
        lsix = super.lsix.overrideAttrs (oldAttrs: {
          postFixup = ''
            substituteInPlace $out/bin/lsix \
              --replace '#fontfamily=Mincho' 'fontfamily="JetBrainsMono-NF-Regular"'
            ${oldAttrs.postFixup}
          '';
        });

        # add icon and .desktop file
        path-of-building = super.path-of-building.overrideAttrs (oldAttrs: rec {
          # passthru =
          #   oldAttrs.passthru
          #   // oldAttrs.passthru.data.overrideAttrs (oldDataAttrs: {
          #     src = super.fetchFromGitHub {
          #       owner = "PathOfBuildingCommunity";
          #       repo = "PathOfBuilding";
          #       rev = "v2.31.2";
          #       hash = "sha256-E178uYVQ+B08h1lM7h+hwfMb08VZK+r25pD4haT1tc8=";
          #     };
          #   });

          installPhase =
            oldAttrs.installPhase
            + ''
              mkdir -p $out/share/pixmaps
              cp ${./PathOfBuilding-logo.png} $out/share/pixmaps/PathOfBuilding.png
              cp ${./PathOfBuilding-logo.svg} $out/share/pixmaps/PathOfBuilding.svg
              ln -sv "${desktopItem}/share/applications" $out/share
            '';

          desktopItem = super.makeDesktopItem {
            name = "Path of Building";
            desktopName = "Path of Building";
            comment = "Offline build planner for Path of Exile";
            exec = "pobfrontend %U";
            terminal = false;
            type = "Application";
            icon = "PathOfBuilding";
            categories = ["Game"];
            keywords = ["poe" "pob" "pobc" "path" "exile"];
            mimeTypes = ["x-scheme-handler/pob"];
          };
        });

        # creating an overlay for buildRustPackage overlay
        # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
        swww = super.swww.overrideAttrs (oldAttrs: rec {
          src = super.fetchgit {
            url = "https://github.com/Horus645/swww";
            rev = "517fbeb0f831d43d6c88dac22380536b00e7d9f1";
            sha256 = "sha256-Fx2e+UqBURY6Vxi6cePc0lK5gIEcWobMGfEx03ZOvAY=";
          };

          cargoDeps = super.rustPlatform.importCargoLock {
            lockFile = src + "/Cargo.lock";
            allowBuiltinFetchGit = true;
          };
        });

        # transmission dark mode, the default theme is hideous
        transmission = super.transmission.overrideAttrs (oldAttrs: rec {
          themeSrc =
            super.fetchzip
            {
              url = "https://git.eigenlab.org/sbiego/transmission-web-soft-theme/-/archive/master/transmission-web-soft-theme-master.tar.gz";
              sha256 = "sha256-TAelzMJ8iFUhql2CX8lhysXKvYtH+cL6BCyMcpMaS9Q=";
            };
          # sed command taken from original install.sh script
          postInstall = ''
            ${oldAttrs.postInstall}
            cp -RT ${themeSrc}/web/ $out/share/transmission/web/
            sed -i '21i\\t\t<link href="./style/transmission/soft-theme.min.css" type="text/css" rel="stylesheet" />\n\t\t<link href="style/transmission/soft-dark-theme.min.css" type="text/css" rel="stylesheet" />\n' $out/share/transmission/web/index.html;
          '';
        });

        # waybar = super.waybar.overrideAttrs (oldAttrs: rec {
        #   version = "0.9.22";

        #   # use latest waybar from git
        #   src = super.fetchgit {
        #     url = "https://github.com/Alexays/Waybar";
        #     rev = version;
        #     sha256 = "sha256-4VZG3laTs8JGtHsNQC7ka7iNF4jR0cIYzZiwx9Ilbmg=";
        #   };
        # });
      }
    )
  ];
}
