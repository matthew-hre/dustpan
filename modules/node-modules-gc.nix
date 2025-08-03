{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.nodeModules.gc;

  pruneScript = pkgs.writeShellScriptBin "node-modules-gc" ''
    SEARCH_DIRS=(${concatStringsSep " " cfg.directories})
    for dir in "''${SEARCH_DIRS[@]}"; do
      echo "Pruning in: $dir"
      find "$dir" -type d -name "node_modules" -prune -mtime +${toString cfg.olderThanDays} \
        -print -exec rm -rf {} +
    done
  '';
in {
  options.services.nodeModules.gc = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic cleanup of old node_modules folders";
    };

    directories = mkOption {
      type = types.listOf types.str;
      default = ["$HOME/projects" "$HOME/Projects" "$HOME/dev"];
      description = "Directories to search for node_modules folders";
    };

    olderThanDays = mkOption {
      type = types.int;
      default = 30;
      description = "Remove node_modules folders older than this many days";
    };

    frequency = mkOption {
      type = types.str;
      default = "weekly";
      description = "systemd timer OnCalendar value";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pruneScript];

    systemd.user.timers.node-modules-gc = {
      Unit.Description = "Scheduled cleanup of node_modules folders";
      Timer.OnCalendar = cfg.frequency;
      Timer.Persistent = true;
      Install.WantedBy = ["timers.target"];
    };

    systemd.user.services.node-modules-gc = {
      Unit.Description = "Run node_modules pruning";
      Service.ExecStart = "${pruneScript}/bin/node-modules-gc";
    };
  };
}
