{ config, pkgs, lib, ... }:

let
  cfg = config.services.guix;

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

  guixEnv = {
    ROOT_PROFILE = "/var/guix/profiles/per-user/root/current-guix";
  };
in
{
  options.services.guix = with lib; {
    enable = mkEnableOption "the guix daemon and init /gnu/store";

    group = mkOption {
      type = types.str;
      default = "guixbuild";
      example = "guixbuild";
      description = ''
        The group of the guix build users.
      '';
    };

    userPrefix = mkOption {
      type = types.str;
      default = "guixbuilder";
      example = "guixbuilder";
      description = ''
        The common prefix of the guix build users.
      '';
    };

    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [ "--max-jobs=4" "--debug" ];
      description = ''
        Extra flags to pass to the guix daemon.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.guix;
      defaultText = "pkgs.guix";
      description = ''
        The package containing the Guix daemon and command-line interface.
      '';
    };

    publish = {
      enable = mkEnableOption "publishing the guix store";

      port = mkOption {
        type = types.int;
        default = 8181;
        description = ''
          Port to publish the guix store on.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "nobody";
        description = ''
          User to publish the guix store with.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.users = guixBuildUsers 10;
    users.groups = { "${cfg.group}" = { }; };

    systemd.services.guix-daemon = {
      description = "Build daemon for GNU Guix";
      environment = guixEnv;
      path = [ cfg.package ];
      script = ''
        export GUIX_CONFIGURATION_DIRECTORY="$RUNTIME_DIRECTORY"
        export GUIX_LOCPATH="$ROOT_PROFILE/lib/locale"

        guix archive --authorize < \
          ${cfg.package}/share/guix/ci.guix.gnu.org.pub

        DAEMON="$ROOT_PROFILE/bin/guix"
        if [ ! -x "$DAEMON" ]; then
          DAEMON="${cfg.package}/bin/guix-daemon"
          export GUIX_LOCPATH="${pkgs.glibcLocales}/lib/locale"
        fi

        exec $DAEMON --build-users-group=${cfg.group} ${
          lib.escapeShellArgs cfg.extraArgs
        }
      '';
      serviceConfig = {
        ExecStartPre = ''
          ${pkgs.coreutils}/bin/mkdir -p ${lib.concatStringsSep " " (lib.attrValues guixEnv)}
        '';
        RuntimeDirectory = "guix";
        RemainAfterExit = "yes";
        StandardOutput = "syslog";
        StandardError = "syslog";
        TasksMax =
          8192; # See <https://lists.gnu.org/archive/html/guix-devel/2016-04/msg00608.html>.
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.guix-publish = lib.mkIf cfg.publish.enable {
      description = "Publish the GNU Guix store";
      environment = guixEnv;
      path = [ cfg.package ];
      script = ''
        export GUIX_CONFIGURATION_DIRECTORY="$RUNTIME_DIRECTORY"
        export GUIX_LOCPATH="$ROOT_PROFILE/lib/locale"

        guix archive --authorize < \
          ${cfg.package}/share/guix/ci.guix.gnu.org.pub

        if [ ! -x "$DAEMON" ]; then
          DAEMON="${cfg.package}/bin/guix"
          export GUIX_LOCPATH="${pkgs.glibcLocales}/lib/locale"
        fi

        exec $DAEMON publish --user=${cfg.publish.user} --port=${cfg.publish.port}
      '';
      serviceConfig = {
        ExecStartPre = ''
          ${pkgs.coreutils}/bin/mkdir -p ${lib.concatStringsSep " " (lib.attrValues guixEnv)}
        '';
        RuntimeDirectory = "guix";
        RemainAfterExit = "yes";
        StandardOutput = "syslog";
        StandardError = "syslog";
        TasksMax =
          1024; # See <https://lists.gnu.org/archive/html/guix-devel/2016-04/msg00608.html>.
      };
      wantedBy = [ "multi-user.target" ];
    };

    environment.profiles = [
      "$HOME/.config/guix/current"
      "$HOME/.guix-profile"
      "/var/guix/profiles/per-user/root/current-guix"
    ];
  };
}
