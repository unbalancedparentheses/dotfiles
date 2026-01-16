{
  description = "Cross-platform Nix configuration (macOS + Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    # User configuration
    username = "unbalancedparen";
    gitName = "Federico Carrone";
    gitEmail = "mail@fcarrone.com";

    # Systems
    darwinSystem = "aarch64-darwin";
    linuxSystem = "x86_64-linux";

    # Import packages
    packages = import ./modules/packages.nix;

  in {
    # macOS configuration
    darwinConfigurations.default = nix-darwin.lib.darwinSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = (packages { inherit pkgs; }).shared
            ++ (packages { inherit pkgs; }).darwin;
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.primaryUser = username;
          nixpkgs.hostPlatform = darwinSystem;
        })
        ./modules/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.${username} = { pkgs, lib, ... }: {
            imports = [ ./modules/home.nix ];
            home.username = username;
            home.homeDirectory = lib.mkForce "/Users/${username}";
            _module.args = { inherit gitName gitEmail; };
          };
        }
      ];
      specialArgs = { inherit username; };
    };

    # Linux configuration
    homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${linuxSystem};
      modules = [
        ({ pkgs, ... }: {
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.packages = (packages { inherit pkgs; }).shared
            ++ (packages { inherit pkgs; }).linuxFonts;
          fonts.fontconfig.enable = true;
          _module.args = { inherit gitName gitEmail; };
        })
        ./modules/home.nix
      ];
    };
  };
}
