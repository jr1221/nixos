# symlink to buildroot submodule:
# ln -s /home/jack/Documents/nixos/shell-buildroot.nix /home/jack/Projects/NER/buildroot/Siren/odysseus/buildroot/shell.nix
# nix-shell

let
  pkgs = import <nixpkgs> { };
in
(pkgs.buildFHSUserEnv {
  name = "buildroot";
  targetPkgs = pkgs: (with pkgs;
    [
      pkg-config
      ncurses
      qt5.qtbase
      # new gcc usually causes issues with building kernel so use an old one
      pkgsCross.aarch64-multiplatform.gccStdenv.cc
      (hiPrio gcc)

      # mandatory
      which
      gnused
      gnumake
      binutils
      diffutils
      bash
      gnupatch
      gzip
      bzip2
      perl
      gnutar
      cpio
      unzip
      rsync
      file
      bc
      findutils
      wget

      # other optional
      python3
      git
      graphviz
      python311Packages.matplotlib

      # other
      git-lfs
      libelf
    ]
    ++ pkgs.linux.nativeBuildInputs);
    runScript = pkgs.writeScript "init.sh" ''
    export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:${pkgs.qt5.qtbase.dev}/lib/pkgconfig"
    export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins"
    export QT_QPA_PLATFORMTHEME=qt5ct
    exec fish
  '';
}).env
