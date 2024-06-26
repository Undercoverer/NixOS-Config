# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

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

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = ["acpi_call" "kvm-amd"];
    extraModulePackages = [config.boot.kernelPackages.acpi_call];

    kernelParams = [
      "mem_sleep_default=deep"
      "pcie_aspm.policy=powersupersave"
      "acpi.prefer_microsoft_dsm_guid=1"
    ];

    blacklistedKernelModules = [ "nouveau" ];
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };
  };

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };

  fonts = {
    enableGhostscriptFonts = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
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

  virtualisation.waydroid.enable = true;

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = false;
    };
  };

  # Enable OpenGL
  hardware = {
    enableAllFirmware = true;

    amdgpu.loadInInitrd = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
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
#       powerManagement.finegrained = true;

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
          Experimental = "true";
          ControllerMode = "dual";
          JustWorksRepairing = "always";
          KernelExperimental = "true";
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

    printing = {
      enable = true;
      cups-pdf = {
        enable = true;
        instances = {
          pdf = {
            settings = {
              Out = "\${HOME}/cups-pdf";
              UserUMask = "0033";
            };
          };
        };
      };
    };
  };


  users = {
    defaultUserShell = pkgs.zsh;

    users.foxkj = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "docker" "eduroam"];
      hashedPassword = "$y$j9T$u8NldUWSzg7/J9KeQO6sF1$B.SsPsPMZlBoow0AzF/B/5f8kCWzlSR4E7aeWr/4vv4";
      description = "Fox Johnjulio";
    };
  };

  environment.systemPackages = let
    unstable = import <nixos-unstable> { config.allowUnfree = true; };
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

      (import ./gitbutler-package/gitbutler-package.nix {inherit pkgs unstable;})

      xwayland
      nixos-rebuild-commit
      kate
      jetbrains-toolbox
      unstable.vesktop
      spotify

      (prismlauncher.override {
        additionalLibs = [vulkan-loader];
      })

      jupyter-all
      bitwarden
      megasync
      calibre
      libreoffice-qt
      ungoogled-chromium
      zoom-us
      unstable.postman
      vlc
      ffmpeg
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
      libraries = import ./ld-libraries.nix {pkgs = pkgs;};
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
    Options = UnsafeLegacyRenegotiation
  '';

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

}
