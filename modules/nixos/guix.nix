{ config, pkgs, lib, ... }:

let
  cfg = config.services.guix;

  package = cfg.package.override { inherit (cfg) stateDir storeDir; };

  guixBuildUser = id: {
    group = cfg.group;
    name = "${cfg.userPrefix}${toString id}";
    createHome = false;
    description = "Guix build user ${toString id}";
    isSystemUser = true;
  };

  guixBuildUsers = numberOfUsers:
    builtins.listToAttrs (map
      (user: {
        name = user.name;
        value = user;
      })
      (builtins.genList guixBuildUser numberOfUsers));

  guixEnv = rec {
    ROOT_PROFILE = "${cfg.stateDir}/guix/profiles/per-user/root/current-guix";
    DAEMON = "${ROOT_PROFILE}/bin/guix-daemon";
    GUIX = "${ROOT_PROFILE}/bin/guix";
    GUIX_LOCPATH = "${ROOT_PROFILE}/lib/locale";
    LC_ALL = "en_US.utf8";
  };

  # The usual list of profiles being used for the best way of integrating
  # Guix-built applications throughout the NixOS system. Take note it is sorted
  # starting with the profile with the most precedence.
  guixProfiles = [
    "$HOME/.config/guix/current"
    "$HOME/.guix-profile"
    guixEnv.ROOT_PROFILE
  ];
in
{
  options.services.guix = with lib; {
    enable = mkEnableOption "Guix build daemon service";

    group = mkOption {
      type = types.str;
      default = "guixbuild";
      example = "guixbuild";
      description = ''
        The group of the Guix build user pool.
      '';
    };

    userPrefix = mkOption {
      type = types.str;
      default = "guixbuilder";
      example = "guixbuilder";
      description = ''
        The name prefix for the Guix build user pool.
      '';
    };

    nrBuildUsers = mkOption {
      type = types.int;
      description = ''
        Number of Guix build users to be used in the build pool.
      '';
      default = 10;
      example = 20;
    };

    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [ "--max-jobs=4" "--debug" ];
      description = ''
        Extra flags to pass to the Guix daemon service.
      '';
    };

    package = mkPackageOption pkgs "guix" {
      extraDescription = ''
        It should contain {command}`guix-daemon` and {command}`guix` executable.
      '';
    };

    storeDir = mkOption {
      type = types.str;
      default = "/gnu/store";
      defaultText = "/gnu/store";
      description = ''
        The store directory where the Guix service will serve to/from. Take
        note Guix cannot take advantage of substitutes if you set it other than
        {path}`/gnu/store` since most of the cached builds are
        assumed in there.

        ::: {.warning}
        This will also recompile the package with the specified option so you
        better have a good reason to change it.
        :::
      '';
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var";
      defaultText = "/var";
      description = ''
        The state directory where Guix service will store its data such as its
        user-specific profiles, cache, and state files.

        ::: {.warning}
        Changing it other than the default will rebuild the package.
        :::
      '';
      example = "/gnu/var";
    };

    publish = {
      enable = mkEnableOption "substitute server for your Guix store directory";

      port = mkOption {
        type = types.port;
        default = 8181;
        example = 8200;
        description = ''
          Port of the substitute server to listen to.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "nobody";
        defaultText = "nobody";
        description = ''
          Name of the user to change once the server is up.
        '';
      };

      extraArgs = mkOption {
        type = with types; listOf str;
        description = ''
          Extra flags to pass to the substitute server.
        '';
        default = [];
        example = lib.literalExpression ''
          [ "--compression=zstd:6" "--repl" "--discover=no" ]
        '';
      };
    };

    gc = {
      enable = mkEnableOption "automatic garbage collection service for Guix";

      extraFlags = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = ''
          List of arguments to be passed to {command}`guix gc`.
        '';
        example = [ ];
      };

      dates = lib.mkOption {
        type = types.str;
        default = "03:15";
        example = "weekly";
        description = ''
          How often the garbage collection occurs. This takes the time format
          as indicated from {manpage}`systemd.time(7)`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = [ package ];

      # Building the user pool for Guix.
      users.users = guixBuildUsers cfg.nrBuildUsers;
      users.groups."${cfg.group}" = { };

      systemd.packages = [ package ];

      # This is to be enabled with their respective submodules.
      systemd.services.guix-gc.enable = false;
      systemd.services.guix-publish.enable = false;

      # From this point, the script for services involving activating the Guix
      # daemon will more likely use the daemon from the Guix root profile which
      # is present after doing an update (i.e., 'guix pull'). Otherwise, we'll
      # just use the daemon from the derivation.
      systemd.services.guix-daemon = {
        environment = guixEnv;
        script = ''
          ${lib.getExe' package "guix-daemon"} --build-users-group=${cfg.group} ${
            lib.escapeShellArgs cfg.extraArgs
          }
        '';
        serviceConfig = {
          RemainAfterExit = "yes";
          StandardOutput = "journal";
          StandardError = "journal";
        };
      };

      # This is based from Nix daemon socket unit from upstream Nix package.
      # Guix build daemon has support for systemd-style socket activation.
      systemd.sockets.guix-daemon = {
        description = "Guix daemon socket";
        before = [ "multi-user.target" ];
        listenStreams = [ "${cfg.stateDir}/guix/daemon-socket/socket" ];
        unitConfig = {
          RequiresMountsFor = cfg.storeDir;
          ConditionPathIsReadWrite = "${cfg.stateDir}/guix/daemon-socket";
        };
        wantedBy = [ "socket.target" ];
      };

      # This is to make Guix profiles always be activated at user boot
      # including Guix home env if you REALLY want to. For now, it only
      # activates the default Guix user profile, the `current-guix` profile
      # (from user mode `guix pull`), and Guix home profile. This has the
      # potential to be configurable but we'll stick with the defaults.
      #
      # Whatever else is on the users' discretion. If a user wants to get rid
      # any of the profiles for whatever reason, those profiles have to be
      # garbage-collected.
      #
      # For more information, see the `activate-guix-profile.scm` script.
      systemd.user.services.guix-profiles-activation = {
      };

      # Make transferring files from one store to another easier with the usual
      # case being of most substitutes from the official Guix CI instance.
      system.activationScripts.guix = ''
        ${lib.getExe' package "guix"} archive --authorize < \
          ${package}/share/guix/ci.guix.gnu.org.pub
      '';

      # GUIX_LOCPATH is basically LOCPATH but for Guix libc which in turn used by
      # virtually every Guix-built packages. This is so that Guix-installed
      # applications wouldn't use incompatible locale data and not touch its host
      # system.
      #
      # Since it is mainly used by Guix-built packages, we'll have to avoid
      # setting this variable to point to Nix-built locale data.
      environment.sessionVariables.GUIX_LOCPATH = lib.makeSearchPath "lib/locale" guixProfiles;

      # What Guix profiles export is very similar to Nix profiles so it is
      # acceptable to list it here. Also, it is more likely that the user would
      # want to use packages explicitly installed from Guix so we're putting it
      # first.
      environment.profiles = lib.mkBefore guixProfiles;
    }

    (lib.mkIf cfg.publish.enable {
      systemd.services.guix-publish = {
        enable = true;
        script = ''
          ${lib.getExe' package "guix"} publish --user=${cfg.publish.user} --port=${cfg.publish.port} ${
            lib.escapeShellArgs cfg.publish.extraArgs
          }
        '';
        serviceConfig = {
          RemainAfterExit = "yes";
          StandardOutput = "journal";
          StandardError = "journal";
        };
      };
    })

    (lib.mkIf cfg.gc.enable {
      systemd.services.guix-gc = {
        enable = true;
        startAt = cfg.gc.dates;
        script = ''
          ${lib.getExe' package "guix"} gc ${lib.escapeShellArgs cfg.gc.extraArgs}
        '';
      };
    })
  ]);
}
