# ln -s /home/jack/Documents/nixos/shell-fw.nix /home/jack/Projects/NER/Cerberus/shell.nix

{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs.buildPackages; [
    linuxKernel.packages.linux_6_6.usbip
    python3
    llvmPackages_18.clang-tools
    openocd
  ];
  shellHook = ''
    source ../ner-venv/bin/activate
  '';
}
