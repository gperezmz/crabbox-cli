{
  description = "Crabbox CLI builds with the GCP capabilities";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      release = builtins.fromJSON (builtins.readFile ./release.json);
      systems = builtins.attrNames release.assets;
      forSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          asset = release.assets.${system};
        in
        {
          default = self.packages.${system}.crabbox;
          crabbox = pkgs.stdenvNoCC.mkDerivation {
            pname = "crabbox";
            version = release.version;
            src = pkgs.fetchurl { inherit (asset) url sha256; };
            sourceRoot = ".";
            nativeBuildInputs = [ pkgs.installShellFiles ];
            installPhase = ''
              runHook preInstall
              install -Dm755 crabbox $out/bin/crabbox
              install -Dm644 LICENSE $out/share/licenses/crabbox/LICENSE
              runHook postInstall
            '';
            meta = {
              description = "Crabbox CLI built from gperezmz/crabbox (GCP capabilities)";
              homepage = "https://github.com/gperezmz/crabbox-cli";
              license = nixpkgs.lib.licenses.mit;
              mainProgram = "crabbox";
              platforms = systems;
            };
          };
        }
      );
    };
}
