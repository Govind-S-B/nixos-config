{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";

  home.shellAliases = {
    rebuild = "cd ~/nixos-config && git add . && sudo nixos-rebuild switch --flake .#nixchan";
  };

  programs.bash.enable = true;

  programs.git = {
    enable = true;
    signing.format = null;
    settings.user = {
      name = "Govind S B";
      email = "b.s.dnivog@gmail.com";
    };
  };
}
