{ config, pkgs, lib, ... }:

let
  cfg = config.services.guix;

  package = cfg.package.override (with cfg; { inherit stateDir storeDir; });

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

  guixEnv = rec {
    ROOT_PROFILE = "${cfg.stateDir}/profiles/per-user/root/current-guix";
    DAEMON = "${ROOT_PROFILE}/bin/guix-daemon";
    GUIX_LOCPATH = "${ROOT_PROFILE}/lib/locale";
    LC_ALL = "en_US.utf8";
  };
in
{
  options.services.guix = with lib; {
    enable = mkEnableOption "the Guix daemon service";

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

    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = [ "--max-jobs=4" "--debug" ];
      description = ''
        Extra flags to pass to the Guix daemon service.
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

    storeDir = mkOption {
      type = types.str;
      default = "/gnu/store";
      defaultText = "/gnu/store";
      description = ''
        The store directory where the Guix service will serve to/from. Take
        note Guix cannot take advantage of substitutes if you set it elsewhere
        since most of the cached builds are assumed in
        <literal>/gnu/store<literal>.

        This will also recompile the package with the specified option so you
        better have a good reason to do so.
      '';
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var";
      defaultText = "/var";
      description = ''
        The state directory where Guix service will store its data such as its
        user-specific profiles, cache, and state files.

        Changing it other than the default will rebuild the package.
      '';
      example = "/gnu/var";
    };

    publish = {
      enable = mkEnableOption "substitute server for your Guix store directory";

      port = mkOption {
        type = types.port;
        default = 8181;
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
          [ "--compression=zstd:6" "--repl" ]
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];

    users.users = guixBuildUsers 10;
    users.groups = { "${cfg.group}" = { }; };

    systemd.services.guix-daemon = {
      description = "Build daemon for GNU Guix";
      environment = guixEnv;
      script = ''
        if [ ! -x "$DAEMON" ]; then
          DAEMON="${cfg.package}/bin/guix-daemon"
          GUIX_LOCPATH="${pkgs.glibcLocales}/lib/locale"
        fi

        exec $DAEMON --build-users-group=${cfg.group} ${
          lib.escapeShellArgs cfg.extraArgs
        }
      '';
      serviceConfig = {
        RemainAfterExit = "yes";
        StandardOutput = "journal";
        StandardError = "journal";
        TasksMax =
          8192; # See <https://lists.gnu.org/archive/html/guix-devel/2016-04/msg00608.html>.
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.guix-publish = lib.mkIf cfg.publish.enable {
      description = "Publish the GNU Guix store";
      environment = guixEnv;
      script = ''
        if [ ! -x "$DAEMON" ]; then
          DAEMON="${cfg.package}/bin/guix-daemon"
          GUIX_LOCPATH="${pkgs.glibcLocales}/lib/locale"
        fi

        exec $DAEMON publish --user=${cfg.publish.user} --port=${cfg.publish.port} ${
          lib.escapeShellArgs cfg.publish.extraArgs
        }
      '';
      serviceConfig = {
        RemainAfterExit = "yes";
        StandardOutput = "journal";
        StandardError = "journal";
        TasksMax =
          1024; # See <https://lists.gnu.org/archive/html/guix-devel/2016-04/msg00608.html>.
      };
      wantedBy = [ "multi-user.target" ];
    };

    system.activationScripts.guix = ''
      ${cfg.package}/bin/guix archive --authorize < \
        ${cfg.package}/share/guix/ci.guix.gnu.org.pub
    '';

    environment.profiles = [
      "$HOME/.config/guix/current"
      "$HOME/.guix-profile"
      guixEnv.ROOT_PROFILE
    ];
  };
}
