{
  #description = "nix config";

  inputs = {
    master.url = "github:nixos/nixpkgs/master";
    staging-next.url = "github:nixos/nixpkgs/staging-next";
    staging.url = "github:nixos/nixpkgs/staging";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    release-stable.url = "github:nixos/nixpkgs/release-24.11";
    staging-next-stable.url = "github:nixos/nixpkgs/staging-next-24.11";
    staging-stable.url = "github:nixos/nixpkgs/staging-24.11";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixos-stable-small.url = "github:nixos/nixpkgs/nixos-24.11-small";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs.follows = "nixos-unstable";

    nur.url = "github:nix-community/NUR";
    #hardware.url = "github:nixos/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fortune-kind = {
      url = "github:cafkafk/fortune-kind";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jerry = {
      url = "github:justchokingaround/jerry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lobster = {
      url = "github:justchokingaround/lobster";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-conf-editor = {
      url = "github:snowfallorg/nixos-conf-editor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #nixos-generators = {
    #  url = "github:nix-community/nixos-generators";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nyx = {
      url = "github:chaotic-cx/nyx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      flake = false;
    };
    #firefox-gnome-theme = { url = "github:rafaelmardojai/firefox-gnome-theme"; flake = false; };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      nix-on-droid,
      system-manager,
      home-manager,
      pre-commit,
      treefmt,
      systems,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt.lib.evalModule pkgs ./nix/treefmt.nix);
    in
    {
      packages = eachSystem (pkgs: import ./pkgs { inherit pkgs; });
      legacyPackages = eachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        pre-commit = import ./nix/pre-commit.nix { inherit pkgs pre-commit; };
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
      devShells = eachSystem (pkgs: {
        default = import ./nix/shell.nix { inherit pkgs; };
      });
      overlays = import ./overlays;
      #templates = import ./templates;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/desktop ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/laptop ];
        };
        wsl = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/wsl ];
        };
      };
      darwinConfigurations = {
        darwin = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/darwin ];
        };
      };
      nixOnDroidConfigurations = {
        default = nix-on-droid.lib.nixOnDroidConfiguration {
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          home-manager-path = home-manager;
          modules = [ ./hosts/droid ];
        };
      };
      systemConfigs = {
        default = system-manager.lib.makeSystemConfig {
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/non-nix ];
        };
      };
      homeConfigurations = {
        user = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          pkgs = pkgs: nixpkgs.legacyPackages.${pkgs.system};
          modules = [ ./home-manager ];
        };
      };
    };
}
