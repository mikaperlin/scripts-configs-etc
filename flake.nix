{
  description = "NixOS and Home Manager configuration of perlinm";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-23.05"; };
    nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    with inputs;
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      nixos-configs = {
        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "22.11"; # Did you read the comment?

        # system.autoUpgrade.enable = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # use the Zen linux kernel (others mignt not work!)
        boot.kernelPackages = pkgs.linuxPackages_zen;

        # bootloader
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # setup keyfile for encrypted hard drive
        boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

        # Enable swap on luks
        boot.initrd.luks.devices."luks-6584249e-94c5-4559-a9e8-3654b2b164ae".device =
          "/dev/disk/by-uuid/6584249e-94c5-4559-a9e8-3654b2b164ae";
        boot.initrd.luks.devices."luks-6584249e-94c5-4559-a9e8-3654b2b164ae".keyFile =
          "/crypto_keyfile.bin";

        # internationalization properties
        # WARNING: these are ignored by some desktop environments (such as GNOME)
        time.timeZone = "America/Chicago";
        i18n.defaultLocale = "en_US.utf8";
        i18n.extraLocaleSettings.LC_TIME = "en_GB.utf8";

        # networking options
        networking.hostName = "map-work";
        networking.networkmanager.enable = true;

        # keyboard layout in the console
        console.keyMap = "colemak";

        # define user
        users.users.perlinm = {
          isNormalUser = true;
          description = "Michael A. Perlin";
          extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
          shell = pkgs.zsh;
        };
        programs.zsh.enable = true;

        # X11 services
        services.xserver = {
          enable = true;

          # keyboard layout
          layout = "us";
          xkbVariant = "colemak";
          autoRepeatDelay = 200;
          autoRepeatInterval = 60;

          # display (login), desktop, and window managers
          displayManager.gdm.enable = true;
          displayManager.autoLogin.enable = true;
          displayManager.autoLogin.user = "perlinm";

          desktopManager.xterm.enable = false;
          desktopManager.gnome.enable = true;

          windowManager.i3.enable = true;
          displayManager.defaultSession = "none+i3";

          # touchpad
          libinput.enable = true;
          libinput.touchpad = {
            naturalScrolling = true;
            clickMethod = "clickfinger";
            disableWhileTyping = true;
          };
        };

        # # enable sway window manager
        # programs.sway.enable = true;
        # programs.sway.wrapperFeatures.gtk = true;
        # programs.xwayland.enable = true;
        # xdg.portal = sway-fixes.xdg-portal;
        # environment.systemPackages = sway-fixes.packages;

        # sound and bluetooth control
        sound.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };
        hardware.pulseaudio.enable = false;
        hardware.bluetooth.enable = true;
        hardware.bluetooth.package = pkgs.bluezFull;

        # change some power settings
        services.logind.lidSwitch = "ignore";
        services.logind.extraConfig = "HandlePowerKey=suspend";

        # miscellaneous utilities 
        security.rtkit.enable = true; # schedule user processes/threads
        security.polkit.enable = true; # fine-grained authentication agent
        services.dbus.enable = true; # interprocess communications manager
        services.udisks2.enable = true; # automounting external drives
        services.printing.enable = true; # enable CUPS to print documents

        # make home-manager use global install paths and package configurations
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      };

    in {
      nixosConfigurations.map-work = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          ./hardware-configuration.nix # results of hardware scan
          home-manager.nixosModules.home-manager
          nixos-configs
        ];
      };

      homeConfigurations.perlinm = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit unstable; };
      };
    };
}
