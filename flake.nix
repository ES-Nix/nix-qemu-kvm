{
  description = "A flake that has a minimal shell that is able to run cloud images";

  inputs = {
     flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        #config = { allowUnfree = true; };
      };
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [ 
                                 qemu
                                 wget
                                 cloud-utils
                                ];
      };
    }
  );
}
