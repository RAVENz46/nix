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
  networking.hostName = "";
  userList = [ "" ];
  ai-utils = {
    enable = false;
    excludePackages = with pkgs; [
      ollama
      tabby
    ];
  };
  audio.enable = false;
  desktop-managers = {
    compositors = [
      "cosmic"
      "niri"
    ];
    excludePackages = with pkgs; [ cosmic-greeter ];
  };
  localization.enable = false;
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
    enable = false;
    excludePackages = with pkgs; [
      bandwhich
      rosenpass
      rosenpass-tools
      sniffnet
      tailscale
      trippy
      hickory-dns
      wstunnel
    ];
  };
  nix-utils = {
    enable = false;
    excludePackages = with pkgs; [
      nh
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
    enable = false;
    excludePackages = with pkgs; [ kanidm ];
  };
  shells.enable = false;
  virtualization = {
    hypervisor = ""; # kvm or xen
    container.enable = false;
    excludePackages = with pkgs; [
      cloud-hypervisor
      cntr
      conmon-rs
      crosvm
      distrobuilder
      extra-container
      firecracker
      gnome.gnome-boxes
      incus
      krun
      krunvm
      lxc
      quickemu
      quickgui
      stratovirt
      swtpm
      virt-manager
    ];
  };

  nixpkgs.overlays = builtins.attrValues outputs.overlays;

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

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "green"; # red, pink, yellow, green, teal
  };

  hardware.system76.power-daemon.enable = true;

  services = {
    clipcat.enable = true;
    system76-scheduler.enable = true;
    #fstrim.enable = true;
    kanidm = {
      #enableClient = true;
      #enableServer = true;
    };
    #rkvm = {
    #  server = {
    #    enable = true;
    #  };
    #  cliant = {
    #    enable = true;
    #  };
    #};
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
    isNormalUser = true;
    packages = with pkgs; [ ];
  });

  system.stateVersion = "";

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
