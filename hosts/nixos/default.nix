{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  modulesPath,
  ...
}:

{
  networking.hostName = "nixos";
  #userList = [ "ravenz46" ];
  userList = [ "user" ];
  ai-utils = {
    enable = false;
    excludePackages = with pkgs; [
      ollama
      tabby
    ];
  };
  audio.enable = true;
  desktop = {
    compositors = [ "cosmic" "niri" ];
    excludePackages = with pkgs; [ ];
  };
  localization.enable = true;
  misc = {
    enable = false;
    excludePackages = with pkgs; [
      android-tools
      envision
      garage
      kanata
      lact
      mouse-actions
      rkvm
      rustdesk-server
    ];
  };
  network = {
    enable = true;
    excludePackages = with pkgs; [
      rosenpass
      rosenpass-tools
      tailscale
      #hickory-dns
      wstunnel
    ];
  };
  nix-utils = {
    enable = true;
    excludePackages = with pkgs; [
      nix-ld-rs
      nixseparatedebuginfod
      nix-web
    ];
  };
  observability = {
    enable = false;
    excludePackages = with pkgs; [
      below
      vector
    ];
  };
  search = {
    enable = false;
    excludePackages = with pkgs; [
      meilisearch
      qdrant
      quickwit
      sonic-server
    ];
  };
  security = {
    enable = true;
    excludePackages = with pkgs; [ kanidm ];
  };
  shells.enable = true;
  virtualization = {
    hypervisor = "kvm";
    #container.enable = true;
    excludePackages = with pkgs; [
      cloud-hypervisor
      cntr
      conmon-rs
      crosvm
      firecracker
      stratovirt
    ];
  };

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];
    };
  };

  nixpkgs.overlays = builtins.attrValues outputs.overlays;

  hardware.system76.power-daemon.enable = true;

  services = {
    clipcat.enable = true;
    system76-scheduler.enable = true;
    #fstrim.enable = true;
    #kanidm = {
    #  enableClient = true;
    #  enableServer = true;
    #};
    #rkvm = {
    #  server = {
    #    enable = true;
    #  };
    #  cliant = {
    #    enable = true;
    #  };
    #};
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "green"; # red, pink, yellow, green, teal
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard-rs
    uutils-coreutils-noprefix
    (catppuccin-papirus-folders.override {
      inherit (config.catppuccin) flavor;
      inherit (config.catppuccin) accent;
    })
  ];

  users.users = lib.genAttrs config.userList (f: {
    name = "ravenz46";
    isNormalUser = true;
    packages = with pkgs; [ ];
  });

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.user = import ./home.nix;
  };

  system.stateVersion = "24.11";

  imports =
    [
      (modulesPath + "/profiles/hardened.nix")
      ./configuration.nix
      ./disk-config.nix
      ./hardware-configuration.nix
    ]
    ++ (with inputs; [
      catppuccin.nixosModules.catppuccin
      disko.nixosModules.default
      home-manager.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      musnix.nixosModules.default
      niri-flake.nixosModules.niri
      nix-gaming.nixosModules.pipewireLowLatency
      nix-gaming.nixosModules.platformOptimizations
      nix-index-database.nixosModules.nix-index
      nixos-cosmic.nixosModules.default
      #nixvim.nixosModules.default
      nur.nixosModules.nur
      nyx.nixosModules.default
    ])
    ++ (builtins.attrValues outputs.nixosModules);
}