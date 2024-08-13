{
  description = "gcp3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      factor = pkgs.factor-lang;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          factor
        ];
        FACTOR_ROOT = "${factor}";
      };
    };
}
