# Dotfiles 2 System Configurations

[I] This repository is heavily inspired by [nmasur/dotfiles](https://github.com/nmasur/dotfiles/tree/master)

## Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/alistairstead/dotfiles2/install.sh)"
```

Sync settings for aws cli

```bash
granted-refresh
```

## Update packages

```bash
nix flake update
```

then rebuild the system

```bash
rebuild-darwin
```
