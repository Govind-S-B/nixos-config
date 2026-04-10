{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
  ];

  # --- sops-nix secrets ---
  # Prerequisites:
  #   1. Age private key lives at ~/.config/sops/age/keys.txt (per-user, no sudo needed)
  #   2. Public key: age1h7uel0m80hl28q958md6856ssjyjsw83qkhhatnhz0qysax6s4lqqgxf9z
  #   3. .sops.yaml in this repo maps secrets.yaml to that key
  #   4. To edit secrets:  sops ~/nixos-config/secrets.yaml
  #   5. To add a new key: add it in sops editor, then reference it below with sops.secrets.<name>
  #   6. Each secret is decrypted to /run/secrets/<name> at activation
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/vio/.config/sops/age/keys.txt";
  sops.age.generateKey = false;

  sops.secrets.anthropic_auth_token = {
    owner = "vio";
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "25.11";
}
