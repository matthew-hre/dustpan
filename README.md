# node-modules-gc

A Home Manager module that prunes build and dependency folders (like `node_modules/`, `target/`, etc.) older than N days, automatically, on a timer.

## Install and Usage

Add the following to your flake:

```nix
inputs.node-modules-gc.url = "github:matthew-hre/node-modules-gc";

outputs = { node-modules-gc, ... }: {
    homeManagerModules.node-modules-gc = node-modules-gc.homeManagerModules.node-modules-gc;
};
```

And use it in your Home Manager configuration:

```nix
{inputs, ...}: {
    imports = [
        inputs.node-modules-gc.homeManagerModules.node-modules-gc
    ];

    services.nodeModules.gc = {
        enable = true;
        directories = [ "$HOME/dev" "$HOME/Projects" ];
        foldersToClean = [ "node_modules" "__pycache__" "target" ".cache" ];
        olderThanDays = 30;
        frequency = "weekly";
    };
}
```

### Options

- `enable`: Enable automatic cleanup of old build/dependency folders (default: `false`).
- `directories`: Directories to search for folders to clean (default: `["$HOME/projects" "$HOME/Projects", "$HOME/dev"]`).
- `foldersToClean`: Names of folders to clean up (default: `["node_modules"]`).
- `olderThanDays`: Remove folders older than this many days (default: `30`).
- `frequency`: systemd timer OnCalendar value (default: `"weekly"`).

## Result

A systemd timer and service is created to periodically run a cleanup. Logs are visible in the journal:

```bash
journalctl --user -u node-modules-gc.service
```

## Why?

I usually have a couple GB of `node_modules` folders lying around in various projects that I no longer work on, and as great as [npkill](https://github.com/voidcosmos/npkill) is, I don't run it as much as I should. Inspired by the `nix.gc.automatic` flag, this module automates the cleanup process, so that old `node_modules` folders are pruned regularly.

## License

MIT © Matthew Hrehirchuk
