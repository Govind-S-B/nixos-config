{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.shellAliases = {
    rebuild = "cd ~/nixos-config && git add . && sudo nixos-rebuild switch --flake .#nixchan";
  };

  # Wrapper scripts that inject secrets only into the launched process
  # Secrets are read from /run/secrets/ (decrypted by sops-nix at activation)
  home.packages = with pkgs; [
    claude-code
    (writeShellScriptBin "ccfree" ''
      export ANTHROPIC_AUTH_TOKEN=$(cat /run/secrets/openrouter_key)
      export ANTHROPIC_API_KEY=""
      export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
      export CLAUDE_CODE_DISABLE_AUTOUPDATE=1
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
