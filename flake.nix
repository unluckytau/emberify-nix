{
  description = "emberify on nix-shell flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pipxNoCheck = pkgs.pipx.overridePythonAttrs (old: {
          doCheck = false;
        });
      in
      {
        devShells.default = pkgs.mkShell {
          name = "emberify-pipx";

          packages = with pkgs; [
            python313
            pipxNoCheck
            git
            opencl-headers
            ocl-icd
            stdenv.cc.cc.lib
            zlib
          ];

          shellHook = ''
            export PIPX_HOME="$PWD/.pipx"
            export PIPX_BIN_DIR="$PWD/.pipx/bin"
            export PATH="$PIPX_BIN_DIR:$PATH"

            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
              pkgs.ocl-icd
            ]}:$LD_LIBRARY_PATH"

            if [ ! -x "$PIPX_BIN_DIR/emberify" ]; then
              echo "Installing emberify with pipx..."
              pipx install emberify
            fi
            echo "Shell Active!"
          '';
        };
      });
}
