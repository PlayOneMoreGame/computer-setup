#!/bin/zsh

{
    if ! which nix; then
        echo "nix not installed"
        exit 1
    fi

    if ! which git | grep nix-profile; then
        echo "installing git..."
        nix profile install nixpkgs#git
        nix profile install nixpkgs#git-lfs
    fi

    if ! which direnv | grep nix-profile; then
        echo "installing direnv..."
        nix profile install nixpkgs#direnv
    fi 

    if ! which gpg | grep nix-profile; then
        echo "installing gpg..."
        nix profile install nixpkgs#gnupg
    fi

    if ! which p4 | grep nix-profile; then
        echo "installing p4 command line tools..."
        nix profile install nixpkgs#p4
    fi

    if [[ ! -e "/Users/$USER/.ssh/id_ed25519" ]]; then
        echo "generating starter ssh keys..."
        ssh-keygen -t ed25519 -C "awesome@onemoregame.com" -f ~/.ssh/id_ed25519 -q -N ""
    fi

    touch "/Users/$USER/.zshrc"

    if ! grep -q "PATH=\$PATH:\$HOME/.nix-profile/bin" "/Users/$USER/.zshrc"; then
        echo "Adding nix-profile bin to the path..."
        echo "PATH=\$PATH:\$HOME/.nix-profile/bin" >>"/Users/$USER/.zshrc"
    fi

    if ! grep -q "eval \"\$(direnv hook zsh)\"" "/Users/$USER/.zshrc"; then
        echo "Adding direnv hook..."
        echo "eval \"\$(direnv hook zsh)\"" >>"/Users/$USER/.zshrc"
    fi

    source "/Users/$USER/.zshrc"

    if ! p4 info | grep P4CONFIG=p4config.txt; then
        p4 set P4CONFIG=p4config.txt
    fi
    if ! p4 info | grep P4IGNORE=p4ignore.txt; then
        p4 set P4IGNORE=p4ignore.txt
    fi
    if ! p4 info | grep P4PORT=ssl:p4.core.onemoregame.live:1666; then
        p4 set P4PORT=ssl:p4.core.onemoregame.live:1666
    fi
    if ! p4 info | grep P4CHARSET=utf8; then
        p4 set P4CHARSET=utf8
    fi

} 2>&1 | tee -a "/Users/$USER/nixconfig.log"

