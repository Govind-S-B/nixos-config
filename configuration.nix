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

  # --- hermes-agent ---
  # Everything hermes-related lives inside ~/HERMES/ (stateDir). The module
  # puts the actual brain at ~/HERMES/.hermes/, workspace at ~/HERMES/workspace/,
  # etc. Nothing leaks outside ~/HERMES/.

  # Render a systemd-format env file from the raw opencode_key secret.
  # Lives on tmpfs at /run/secrets-rendered/; auto-restart on content change.
  sops.templates."hermes_env" = {
    content = ''
      OPENCODE_ZEN_API_KEY=${config.sops.placeholder.opencode_key}
    '';
    owner = "vio";
    restartUnits = [ "hermes-agent.service" ];
  };

  services.hermes-agent = {
    enable = true;
    user = "vio";
    group = "users";
    stateDir = "/home/vio/HERMES";
    createUser = false;
    settings.model = {
      provider = "opencode-zen";
      default = "minimax-m2.5-free";
    };
    # environmentFiles intentionally unset -> module writes no .env to disk
  };

  # Inject the API key via systemd EnvironmentFile instead of the module's
  # on-disk .env merge. Keeps the secret on tmpfs only.
  systemd.services.hermes-agent.serviceConfig.EnvironmentFile =
    config.sops.templates."hermes_env".path;

  services.openssh.enable = true;
  services.openssh.settings = {
    Banner = "/etc/banner.txt";
  };
  environment.etc."banner.txt".text = lib.readFile ./banner.txt;
  services.tailscale.enable = true;

  system.stateVersion = "25.11";
}
