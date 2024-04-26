{
  description = "khalorg";
  inputs.pyproject-nix.url = "github:nix-community/pyproject.nix";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, pyproject-nix, ... }:
    let
      inherit (nixpkgs) lib;
      project = pyproject-nix.lib.project.loadPyproject {
        projectRoot = pkgs.fetchFromGitHub {
	  owner = "BartSte";
	  repo = "khalorg";
	  rev = "v0.0.3";
	  hash = "sha256-RJX1+Yi9p/v/+7GgyamlOYZWvS/5JqIYcKUpZsBPlZM=";
	};
      };
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      python = pkgs.python3.override {
        packageOverrides = pyself: pysuper: {
          khal = pysuper.toPythonModule pkgs.khal;
        };
      };
    in
    {
      devShells.x86_64-linux.default =
        let
          arg = project.renderers.withPackages { inherit python; };
          pythonEnv = python.withPackages arg;
        in
        pkgs.mkShell { packages = [ pythonEnv ]; };
      packages.x86_64-linux.default =
        let
          attrs = project.renderers.buildPythonPackage { inherit python; };
        in
        python.pkgs.buildPythonPackage attrs;
    };
}

