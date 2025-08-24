{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.dustpan;

  pruneScript = pkgs.writeShellScriptBin "dustpan" ''
    ROOTS=(${concatStringsSep " " cfg.roots})
    TARGETS=(${concatStringsSep " " cfg.targets})

    for dir in "''${ROOTS[@]}"; do
      echo "Pruning in: $dir"
      for folder in "''${TARGETS[@]}"; do
        echo "  Looking for $folder folders..."
        find "$dir" -type d -name "$folder" -prune -mtime +${toString cfg.olderThanDays} \
          -print -exec rm -rf {} +
      done
    done
  '';
in {
  imports = [
    (lib.mkRenamedOptionModule
      ["services" "dustpan" "directories"]
      ["services" "dustpan" "roots"])
    (lib.mkRenamedOptionModule
      ["services" "dustpan" "foldersToClean"]
      ["services" "dustpan" "targets"])
  ];

  options.services.dustpan = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic cleanup of old build/dependency folders";
    };

    roots = mkOption {
      type = types.listOf types.str;
      default = ["$HOME/projects" "$HOME/Projects" "$HOME/dev"];
      description = "Root directories to search within.";
    };

    targets = mkOption {
      type = types.listOf types.str;
      default = ["node_modules"];
      description = "Folder names to delete (e.g., node_modules, __pycache__, target, .cache).";
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
