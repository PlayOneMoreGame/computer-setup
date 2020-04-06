#!/usr/bin/env bash
#
# Prepares a user's workstation to interact with a One More Game software
# project. OMG leverages Nix and Direnv to configure development
# environments on a per-project basis which is also contextual to the
# user's current working directory within their shell.
#
# shellcheck disable=SC1091

set -euo pipefail

readonly NIXSH="$HOME/.nix-profile/etc/profile.d/nix.sh"
readonly OMG_CONFIG_DIR="$HOME/.config/omg"
OS=""

if [ -f /etc/os-release ]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$NAME
elif type lsb_release >/dev/null 2>&1; then
  # linuxbase.org
  OS=$(lsb_release -si)
elif [ -f /etc/lsb-release ]; then
  # For some versions of Debian/Ubuntu without lsb_release command
  . /etc/lsb-release
  OS=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
  # Older Debian/Ubuntu/etc.
  OS=Debian
else
  # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
  OS=$(uname -s)
fi

tmpDir="$(mktemp -d -t nix-binary-tarball-unpack.XXXXXXXXXX ||
  oops "Can't create temporary directory for downloading the Nix binary tarball")"

cleanup() {
  rm -rf "$tmpDir"
}

trap cleanup EXIT INT QUIT TERM

require_util() {
  command -v "$1" >/dev/null 2>&1 ||
    oops "you do not have '$1' installed, which I need to $2"
}

function source_nix() {
  # shellcheck disable=2034
  MANPATH="" # Required to be set to a value for sourcing the profile below
  # shellcheck disable=1090
  source "$NIXSH"
}

function setup_debian() {
  # Disable interactive prompts from debian/ubuntu packages when upgrading apt
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update
  sudo apt-get install -y curl

  if is_wsl; then
    packageDeb="$tmpDir/packages-microsoft-prod.deb"
    wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O $packageDeb
    sudo dpkg -i $packageDeb
    sudo add-apt-repository universe
    sudo apt-get update
    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get install dotnet-sdk-3.1
    sudo apt-get install aspnetcore-runtime-3.1
    sudo apt-get install dotnet-runtime-3.1
  fi
}

function setup_linux() {
  if command -v curl &>/dev/null; then
    return 0
  fi
  local OS=""
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    # shellcheck disable=1091
    . /etc/os-release
    OS=$NAME
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    # shellcheck disable=1091
    . /etc/lsb-release
    OS=$DISTRIB_ID
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
  fi
  case "${OS,,}" in
  ubuntu* | debian*)
    setup_debian
    ;;
  *)
    echo "Unsupported Linux distribution: $OS"
    echo "Manually install 'curl' and ensure it is on your path and try again."
    exit 1
    ;;
  esac
}

function install_nix() {
  case "$(uname -s).$(uname -m)" in
  Linux.x86_64)
    system=x86_64-linux
    hash=bd4cb069d16417ba4aadc5bb005fdb263823990352f9d37c5b763a0bd145394f
    ;;
  Linux.i?86)
    system=i686-linux
    hash=79776189f9b7f6b4a54faf174912a57b272ffc4f6890e17e7ccc7f7d727e4478
    ;;
  Linux.aarch64)
    system=aarch64-linux
    hash=e7bad8aae8f2e5ab101055dc14211465191d4eecf530a2a7c2721569410178fb
    ;;
  Darwin.x86_64)
    system=x86_64-darwin
    hash=856cb6b62e32129c06b5ce7e3f3f22077c8fad8447cab5518c718b6f4107d8d7
    ;;
  *) oops "sorry, there is no binary distribution of Nix for your platform" ;;
  esac

  url="https://nixos.org/releases/nix/nix-2.3.2/nix-2.3.2-$system.tar.xz"

  tarball="$tmpDir/$(basename "$tmpDir/nix-2.3.2-$system.tar.xz")"

  require_util curl "download the binary tarball"
  require_util tar "unpack the binary tarball"

  echo "downloading Nix 2.3.2 binary tarball for $system from '$url' to '$tmpDir'..."
  curl -L "$url" -o "$tarball" || oops "failed to download '$url'"

  if command -v sha256sum >/dev/null 2>&1; then
    hash2="$(sha256sum -b "$tarball" | cut -c1-64)"
  elif command -v shasum >/dev/null 2>&1; then
    hash2="$(shasum -a 256 -b "$tarball" | cut -c1-64)"
  elif command -v openssl >/dev/null 2>&1; then
    hash2="$(openssl dgst -r -sha256 "$tarball" | cut -c1-64)"
  else
    oops "cannot verify the SHA-256 hash of '$url'; you need one of 'shasum', 'sha256sum', or 'openssl'"
  fi

  if [ "$hash" != "$hash2" ]; then
    oops "SHA-256 hash mismatch in '$url'; expected $hash, got $hash2"
  fi

  unpack=$tmpDir/unpack
  mkdir -p "$unpack"
  tar -xf "$tarball" -C "$unpack" || oops "failed to unpack '$url'"

  script=$(echo "$unpack"/*/install)

  [ -e "$script" ] || oops "installation script is missing from the binary tarball!"
  "$script" "$@"
}

function is_wsl() {
  if [[ $(uname -r) =~ icrosoft ]]; then
    return 0
  else
    return 1
  fi
}

# Perform additional OS-specific setup
case "$OSTYPE" in
darwin*) ;;
linux*)
  setup_linux
  ;;
msys* | cygwin*) ;;
*)
  echo >&2 "Unknown OS: $OSTYPE"
  exit 1
  ;;
esac

install_nix
source_nix

if ! command direnv &>/dev/null; then
  echo "Installing direnv..."
  nix-env -i direnv
fi

if ! command git &>/dev/null; then
  echo "Installing git..."
  nix-env -i git
fi

if ! command git-lfs &>/dev/null; then
  echo "Installing git-lfs..."
  nix-env -i git-lfs
fi

# Setup OMG shell configuration
mkdir -p "$OMG_CONFIG_DIR"

if [ -f "$HOME/.bashrc" ]; then
  if ! grep 'eval "$(direnv hook bash)"' "$HOME/.bashrc" &>/dev/null; then
    echo "" >>"$HOME/.bashrc"
    echo "eval \"\$(direnv hook bash)\"" >>"$HOME/.bashrc"
  fi
fi

if [ -f "$HOME/.zshrc" ]; then
  if ! grep 'eval "$(direnv hook zsh)"' "$HOME/.zshrc" &>/dev/null; then
    echo "" >>"$HOME/.zshrc"
    echo "eval \"\$(direnv hook zsh)\"" >>"$HOME/.zshrc"
  fi
fi

echo ""
echo "***************"
echo "Setup complete!"
echo "***************"
echo ""
echo "Please restart your shell before continuing."
echo ""
echo "Once your shell has been restarted, you will need to allow the source tree's"
echo "direnv configuration to modify your shell by running:"
echo ""
echo "    $ direnv allow"
echo ""
echo "Direnv will populate your shell environment and modify it's path to include"
echo "all of the tools you will need to work with the OMG development environment."

if is_wsl; then
  echo ""
  echo "IMPORTANT: You are running on WSL (Windows Subsytem for Linux), and so it"
  echo "may be necessary to restart your WSL session using \`wsl.exe --shutdown\`"
  echo "in order for changes to your \`.profile\` file to be sourced."
fi
