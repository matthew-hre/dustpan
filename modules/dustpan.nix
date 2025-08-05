{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.dustpan;

  pruneScript = pkgs.writeShellScriptBin "dustpan" ''
    SEARCH_DIRS=(${concatStringsSep " " cfg.directories})
    FOLDERS_TO_CLEAN=(${concatStringsSep " " cfg.foldersToClean})
    
    for dir in "''${SEARCH_DIRS[@]}"; do
      echo "Pruning in: $dir"
      for folder in "''${FOLDERS_TO_CLEAN[@]}"; do
        echo "  Looking for $folder folders..."
        find "$dir" -type d -name "$folder" -prune -mtime +${toString cfg.olderThanDays} \
          -print -exec rm -rf {} +
      done
    done
  '';
in {
  options.services.dustpan = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic cleanup of old build/dependency folders";
    };

    directories = mkOption {
      type = types.listOf types.str;
      default = ["$HOME/projects" "$HOME/Projects" "$HOME/dev"];
      description = "Directories to search for folders to clean";
    };

    foldersToClean = mkOption {
      type = types.listOf types.str;
      default = ["node_modules"];
      description = "Names of folders to clean up (e.g., node_modules, __pycache__, target, .cache)";
    };

    olderThanDays = mkOption {
      type = types.int;
      default = 30;
      description = "Remove folders older than this many days";
    };

    frequency = mkOption {
      type = types.str;
      default = "weekly";
      description = "systemd timer OnCalendar value";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pruneScript];

    systemd.user.timers.dustpan = {
      Unit.Description = "Scheduled cleanup of build/dependency folders";
      Timer.OnCalendar = cfg.frequency;
      Timer.Persistent = true;
      Install.WantedBy = ["timers.target"];
    };

    systemd.user.services.dustpan = {
      Unit.Description = "Run build/dependency folder pruning";
      Service.ExecStart = "${pruneScript}/bin/dustpan";
    };
  };
}
