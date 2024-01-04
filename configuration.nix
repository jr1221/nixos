# symlink to /etc/nixos/configuration.nix
# sudo ln -s /home/jack/Documents/nixos/configuration.nix /etc/nixos/

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    <home-manager/nixos>
  ];

  # allow nix commands such as nix run, etc.
  nix.settings.experimental-features = [ "nix-command" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "kernel.sysrq" = 1;
  };

  networking.hostName = "jack-xps9570-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jack = {
    isNormalUser = true;
    description = "Jack Rubacha";
    extraGroups = [ "networkmanager" "wheel" ];
    # sets default shell (doesnt apply to nix-shell)
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # ignores if shell installed, as uses home-manager shell
  users.users.jack.ignoreShellProgramCheck = true;

  # allows to use the environment pkg manager, fixes issue with nonfree
  home-manager.useGlobalPkgs = true;
  home-manager.users.jack = { pkgs, ... }: {
    home.username = "jack";
    home.homeDirectory = "/home/jack";
    programs.home-manager.enable = true;
    imports = [ <plasma-manager/modules> ];
    home.packages = with pkgs; [
      htop
      kate
      efibootmgr
      (vivaldi.override {
        enableWidevine = true;
        proprietaryCodecs = true;
      })
      github-desktop
      slack
      meld
      git
      nixfmt
      grc # colored fish output
      rpi-imager
      partition-manager
      killall
    ];
    programs.fish = {
      enable = true;
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        {
          name = "grc";
          src = pkgs.fishPlugins.grc.src;
        }
      ];
    };
    # ensure bash doesnt come alive
    programs.bash.enable = false;

    programs.ssh.enable = true;

    programs.plasma = {
      enable = true;
      configFile = {
        "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
        "krunnerrc"."Plugins"."baloosearchEnabled" = false;
        "kdeglobals"."KDE"."SingleClick" = false;
        "kdeglobals"."KScreen"."ScaleFactor" = 2;
        "kdeglobals"."KScreen"."ScreenScaleFactors" =
          "eDP-1-1=2;DP-1-1=2;DP-1-2=2;DP-1-3=2;";
        "kwinrc"."NightColor"."Active" = true;
        "kwinrc"."NightColor"."Mode" = "Constant";
        "kwinrc"."NightColor"."NightTemperature" = 5400;
        "plasmarc"."Theme"."name" = "breeze-dark";
        "kwinrc"."Xwayland"."Scale" = 2;
        "kdeglobals"."WM"."activeBackground" = "49,54,59";
        "kdeglobals"."WM"."activeBlend" = "252,252,252";
        "kdeglobals"."WM"."activeForeground" = "252,252,252";
        "kdeglobals"."WM"."inactiveBackground" = "42,46,50";
        "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
        "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
      };
    };
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";

  };

  # autologin mysteriously broken
  services.xserver.displayManager.autoLogin.enable = false;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.xserver.displayManager.autoLogin.user = "jack";
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for electron wayland

  # Allow unfree packages
  nixpkgs.config = { allowUnfree = true; };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
    ];

  # for root escalation in guis (kate still doesnt work?)
  security.polkit.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [
  "intel"
  "nvidia"
  ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
