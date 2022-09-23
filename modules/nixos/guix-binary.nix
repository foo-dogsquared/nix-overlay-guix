{ config, pkgs, lib, ... }:

let
  cfg = config.services.guix-binary;

  guixBuildUser = id: {
    group = cfg.group;
    extraGroups = [ cfg.group ];
    name = "${cfg.userPrefix}${toString id}";
    createHome = false;
    description = "Guix build user ${toString id}";
    isSystemUser = true;
    shell = pkgs.shadow;
  };

  guixBuildUsers = numberOfUsers:
    builtins.listToAttrs (map
      (user: {
        name = user.name;
        value = user;
      })
      (builtins.genList guixBuildUser numberOfUsers));

  # The usual list of profiles being used for the best way of integrating
  # Guix-built applications throughout the NixOS system.
  guixProfiles = [
    "$HOME/.config/guix/current"
    "$HOME/.guix-profile"
    "/var/guix/profiles/per-user/root/current-guix"
  ];
in
{
  options.services.guix-binary = with lib; {
    enable = lib.mkEnableOption
      "GNU Guix package manager with the binary installation";

    userPrefix = mkOption {
      type = types.str;
      default = "guixbuilder";
      example = "guixbuilder";
      description = "The prefix of the users for the Guix user pool.";
    };

    group = mkOption {
      type = types.str;
      default = "guixbuild";
      example = "guixbuild";
      description = ''
        The group of the Guix build user pool.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.guix_binary_1_3_0;
      defaultText = "pkgs.guix-binary_1_3_0";
      description =
        "Package that contains the binary installation files from Guix.";
    };

    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [ "--max-jobs=4" "--debug" ];
      description = "Extra arguments to be passed to the Guix daemon.";
    };

    publish = {
      enable = mkEnableOption "publishing to the Guix store";

      user = mkOption {
        type = types.str;
        default = "nobody";
        example = "guixpublish";
        description = "User to publish with 'guix publish'.";
      };

      port = mkOption {
        type = types.port;
        default = 8181;
        example = 9001;
        description = "Port to publish the Guix store.";
      };

      extraArgs = mkOption {
        type = with types; listOf str;
        description = ''
          Extra flags to pass to the substitute server.
        '';
        default = [];
        example = lib.literalExpression ''
          [ "--compression=zstd:6" "--repl" ]
        '';
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    users.users = guixBuildUsers 10;
    users.groups = { "${cfg.group}" = { }; };

    # /root/.config/guix/current/lib/systemd/system/guix-daemon.service
    systemd.services.guix-daemon = {
      enable = true;
      description = "Build daemon for GNU Guix";
      serviceConfig = {
        ExecStart =
          "/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon --build-users-group=${cfg.group} ${
            lib.escapeShellArgs cfg.extraArgs
          }";
        Environment = [
          "GUIX_LOCPATH=/var/guix/profiles/per-user/root/guix-profile/lib/locale"
          "LC_ALL=en_US.utf8"
        ];
        StandardOutput = "journal";
        StandardError = "journal";
        RemainAfterExit = "yes";

        # See <https://lists.gnu.org/archive/html/guix-devel/2016-04/msg00608.html>.
        # Some package builds (for example, go@1.8.1) may require even more than
        # 1024 tasks.
        TasksMax = "8192";
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.guix-publish = lib.mkIf cfg.publish.enable {
      description = "Publish the GNU Guix store";
      serviceConfig = {
        ExecStart = ''
          /var/guix/profiles/per-user/root/current-guix/bin/guix publish --user=${lib.escapeShellArg cfg.publish.user} --port=${lib.escapeShellArg cfg.publish.port} ${lib.escapeShellArgs cfg.publish.extraArgs}
        '';
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /gnu/store";
        RemainAfterExit = "yes";
        StandardOutput = "journal";
        StandardError = "journal";
        TasksMax =
          1024; # See <https://lists.gnu.org/archive/html/guix-devel/2016-04/msg00608.html>.
      };
      wantedBy = [ "multi-user.target" ];
    };

    system.activationScripts.guix = ''
      # copy initial /gnu/store
      if [ ! -d /gnu/store ]
      then
        mkdir -p /gnu
        cp -ra ${cfg.package.store}/gnu/store /gnu/
      fi

      # copy initial /var/guix content
      if [ ! -d /var/guix ]
      then
        mkdir -p /var
        cp -ra ${cfg.package.var}/var/guix /var/
      fi

      # root profile
      if [ ! -d ~root/.config/guix ]
      then
        mkdir -p ~root/.config/guix
        ln -sf /var/guix/profiles/per-user/root/current-guix \
          ~root/.config/guix/current
      fi

      # authorize substitutes
      GUIX_PROFILE="`echo ~root`/.config/guix/current"; \
      source $GUIX_PROFILE/etc/profile
      guix archive --authorize < ~root/.config/guix/current/share/guix/ci.guix.gnu.org.pub
      # probably enable after next stable release
      # guix archive --authorize < ~root/.config/guix/current/share/guix/bordeaux.guix.gnu.org.pub
    '';

    # GUIX_LOCPATH is basically LOCPATH but for Guix libc which in turn used by
    # virtually every Guix-built packages. This is so that Guix-installed
    # applications wouldn't use incompatible locale data and not touch its host
    # system.
    #
    # Since it is mainly used by Guix-built packages, we'll have to avoid
    # setting this variable to point to Nix-built locale data.
    environment.variables.GUIX_LOCPATH = let
      localePath = "lib/locale";
      addLocalePath = paths: lib.lists.map (path: "${path}/${localePath}") paths;
    in addLocalePath guixProfiles;

    # What Guix profiles export is very similar to Nix profiles so it is
    # acceptable to list it here. Also, it is more likely that the user would
    # want to use packages explicitly installed from Guix so we're putting it
    # first.
    environment.profiles = lib.mkBefore guixProfiles;
  };
}
