# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
        editor = false;
        netbootxyz.enable = true;
        configurationLimit = 8;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_6_7;
    kernelModules = ["acpi_call"];
    extraModulePackages = [config.boot.kernelPackages.acpi_call];

    kernelParams = ["quiet" "loglevel=3" "systemd.show_status=auto" "rd.udev.log_level=3"];
  };


  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      };
  };

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    OPENSSL_CONF = "/etc/openssl/openssl.cnf";
  };

  fonts = {
    enableGhostscriptFonts = true;
    enableDefaultPackages = true;
  };

  documentation = {
    enable = true;
    dev.enable = true;
  };

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = false;
    };
  };

  # Enable OpenGL
  hardware = {
    enableAllFirmware = true;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [
        vaapiVdpau
      ];
    };

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.production;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  sound.enable = true;

  services = {
    fstrim.enable = true;

    mullvad-vpn = {
      enable = true;
      enableExcludeWrapper = true;
      package = pkgs.mullvad-vpn;
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };

    xserver = {
      enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
      };

      displayManager.defaultSession = "plasmawayland";

      desktopManager.plasma5 = {
        enable = true;
        useQtScaling = true;

        bigscreen.enable = true;
      };

      videoDrivers = ["nvidia"];
      };

    printing.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users.foxkj = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" "eduroam"];
      hashedPassword = "$y$j9T$u8NldUWSzg7/J9KeQO6sF1$B.SsPsPMZlBoow0AzF/B/5f8kCWzlSR4E7aeWr/4vv4";
      description = "Fox Johnjulio";
    };
  };

  environment.systemPackages = let
    unstable = import <nixos-unstable> {};
    nixos-rebuild-commit = import ./nixos-rebuild-commit.nix {inherit pkgs;};
  in
    with pkgs; [
      git
      libnotify
      alejandra
      jdk8
      jdk11
      jdk17
      nil

      (unstable.appimage-run.override {
        extraPkgs = pkgs: [pkgs.libsecret];
      })

      xwayland
      nixos-rebuild-commit
      kate
      jetbrains-toolbox
      unstable.vesktop
      spotify

      (prismlauncher.override {
        additionalLibs = [vulkan-loader];
      })

      bitwarden
      megasync
      calibre
    ];

  programs = {
    kclock.enable = true;
    kdeconnect.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    java.enable = true;

    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "kphoen";
        plugins = ["sudo" "safe-paste" "history"];
      };
      enableBashCompletion = true;
    };

    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.location" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        "widget.use-xdg-desktop-portal.open-uri" = 1;
        "widget.use-xdg-desktop-portal.settings" = 1;
      };
    };

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        SDL
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        SDL_image
        SDL_mixer
        SDL_ttf
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        bzip2
        cairo
        cups
        curlWithGnuTls
        dbus
        dbus-glib
        desktop-file-utils
        e2fsprogs
        expat
        flac
        fontconfig
        freeglut
        freetype
        fribidi
        fuse
        fuse3
        gdk-pixbuf
        glew110
        glib
        gmp
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-ugly
        gst_all_1.gstreamer
        gtk2
        harfbuzz
        icu
        keyutils.lib
        libGL
        libGLU
        libappindicator-gtk2
        libcaca
        libcanberra
        libcap
        libclang.lib
        libdbusmenu
        libdrm
        libgcrypt
        libgpg-error
        libidn
        libjack2
        libjpeg
        libsecret
        libmikmod
        libogg
        libpng12
        libpulseaudio
        librsvg
        libsamplerate
        libthai
        libtheora
        libtiff
        libudev0-shim
        libusb1
        libuuid
        libvdpau
        libvorbis
        libvpx
        libxcrypt-legacy
        libxkbcommon
        libxml2
        mesa
        nspr
        nss
        openssl
        p11-kit
        pango
        pixman
        python3
        speex
        stdenv.cc.cc
        tbb
        udev
        vulkan-loader
        wayland
        xorg.libICE
        xorg.libSM
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXft
        xorg.libXi
        xorg.libXinerama
        xorg.libXmu
        xorg.libXrandr
        xorg.libXrender
        xorg.libXt
        xorg.libXtst
        xorg.libXxf86vm
        xorg.libpciaccess
        xorg.libxcb
        xorg.xcbutil
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilrenderutil
        xorg.xcbutilwm
        xorg.xkeyboardconfig
        xz
        zlib
      ];
    };
  };

  system = {
    copySystemConfiguration = true;
    stateVersion = "23.11";
  };

  systemd.services.wpa_supplicant.environment.OPENSSL_CONF = pkgs.writeText "openssl.cnf" ''
    openssl_conf = default_conf

    [ default_conf ]
    ssl_conf = ssl_sect

    [ ssl_sect ]
    system_default = system_default_sect

    [ system_default_sect ]
    CipherString = Default:@SECLEVEL=0
    Options = UnsafeLegacyRenegotiation
  '';
}
