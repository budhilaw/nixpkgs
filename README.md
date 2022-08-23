# Baudhilaw's Home 🏚

> Heavily inspired from ([malob/nixpkgs](https://github.com/malob/nixpkgs)) ([r17x/nixpkgs](https://github.com/r17x/nixpkgs)).

This is my personal configuration with [nix](https://nixos.org/) using [**flakes**](https://nixos.wiki/wiki/Flakes), [**home-manager**](https://github.com/nix-community/home-manager), & [**nix-darwin**](https://github.com/LnL7/nix-darwin) for Darwin or MacOS System.

## Structure

```console
.
├── README.md
├── darwin
│   ├── bootstrap.nix
│   ├── defaults.nix
│   ├── general.nix
│   └── homebrew.nix
├── default.nix
├── flake.lock
├── flake.nix
├── home
│   ├── config-files.nix
│   ├── fish.nix
│   ├── git.nix
│   ├── packages.nix
│   └── zsh.nix
├── nixpkgs.nix
└── result -> /nix/store/xxxx (the result when completed run nix build)

3 directories, 14 files

```

## Usage

### Prerequisite

#### **Nix**

| System                                         | Single User | Multiple User | Command                                                             |
| ---------------------------------------------- | ----------- | ------------- | ------------------------------------------------------------------- |
| **Linux**                                      | ✅          | ✅            | [Single User](#linux-single-user) • [Multi User](#linux-multi-user) |
| **Darwin** (MacOS)                             | ❌          | ✅            | [Multi User](#darwin-multi-user)                                    |
| [**More...**](https://nixos.org/download.html) |             |               |                                                                     |

##### Linux Single User

```console
sh <(curl -L https://nixos.org/nix/install) --daemon
```

##### Linux Multi User

```console
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

##### Darwin Multi User

```console
sh <(curl -L https://nixos.org/nix/install)
```

#### Enable `experimental-features`

In general installation of nix, the nix configuration is located in `~/.config/nix/nix.conf`.
You **MUST** be set the `experimental-features` before use [this configuration](https://github.com/r17x/nixpkgs).

```cfg
experimental-features = nix-command flakes

// (optional) for distribution cache (DON'T COPY THIS COMMENT LINE)
substituters = https://cache.nixos.org https://cache.nixos.org/ https://r17.cachix.org
```

### Setup

- Clone [this repository](https://github.com/budhilaw/nixpkgs)

```console
// with SSH

git clone git@github.com:budhilaw/nixpkgs.git ~/.config/nixpkgs

// OR with HTTP
git clone https://github.com/budhilaw/nixpkgs.git ~/.config/nixpkgs

```

- Change directory to `~/.config/nixpkgs`

```console
cd ~/.config/nixpkgs
```

- Run Build  
  command for build: `nix build .#darwinConfigurations.[NAME].system`  
  Available for `[NAME]`:
  - `Budhilaw`

```console
nix build .#darwinConfigurations.Budhilaw.system
```

- Apply from `Result`  
  command for apply the result: `./result/sw/bin/darwin-rebuild switch --flake .#[NAME]`  
  Available for `[NAME]`:
  - `Budhilaw`  
    After `Run Build` you can apply from `./result` with this command

```console
./result/sw/bin/darwin-rebuild switch --flake .#Budhilaw
```

- Done 🚀🎉

## Acknowledgement

- [**malob/nixpkgs**](https://github.com/malob/nixpkgs) ~ [malob](https://github.com/malob) Nix System configs!.
- [**r17x/nixpkgs**](https://github.com/r17x/nixpkgs) ~ [r17x](https://github.com/r17x) Nix config!.
- [**Lzyct/nixpkgs**](https://github.com/Lzyct/nixpkgs) ~ [Lzyct](https://github.com/Lzyct) Nix config!.