{
  description = "A flake that has a minimal shell that is able to run cloud images";

  inputs = {
     flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgsAllowUnfree = import nixpkgs {
        system = "x86_64-linux";
        config = { allowUnfree = true; };
      };

    in
    {
      packages.myqemu = import ./myqemu.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      };

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
                                 qemu
                                 wget
                                 cloud-utils
                                ];
      };
    }
  );
}
