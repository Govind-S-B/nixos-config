{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://openrouter.ai/api";
    ANTHROPIC_API_KEY = "";
    CLAUDE_CODE_DISABLE_AUTOUPDATE = "1";
  };

  home.shellAliases = {
    rebuild = "cd ~/nixos-config && git add . && sudo nixos-rebuild switch --flake .#nixchan";
  };

  # Wrapper scripts that inject secrets only into the launched process
  # Secrets are read from /run/secrets/ (decrypted by sops-nix at activation)
  home.packages = with pkgs; [
    nodejs
    (writeShellScriptBin "ccfree" ''
      export ANTHROPIC_AUTH_TOKEN=$(cat /run/secrets/anthropic_auth_token)
      exec claude --model openrouter/free --dangerously-skip-permissions "$@"
    '')
  ];

  programs.bash.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "Govind S B";
      email = "b.s.dnivog@gmail.com";
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    terminal = "screen-256color";
  };
}
