{
  description = "dmemcg-booster NixOS module";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

  outputs = { self, nixpkgs }:
    {
      packages.x86_64-linux.dmemcg-booster =
        nixpkgs.legacyPackages.x86_64-linux.rustPlatform.buildRustPackage {
          pname = "dmemcg-booster";
          version = "0.1.3";

          src = nixpkgs.legacyPackages.x86_64-linux.fetchFromGitLab {
            domain = "gitlab.steamos.cloud";
            owner = "holo";
            repo = "dmemcg-booster";
            tag = "0.1.3";
            hash = "sha256-JDT+JKxgaETinIHiP0Pqb7fPNrvcI6AQu90nmoA/YuI=";
          };

          postPatch = ''
            substituteInPlace *.service \
              --replace-fail /usr/bin/dmemcg-booster $out/bin/dmemcg-booster
          '';

          cargoHash =
            "sha256-NHK4734Jvi4RJieGn0RjYU0PzQFqaE4exHG77dmukig=";

          nativeBuildInputs = [
            nixpkgs.legacyPackages.x86_64-linux.pkg-config
          ];

          buildInputs = [
            nixpkgs.legacyPackages.x86_64-linux.dbus
          ];

          postInstall = ''
            install -Dm644 dmemcg-booster-system.service \
              "$out/lib/systemd/system/dmemcg-booster-system.service"

            install -Dm644 dmemcg-booster-user.service \
              "$out/lib/systemd/user/dmemcg-booster-user.service"
          '';

          meta = {
            description = "Dynamic memory cgroup booster";
            homepage = "https://gitlab.steamos.cloud/holo/dmemcg-booster";
            license = nixpkgs.lib.licenses.mit;
            platforms = nixpkgs.lib.platforms.linux;
            mainProgram = "dmemcg-booster";
          };
        };

      nixosModules.default =
        { config, lib, pkgs, ... }:
        {
          options.services.dmemcg-booster.enable =
            lib.mkEnableOption "dmemcg-booster system service";

          config = lib.mkIf config.services.dmemcg-booster.enable {
            systemd.packages = [
              self.packages.${pkgs.stdenv.hostPlatform.system}.dmemcg-booster
            ];

            systemd.services.dmemcg-booster-system = {
              enable = true;
              wantedBy = [ "multi-user.target" ];
            };
          };
        };
    };
}
