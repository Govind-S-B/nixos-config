{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "claude-code"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixchan";
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  time.timeZone = "Asia/Kolkata";

  users.users.vio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    kitty.terminfo
    sops
    age
    fastfetch
  ];

  # --- sops-nix secrets ---
  # Backup: ~/.config/sops/age/keys.txt (age private key)
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/vio/.config/sops/age/keys.txt";
  sops.age.generateKey = false;

  sops.secrets.openrouter_key = {
    owner = "vio";
  };

  sops.secrets.opencode_key = {
    owner = "vio";
  };

  services.openssh.enable = true;
  services.openssh.settings = {
    Banner = "/etc/banner.txt";
  };
  environment.etc."banner.txt".text = lib.readFile ./banner.txt;
  services.tailscale.enable = true;

  system.stateVersion = "25.11";
}
