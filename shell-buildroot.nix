# symlink to buildroot submodule:
# ln -s /home/jack/Documents/nixos/shell-buildroot.nix /home/jack/Projects/NER/buildroot/Siren/odysseus/buildroot/shell.nix
# run `nix-shell --pure --keep XDG_SESSION_TYPE --keep QT_PLUGIN_PATH  --keep XDG_DATA_DIRS` to open

let pkgs = import <nixpkgs> { };
in (pkgs.buildFHSUserEnv {
  name = "buildroot";
  targetPkgs = pkgs:
    (with pkgs;
      [
        pkg-config
        ncurses
        qt5.qtbase
        libsForQt5.qt5ct

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
        util-linux
        libxcrypt-legacy

        # needed for nixos
#         (glibc.override {
#           withLibcrypt = true;
#         })
      ] ++ pkgs.linux.nativeBuildInputs);
  runScript = "bash";
  profile = ''
    export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins"
    export QT_QPA_PLATFORMTHEME=qt5ct
    export QT_WAYLAND_FORCE_DPI=84
    export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:${pkgs.qt5.qtbase.dev}/lib/pkgconfig"
    export NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
    export SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.cr"
  '';
}).env
