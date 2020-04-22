#!/usr/bin/env bash
#
# Installed to a Windows host by `windows-buildkite-setup.ps1` and used
# as the entrypoint for WSL. This entrypoint updates Ubuntu and install
# the necessary packages to run a Buildkite Agent. Finally, the script
# execs to `buildkite-agent start` effectively turning the WSL process
# into a buildkite-agent.
#
# The script requires a single argument of a filepath pointing to a
# an environment configuration file with a set of keypairs to configure
# the environment of the buildkite-agent. The keypairs are secrets used
# by our buildkite pipelines. See below for the required keypairs. Values
# for the keypairs can be found in 1Password.
#
# Usage:
#   windows-buildkite-entrypoint /path/to/config.env
#
# shellcheck disable=SC1090

set -euo pipefail

if [ ! -f "$1" ]; then
    echo "ERROR: unable to load environment configuration, $1"
    exit 1
fi

source "$1"

# Disable interactive prompts from debian/ubuntu packages when upgrading apt
export DEBIAN_FRONTEND=noninteractive
export BUILDKITE_AGENT_TAGS="os=wsl"
APT_SOURCE_LIST=/etc/apt/sources.list.d/buildkite-agent.list

if [ ! -f "$APT_SOURCE_LIST" ]; then
    echo "Installing Buildkite apt-key..."
    echo "deb https://apt.buildkite.com/buildkite-agent stable main" | tee "$APT_SOURCE_LIST"
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
fi

echo "Updating Ubuntu..."
apt-get update -y

if ! command -v buildkite-agent &>/dev/null; then
    echo "Installing Buildkite Agent..."
    apt-get install -y buildkite-agent
fi

echo "Upgrading Ubuntu..."
apt-get upgrade -y

echo "Adding SSH Key..."
mkdir -p "$HOME/.ssh"
echo "$OMG_BUILDKITE_PRIVATE_KEY" >"$HOME/.ssh/id_rsa"
echo "$OMG_BUILDKITE_PUBLIC_KEY" >"$HOME/.ssh/id_rsa.pub"
chmod 0600 "$HOME/.ssh/id_rsa"
chmod 0644 "$HOME/.ssh/id_rsa.pub"

if ! grep -q nixbld /etc/group; then
    echo "Installing Nix build users/group..."
    groupadd -r nixbld
    for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n"; done
fi

echo "Running omg system setup..."
curl -fsSL https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/unix-host-setup | bash
source "$HOME/.nix-profile/etc/profile.d/nix.sh"

exec buildkite-agent start
