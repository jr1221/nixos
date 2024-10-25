# symlink to /etc/nixos/configuration.nix
# sudo ln -s /home/jack/Documents/nixos/configuration.nix /etc/nixos/

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    <home-manager/nixos>
  ];

  # for space savings
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # allow nix commands such as nix run, etc.
  nix.settings.experimental-features = [ "nix-command" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.initrd.kernelModules = [ "nvidia_drm" "nvidia" "nvidia_modeset" "i915"];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "kernel.sysrq" = 502;
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

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";

  #   # Configure keymap in X11
  #   services.xserver = {
  #     xkb.layout = "us";
  #     xkb.variant = "";
  #   };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
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
  users.groups.plugdev = { };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jack = {
    isNormalUser = true;
    description = "Jack Rubacha";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev"
    ];
    # sets default shell (doesnt apply to nix-shell)
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  # cant use as user package!
  programs.partition-manager.enable = true;

  # ignores if shell installed, as uses home-manager shell
  users.users.jack.ignoreShellProgramCheck = true;

  virtualisation.docker = {
    enable = true;
  };

  # allows to use the environment pkg manager, fixes issue with nonfree
  home-manager.useGlobalPkgs = true;
  home-manager.users.jack =
    { pkgs, ... }:
    {
      home.username = "jack";
      home.homeDirectory = "/home/jack";
      programs.home-manager.enable = true;
      imports = [ <plasma-manager/modules> ];
      home.packages = with pkgs; [
        htop
        kate
        efibootmgr
        gitkraken
        slack
        (vivaldi.override {
          enableWidevine = true;
          proprietaryCodecs = true;
        })
        meld
        git
        nixfmt-rfc-style
        grc # colored fish output
        rpi-imager
        killall
        #ner
        stm32cubemx
        mqttui
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

      # let home manager manage startx
      xsession.enable = true;
      xsession.windowManager.command = "…";

      programs.git = {
        enable = true;
        userName = "Jack Rubacha";
        userEmail = "rubacha.jack03@gmail.com";
      };
      # ensure bash doesnt come alive
      programs.bash.enable = false;

      programs.ssh.enable = true;

      programs.vscode = {
        enable = true;
        extensions =
          with pkgs.vscode-extensions;
          [
            arrterian.nix-env-selector
            rust-lang.rust-analyzer
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "probe-rs-debugger";
              publisher = "probe-rs";
              version = "0.24.2";
              sha256 = "d46b390f9c1ab3f64e650ad50f7fd48919b96dbd76bc6225eb40195761276b34";
            }
          ];
      };

      programs.plasma = {
        enable = true;
        overrideConfig = true;
        workspace = {
          theme = "breeze-dark";
          clickItemTo = "select";
          colorScheme = "breezeDark";
          lookAndFeel = "org.kde.breezedark.desktop";
          wallpaperPictureOfTheDay.provider = "bing";
        };
        windows = {
          allowWindowsToRememberPositions = true;
        };
        panels = [
          {
            location = "bottom";
            height = 30;
            hiding = "normalpanel";
            floating = true;
            widgets = [
              "org.kde.plasma.kickoff"
              {
                name = "org.kde.plasma.icontasks";
                config = {
                  General.launchers = [
                    "applications:systemsettings.desktop"
                    "applications:org.kde.dolphin.desktop"
                    "applications:org.kde.konsole.desktop"
                    "applications:vivaldi-stable.desktop"
                  ];
                };
              }
              "org.kde.plasma.colorpicker"
              "org.kde.plasma.systemtray"
              "org.kde.plasma.digitalclock"
              "org.kde.plasma.showdesktop"
            ];
          }
        ];

        shortcuts = {
          "ActivityManager"."switch-to-activity-f80d8bc2-3dca-4b95-8a4a-1cdaade18b4a" = [ ];
          "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
          "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
          "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
          "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
          "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
          "kcm_touchpad"."Toggle Touchpad" = [
            "Touchpad Toggle"
            "Meta+Ctrl+Zenkaku Hankaku"
          ];
          "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
          "kmix"."decrease_volume" = "Volume Down";
          "kmix"."decrease_volume_small" = "Shift+Volume Down";
          "kmix"."increase_microphone_volume" = "Microphone Volume Up";
          "kmix"."increase_volume" = "Volume Up";
          "kmix"."increase_volume_small" = "Shift+Volume Up";
          "kmix"."mic_mute" = [
            "Microphone Mute"
            "Meta+Volume Mute"
          ];
          "kmix"."mute" = "Volume Mute";
          "ksmserver"."Halt Without Confirmation" = [ ];
          "ksmserver"."Lock Session" = [
            "Meta+L"
            "Screensaver"
          ];
          "ksmserver"."Log Out" = "Ctrl+Alt+Del";
          "ksmserver"."Log Out Without Confirmation" = [ ];
          "ksmserver"."Reboot" = [ ];
          "ksmserver"."Reboot Without Confirmation" = [ ];
          "ksmserver"."Shut Down" = [ ];
          "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
          "kwin"."Cycle Overview" = [ ];
          "kwin"."Cycle Overview Opposite" = [ ];
          "kwin"."Decrease Opacity" = [ ];
          "kwin"."Edit Tiles" = "Meta+T";
          "kwin"."Expose" = "Ctrl+F9";
          "kwin"."ExposeAll" = [
            "Ctrl+F10"
            "Launch (C)"
          ];
          "kwin"."ExposeClass" = "Ctrl+F7";
          "kwin"."ExposeClassCurrentDesktop" = [ ];
          "kwin"."Grid View" = "Meta+G";
          "kwin"."Increase Opacity" = [ ];
          "kwin"."Kill Window" = "Meta+Ctrl+Esc";
          "kwin"."Move Tablet to Next Output" = [ ];
          "kwin"."MoveMouseToCenter" = "Meta+F6";
          "kwin"."MoveMouseToFocus" = "Meta+F5";
          "kwin"."MoveZoomDown" = [ ];
          "kwin"."MoveZoomLeft" = [ ];
          "kwin"."MoveZoomRight" = [ ];
          "kwin"."MoveZoomUp" = [ ];
          "kwin"."Overview" = "Meta+W";
          "kwin"."Setup Window Shortcut" = [ ];
          "kwin"."Show Desktop" = "Meta+D";
          "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
          "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
          "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
          "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
          "kwin"."Switch Window Down" = "Meta+Alt+Down";
          "kwin"."Switch Window Left" = "Meta+Alt+Left";
          "kwin"."Switch Window Right" = "Meta+Alt+Right";
          "kwin"."Switch Window Up" = "Meta+Alt+Up";
          "kwin"."Switch to Desktop 1" = "Ctrl+F1";
          "kwin"."Switch to Desktop 10" = [ ];
          "kwin"."Switch to Desktop 11" = [ ];
          "kwin"."Switch to Desktop 12" = [ ];
          "kwin"."Switch to Desktop 13" = [ ];
          "kwin"."Switch to Desktop 14" = [ ];
          "kwin"."Switch to Desktop 15" = [ ];
          "kwin"."Switch to Desktop 16" = [ ];
          "kwin"."Switch to Desktop 17" = [ ];
          "kwin"."Switch to Desktop 18" = [ ];
          "kwin"."Switch to Desktop 19" = [ ];
          "kwin"."Switch to Desktop 2" = "Ctrl+F2";
          "kwin"."Switch to Desktop 20" = [ ];
          "kwin"."Switch to Desktop 3" = "Ctrl+F3";
          "kwin"."Switch to Desktop 4" = "Ctrl+F4";
          "kwin"."Switch to Desktop 5" = [ ];
          "kwin"."Switch to Desktop 6" = [ ];
          "kwin"."Switch to Desktop 7" = [ ];
          "kwin"."Switch to Desktop 8" = [ ];
          "kwin"."Switch to Desktop 9" = [ ];
          "kwin"."Switch to Next Desktop" = [ ];
          "kwin"."Switch to Next Screen" = [ ];
          "kwin"."Switch to Previous Desktop" = [ ];
          "kwin"."Switch to Previous Screen" = [ ];
          "kwin"."Switch to Screen 0" = [ ];
          "kwin"."Switch to Screen 1" = [ ];
          "kwin"."Switch to Screen 2" = [ ];
          "kwin"."Switch to Screen 3" = [ ];
          "kwin"."Switch to Screen 4" = [ ];
          "kwin"."Switch to Screen 5" = [ ];
          "kwin"."Switch to Screen 6" = [ ];
          "kwin"."Switch to Screen 7" = [ ];
          "kwin"."Switch to Screen Above" = [ ];
          "kwin"."Switch to Screen Below" = [ ];
          "kwin"."Switch to Screen to the Left" = [ ];
          "kwin"."Switch to Screen to the Right" = [ ];
          "kwin"."Toggle Night Color" = [ ];
          "kwin"."Toggle Window Raise/Lower" = [ ];
          "kwin"."Walk Through Windows" = "Alt+Tab";
          "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
          "kwin"."Walk Through Windows Alternative" = [ ];
          "kwin"."Walk Through Windows Alternative (Reverse)" = [ ];
          "kwin"."Walk Through Windows of Current Application" = "Alt+`";
          "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
          "kwin"."Walk Through Windows of Current Application Alternative" = [ ];
          "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = [ ];
          "kwin"."Window Above Other Windows" = [ ];
          "kwin"."Window Below Other Windows" = [ ];
          "kwin"."Window Close" = "Alt+F4";
          "kwin"."Window Fullscreen" = [ ];
          "kwin"."Window Grow Horizontal" = [ ];
          "kwin"."Window Grow Vertical" = [ ];
          "kwin"."Window Lower" = [ ];
          "kwin"."Window Maximize" = "Meta+PgUp";
          "kwin"."Window Maximize Horizontal" = [ ];
          "kwin"."Window Maximize Vertical" = [ ];
          "kwin"."Window Minimize" = "Meta+PgDown";
          "kwin"."Window Move" = [ ];
          "kwin"."Window Move Center" = [ ];
          "kwin"."Window No Border" = [ ];
          "kwin"."Window On All Desktops" = [ ];
          "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
          "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
          "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
          "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
          "kwin"."Window One Screen Down" = [ ];
          "kwin"."Window One Screen Up" = [ ];
          "kwin"."Window One Screen to the Left" = [ ];
          "kwin"."Window One Screen to the Right" = [ ];
          "kwin"."Window Operations Menu" = "Alt+F3";
          "kwin"."Window Pack Down" = [ ];
          "kwin"."Window Pack Left" = [ ];
          "kwin"."Window Pack Right" = [ ];
          "kwin"."Window Pack Up" = [ ];
          "kwin"."Window Quick Tile Bottom" = "Meta+Down";
          "kwin"."Window Quick Tile Bottom Left" = [ ];
          "kwin"."Window Quick Tile Bottom Right" = [ ];
          "kwin"."Window Quick Tile Left" = "Meta+Left";
          "kwin"."Window Quick Tile Right" = "Meta+Right";
          "kwin"."Window Quick Tile Top" = "Meta+Up";
          "kwin"."Window Quick Tile Top Left" = [ ];
          "kwin"."Window Quick Tile Top Right" = [ ];
          "kwin"."Window Raise" = [ ];
          "kwin"."Window Resize" = [ ];
          "kwin"."Window Shade" = [ ];
          "kwin"."Window Shrink Horizontal" = [ ];
          "kwin"."Window Shrink Vertical" = [ ];
          "kwin"."Window to Desktop 1" = [ ];
          "kwin"."Window to Desktop 10" = [ ];
          "kwin"."Window to Desktop 11" = [ ];
          "kwin"."Window to Desktop 12" = [ ];
          "kwin"."Window to Desktop 13" = [ ];
          "kwin"."Window to Desktop 14" = [ ];
          "kwin"."Window to Desktop 15" = [ ];
          "kwin"."Window to Desktop 16" = [ ];
          "kwin"."Window to Desktop 17" = [ ];
          "kwin"."Window to Desktop 18" = [ ];
          "kwin"."Window to Desktop 19" = [ ];
          "kwin"."Window to Desktop 2" = [ ];
          "kwin"."Window to Desktop 20" = [ ];
          "kwin"."Window to Desktop 3" = [ ];
          "kwin"."Window to Desktop 4" = [ ];
          "kwin"."Window to Desktop 5" = [ ];
          "kwin"."Window to Desktop 6" = [ ];
          "kwin"."Window to Desktop 7" = [ ];
          "kwin"."Window to Desktop 8" = [ ];
          "kwin"."Window to Desktop 9" = [ ];
          "kwin"."Window to Next Desktop" = [ ];
          "kwin"."Window to Next Screen" = "Meta+Shift+Right";
          "kwin"."Window to Previous Desktop" = [ ];
          "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
          "kwin"."Window to Screen 0" = [ ];
          "kwin"."Window to Screen 1" = [ ];
          "kwin"."Window to Screen 2" = [ ];
          "kwin"."Window to Screen 3" = [ ];
          "kwin"."Window to Screen 4" = [ ];
          "kwin"."Window to Screen 5" = [ ];
          "kwin"."Window to Screen 6" = [ ];
          "kwin"."Window to Screen 7" = [ ];
          "kwin"."view_actual_size" = "Meta+0";
          "kwin"."view_zoom_in" = [
            "Meta++"
            "Meta+="
          ];
          "kwin"."view_zoom_out" = "Meta+-";
          "mediacontrol"."mediavolumedown" = [ ];
          "mediacontrol"."mediavolumeup" = [ ];
          "mediacontrol"."nextmedia" = "Media Next";
          "mediacontrol"."pausemedia" = "Media Pause";
          "mediacontrol"."playmedia" = [ ];
          "mediacontrol"."playpausemedia" = "Media Play";
          "mediacontrol"."previousmedia" = "Media Previous";
          "mediacontrol"."stopmedia" = "Media Stop";
          "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
          "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
          "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
          "org_kde_powerdevil"."Hibernate" = "Hibernate";
          "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
          "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
          "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
          "org_kde_powerdevil"."PowerDown" = "Power Down";
          "org_kde_powerdevil"."PowerOff" = "Power Off";
          "org_kde_powerdevil"."Sleep" = "Sleep";
          "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
          "org_kde_powerdevil"."Turn Off Screen" = [ ];
          "org_kde_powerdevil"."powerProfile" = [
            "Battery"
            "Meta+B"
          ];
          "plasmashell"."activate task manager entry 1" = "Meta+1";
          "plasmashell"."activate task manager entry 10" = [ ];
          "plasmashell"."activate task manager entry 2" = "Meta+2";
          "plasmashell"."activate task manager entry 3" = "Meta+3";
          "plasmashell"."activate task manager entry 4" = "Meta+4";
          "plasmashell"."activate task manager entry 5" = "Meta+5";
          "plasmashell"."activate task manager entry 6" = "Meta+6";
          "plasmashell"."activate task manager entry 7" = "Meta+7";
          "plasmashell"."activate task manager entry 8" = "Meta+8";
          "plasmashell"."activate task manager entry 9" = "Meta+9";
          "plasmashell"."clear-history" = [ ];
          "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
          "plasmashell"."cycle-panels" = "Meta+Alt+P";
          "plasmashell"."cycleNextAction" = [ ];
          "plasmashell"."cyclePrevAction" = [ ];
          "plasmashell"."manage activities" = "Meta+Q";
          "plasmashell"."next activity" = "Meta+A";
          "plasmashell"."previous activity" = "Meta+Shift+A";
          "plasmashell"."repeat_action" = [ ];
          "plasmashell"."show dashboard" = "Ctrl+F12";
          "plasmashell"."show-barcode" = [ ];
          "plasmashell"."show-on-mouse-pos" = "Meta+V";
          "plasmashell"."stop current activity" = "Meta+S";
          "plasmashell"."switch to next activity" = [ ];
          "plasmashell"."switch to previous activity" = [ ];
          "plasmashell"."toggle do not disturb" = [ ];
        };
        configFile = {
          "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
          "kactivitymanagerdrc"."activities"."f80d8bc2-3dca-4b95-8a4a-1cdaade18b4a" = "Default";
          "kactivitymanagerdrc"."main"."currentActivity" = "f80d8bc2-3dca-4b95-8a4a-1cdaade18b4a";
          "kcminputrc"."Mouse"."cursorSize" = 18;
          "kded5rc"."Module-device_automounter"."autoload" = false;
          "kdeglobals"."KDE"."SingleClick" = false;
          "kdeglobals"."KScreen"."ScaleFactor" = 2;
          "kdeglobals"."KScreen"."ScreenScaleFactors" = "eDP-1-1=2;DP-1-1=2;DP-1-2=2;DP-1-3=2;";
          "kdeglobals"."WM"."activeBackground" = "49,54,59";
          "kdeglobals"."WM"."activeBlend" = "252,252,252";
          "kdeglobals"."WM"."activeForeground" = "252,252,252";
          "kdeglobals"."WM"."inactiveBackground" = "42,46,50";
          "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
          "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
          "kglobalshortcutsrc"."ActivityManager"."_k_friendly_name" = "Activity Manager";
          "kglobalshortcutsrc"."KDE Keyboard Layout Switcher"."_k_friendly_name" = "Keyboard Layout Switcher";
          "kglobalshortcutsrc"."kaccess"."_k_friendly_name" = "Accessibility";
          "kglobalshortcutsrc"."kcm_touchpad"."_k_friendly_name" = "Touchpad";
          "kglobalshortcutsrc"."kmix"."_k_friendly_name" = "Audio Volume";
          "kglobalshortcutsrc"."ksmserver"."_k_friendly_name" = "Session Management";
          "kglobalshortcutsrc"."kwin"."_k_friendly_name" = "KWin";
          "kglobalshortcutsrc"."mediacontrol"."_k_friendly_name" = "Media Controller";
          "kglobalshortcutsrc"."org_kde_powerdevil"."_k_friendly_name" = "Power Management";
          "kglobalshortcutsrc"."plasmashell"."_k_friendly_name" = "plasmashell";
          "krunnerrc"."Plugins"."baloosearchEnabled" = false;
          "kscreenlockerrc"."Greeter/Wallpaper/org.kde.image/General"."Image" = "/nix/store/j0a8dikpffnkdr8wnqcza47dlw7m72sh-plasma-workspace-wallpapers-6.0.4/share/wallpapers/Cascade/";
          "kscreenlockerrc"."Greeter/Wallpaper/org.kde.image/General"."PreviewImage" = "/nix/store/j0a8dikpffnkdr8wnqcza47dlw7m72sh-plasma-workspace-wallpapers-6.0.4/share/wallpapers/Cascade/";
          "ksmserverrc"."General"."loginMode" = "emptySession";
          "kwalletrc"."Wallet"."First Use" = false;
          "kwinrc"."Desktops"."Id_1" = "4da6e43a-fe3b-4dab-9c1d-76d558a961f9";
          "kwinrc"."Desktops"."Number" = 1;
          "kwinrc"."Desktops"."Rows" = 1;
          "kwinrc"."Effect-overview"."BorderActivate" = 9;
          "kwinrc"."NightColor"."Active" = true;
          "kwinrc"."NightColor"."Mode" = "Constant";
          "kwinrc"."NightColor"."NightTemperature" = 5400;
          "kwinrc"."Tiling"."padding" = 4;
          "kwinrc"."Tiling/26175f77-cbd2-53fe-9f08-44f2222ad057"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
          "kwinrc"."Xwayland"."Scale" = 2;
          "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
          "plasmarc"."Wallpapers"."usersWallpapers" = "";
        };
      };
      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "23.11";
    };

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for electron wayland

  #   # dualboot
  #   time.hardwareClockInLocalTime = true;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ libsmbios ];
  systemd = {
    services = {
      dell-thermal-mode = {
        after = [ "post-resume.target" ];
        serviceConfig = {
          Type = "oneshot";
          Restart = "no";
          ExecStart = "${pkgs.libsmbios}/bin/smbios-thermal-ctl --set-thermal-mode=performance";
        };
        wantedBy = [
          "multi-user.target"
          "post-resume.target"
        ];
      };
    };
  };

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
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };


  # Load nvidia driver for Xorg and Wayland
  #   services.xserver.videoDrivers = [
  #     "intel"
  #     "nvidia"
  #   ];

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

  # for non root debug
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "probe_rs_udev";
      text = ''
                # Copy this file to /etc/udev/rules.d/
        # If rules fail to reload automatically, you can refresh udev rules
        # with the command "udevadm control --reload"

        # This rules are based on the udev rules from the OpenOCD project, with unsupported probes removed.
        # See http://openocd.org/ for more details.
        #
        # This file is available under the GNU General Public License v2.0

        ACTION!="add|change", GOTO="probe_rs_rules_end"

        SUBSYSTEM=="gpio", MODE="0660", GROUP="plugdev", TAG+="uaccess"

        SUBSYSTEM!="usb|tty|hidraw", GOTO="probe_rs_rules_end"

        # Please keep this list sorted by VID:PID

        # STMicroelectronics ST-LINK V1
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3744", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # STMicroelectronics ST-LINK/V2
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # STMicroelectronics ST-LINK/V2.1
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # STMicroelectronics STLINK-V3
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # SEGGER J-Link
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0102", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0103", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0104", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0107", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0108", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1001", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1002", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1003", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1004", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1005", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1006", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1007", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1008", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1009", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100a", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100b", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100c", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100d", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100e", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100f", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1010", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1011", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1012", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1013", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1014", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1016", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1017", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1018", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1019", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101a", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101b", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101c", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101d", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101e", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101f", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1020", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1021", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1022", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1023", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1024", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1025", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1026", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1027", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1028", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1029", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102a", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102b", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102c", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102d", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102e", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102f", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1050", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1051", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1052", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1053", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1054", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1055", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1056", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1057", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1058", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1059", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105a", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105b", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105c", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105d", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105e", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105f", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1060", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1061", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1062", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1063", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1064", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1065", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1066", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1067", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1068", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1069", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106a", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106b", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106c", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106d", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106e", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106f", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # FT232H
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="660", GROUP="plugdev", TAG+="uaccess"
        # FT2232x
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="660", GROUP="plugdev", TAG+="uaccess"
        # FT4232H
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # FTDI-based Olimex devices
        ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x0003", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x0004", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x002a", MODE="660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x002b", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # Espressif USB JTAG/serial debug unit
        ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="660", GROUP="plugdev", TAG+="uaccess"
        # Espressif USB Bridge
        ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1002", MODE="660", GROUP="plugdev", TAG+="uaccess"

        # CMSIS-DAP compatible adapters
        ATTRS{product}=="*CMSIS-DAP*", MODE="660", GROUP="plugdev", TAG+="uaccess"
        # WCH Link (CMSIS-DAP compatible adapter)
        ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="8011", MODE="660", GROUP="plugdev", TAG+="uaccess"

        LABEL="probe_rs_rules_end"
      '';
      destination = "/etc/udev/rules.d/69-probe-rs.rules";
    })
  ];

  # enable linux nonfree
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
