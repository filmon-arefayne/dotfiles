{
  description = "Filmon's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        filmon = lib.nixosSystem {
          inherit system;
          modules = [
	    ./configuration.nix
	    home-manager.nixosModules.home-manager {
	      home-manager.useGlobalPkgs = true;
	      home-manager.useUserPackages = true;
	      home-manager.users.filmon = {
	        imports = [ ./home.nix ];
	      };
	    }
	  ];
        };
      };
      hmConfig = {
        filmon = home-manager.lib.homeManagerConfiguration {
	  inherit system pkgs;
	  username = "filmon";
	  homeDirectory = "/home/filmon";
	  stateVersion = "22.05";
	  configuration = {
	    imports = [
	      ./home.nix
	    ];
	  };
	};
      };
    };
}
