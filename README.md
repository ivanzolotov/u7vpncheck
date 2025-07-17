# u7vpncheck

**Repository:** [github.com/ivanzolotov/u7vpncheck](https://github.com/ivanzolotov/u7vpncheck)

## Description

This is a simple script to verify that a VPN connection (based on a `.ovpn` config) is correctly established and that the external IP address matches the expected VPN IP.

## Requirements

- macOS
- `openvpn` (installed via Homebrew)
- `curl` (pre-installed on macOS)

## Installation

While in the project directory:

```bash
chmod +x u7vpncheck.sh
ln -s "$(pwd)/u7vpncheck.sh" "$HOME/bin/u7vpncheck"
```

Make sure `$HOME/bin` is added to your `$PATH` in `~/.zshrc`:

```sh
export PATH="$HOME/bin:$PATH"
source ~/.zshrc
```

## Configuration

Create a file named `u7vpncheck.conf` in the same directory as the script with the following content:

```bash
CONFIG="/path/to/your.ovpn"
EXPECTED_VPN_IP="XXX.XXX.XXX.XXX"
```

## Usage

```sh
u7vpncheck
```

Exit codes:

- `0` — VPN is active and the external IP matches the expected value
- `1` — VPN connection failed or IP address mismatch

The script will automatically disconnect the VPN session after the check.