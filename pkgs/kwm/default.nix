{ pkgs, kwmFlake, ... }:

kwmFlake.packages.${pkgs.stdenv.system}.kwm
