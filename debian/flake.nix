{
  description = "A simple development environment";

  # The Nixpkgs version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }: {

    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        zsh
        git
        htop
        xdg-user-dirs
        lsd
        neovim
        python39
        nodejs_18
        fzf
        ripgrep
        lazygit
        kubectl
        k9s
        kind
        helm
        jdk11
        gh
        unzip
        terraform
        ranger
      ];

      # Shell Hook to make zsh the default shell when entering the environment.
      shellHook = ''
        if [ -n "$PS1" ]; then
          exec zsh
        fi
      '';
    };

  };
}
