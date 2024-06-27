{
  description = "HasTEEProcedureCall";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    wasm-ghc.url = "git+https://gitlab.haskell.org/ghc/ghc-wasm-meta";
  };

  outputs = { self, nixpkgs, wasm-ghc }:
    let
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      version = builtins.substring 0 8 lastModifiedDate;
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      devShells = forAllSystems
        (system:
          let pkgs = nixpkgsFor.${system}; in {
            default = pkgs.mkShell
              {
                buildInputs = with pkgs; [
                  zlib
                  haskellPackages.cabal-install
                  haskellPackages.fourmolu
                  haskell.compiler.ghcHEAD
                  haskellPackages.ghcid
                  haskell-language-server
                  gnumake
                  python3
                ] ++ (with wasm-ghc.packages.${system};
                  [
                    wasm32-wasi-ghc-gmp
                    wasm32-wasi-ghc-native
                    wasm32-wasi-ghc-unreg
                    wasm32-wasi-ghc-9_6
                    wasm32-wasi-ghc-9_8
                    wasm32-wasi-ghc-9_10
                    wasm32-wasi-cabal-gmp
                    wasm32-wasi-cabal-native
                    wasm32-wasi-cabal-unreg
                    wasm32-wasi-cabal-9_6
                    wasm32-wasi-cabal-9_8
                    wasm32-wasi-cabal-9_10
                    wasi-sdk
                    deno
                    nodejs
                    bun
                    binaryen
                    wabt
                    wasmtime
                    wasmedge
                    wazero
                    cabal
                    proot
                    wasm-run
                  ]);
              };
          });
      defaultPackage = forAllSystems (system: self.packages.${system}.WasmTest);
    };
}
