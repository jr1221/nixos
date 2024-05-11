# ln -s /home/jack/Documents/nixos/shell-emqx.nix /home/jack/Projects/NER/emqx/shell.nix

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    gnumake
    gcc
    erlang_26
    openssl
    curl
    cmake
    libgccjit
    autoconf
    automake
    libtool
    jq
    bison
    flex
    expect
    oniguruma

    wget
    git
    unzip
  ];
}
