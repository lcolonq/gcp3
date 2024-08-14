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
      gcp3-lib = pkgs.stdenv.mkDerivation {
        name = "gcp3-lib";
        src = ./.;
        installPhase = ''
          mkdir -p $out
          cp -r * $out
        '';
        postInstallPhase = "";
      };
      gcp3 = pkgs.writeShellScriptBin "gcp3" ''
        ${factor}/bin/factor ${gcp3-lib}/launch.factor
      '';
      gcp3Module = { config, lib, ... }:
        let
          cfg = config.colonq.services.gcp3;
        in {
          options.colonq.services.gcp3 = {
            enable = lib.mkEnableOption "Enable the GCP3 server";
          };
          config = lib.mkIf cfg.enable {
            systemd.services."colonq.gcp3" = {
              after = ["network-online.target"];
              wantedBy = ["network-online.target"];
              serviceConfig = {
                Restart = "on-failure";
                ExecStart = "${gcp3}/bin/gcp3";
                DynamicUser = "yes";
                RuntimeDirectory = "colonq.gcp3";
                RuntimeDirectoryMode = "0755";
                StateDirectory = "colonq.gcp3";
                StateDirectoryMode = "0700";
                CacheDirectory = "colonq.gcp3";
                CacheDirectoryMode = "0750";
              };
            };
          };
        };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          factor
        ];
        FACTOR_ROOT = "${factor}";
      };
      packages.x86_64-linux = {
        default = gcp3;
        inherit gcp3 gcp3-lib;
      };
      nixosModules = {
        gcp3 = gcp3Module;
      };
    };
}
