# https://nixos.wiki/wiki/Python
{ pkgs }:
let
  # install unstable packages with unstable.<PACKAGE-NAME>
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in let
  my-python-packages = python-packages:
    with python-packages; [
      black
      cirq
      flake8
      ipython
      jupyter
      matplotlib
      mypy
      networkx
      numpy
      #pip # only use inside virtual environments!
      pylint
      pytest
      qutip
      scipy
      sympy
      # language server protocol packages
      python-lsp-server
      python-lsp-black
      pyls-flake8
      pyls-isort
      pylsp-mypy
    ];
  python-with-my-packages = [ (pkgs.python3.withPackages my-python-packages) ];

  extra-libs-for-conda = with pkgs; [ ];
  conda-with-extra-libs =
    unstable.conda.override { extraPkgs = extra-libs-for-conda; };

in python-with-my-packages ++ [ conda-with-extra-libs ]
