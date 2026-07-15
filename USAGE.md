#IMPORTANT: Read notes at end of file

# protonvpn-random

protonvpn-random is a small Bash tool for the **Proton VPN command-line interface**.

It uses the `protonvpn` CLI command. It does **not** control the Proton VPN desktop application or its graphical interface.

The script connects to random Proton VPN locations and can automatically change the connection after a random amount of time.

> protonvpn-random is built from small, independent functions that work together like gears — robust, easy to read, and simple to adapt.

## Features

* Connects to random Proton VPN countries
* Supports a preferred main country
* Configurable probability for the main country
* Configurable probability for Secure Core
* Configurable random connection switch time
* Retries failed connections with increasing delays
* Granular control over desktop notifications (global mute, error, success, exit)
* Validates the entire configuration before starting
* Clean exit codes for troubleshooting

## Requirements

The following commands must be available:

* `bash`
* `protonvpn`
* `notify-send`
* `tput`

The Proton VPN CLI must already be installed, configured and logged in.

## Configuration

Open the script in a text editor and edit the configuration section at the top.

### Main location

```bash
MAIN_LOCATION="DE"
PROBABILITY_MAIN_LOCATION=50
```

`MAIN_LOCATION` is the preferred country.

`PROBABILITY_MAIN_LOCATION` controls how often it is selected:

* `0` — never use the main location
* `50` — use it for about 50 percent of connections
* `100` — always use it

Country codes must contain two uppercase letters and are simular with proton country codes, for example:

```text
DE
NL
FR
CH
```

### Random country pool

```bash
RANDOM_POOL=(
    "DE"
    "BE"
    "NL"
    "PL"
    "FR"
    "CH"
    "AT"
    "CZ"
)
```

Add or remove countries as needed.

A country from this list is selected when the main location is not selected.

You should not add the main location to this pool unless you want to increase its total probability.

### Secure Core

```bash
PROBABILITY_SECURECORE=50
```

This controls how often Secure Core is used:

* `0` — disabled
* `50` — use it for about 50 percent of connections
* `100` — always use it

### Random switch time

```bash
SECONDS_SWITCH_VPN_MIN=3600
SECONDS_SWITCH_VPN_MAX=7200
```

The script selects a random waiting time between these values.

In this example, the VPN connection changes after a random time between one and two hours.

### Automatic switching

```bash
SWITCH_VPN_ONOFF="ON"
```

Available values:

* `ON` — continue changing random the VPN connection
* `OFF` — connect once and stop the script

When set to `OFF`, the established VPN connection remains active after the script exits.

### Failed connections

```bash
MAX_CON_FAILS=3
```

This controls how many failed retry attempts are allowed before the script exits.

The waiting time between failed attempts increases automatically.

## Usage

### Run the script directly

Make the script executable:

```bash
chmod +x protonvpn-random
```

Run it:

```bash
./protonvpn-random
```

It can also be started with Bash:

```bash
bash protonvpn-random
```

The terminal shows the remaining time before the next connection change.

### Install it as a command

Copy the script to `/usr/local/bin`:

```bash
sudo cp protonvpn-random /usr/local/bin/protonvpn-randomizer
sudo chmod 755 /usr/local/bin/protonvpn-randomizer
```

It can then be started from any directory:

```bash
protonvpn-randomizer
```

The configuration remains inside the copied script.

Edit it with:

```bash
sudo nano /usr/local/bin/protonvpn-randomizer
```

### Start it automatically after desktop login

The script can be added to the desktop autostart configuration.

Create the autostart directory if it does not exist:

```bash
mkdir -p "$HOME/.config/autostart"
```

Create this file:

```text
~/.config/autostart/protonvpn-randomizer.desktop
```

Example content:

```ini
[Desktop Entry]
Type=Application
Name=protonvpn-random
Comment=Automatically changes Proton VPN CLI connections
Exec=/usr/local/bin/protonvpn-randomizer
Terminal=true/false
StartupNotify=false
```

`Terminal=true`  the script displays information in terminala `tput`.
`Terminal=false`  script runs in background.


## Exit codes

* `0` — normal exit
* `1` — any failure
* `10` — missing dependency
* `11` — invalid configuration

Display the last exit code with:

```bash
echo "$?"
```

## Notes
The script depends on the commands and options provided by the Proton VPN CLI. Future changes to the CLI may require changes to the script.

## IMPORTANT: ----------------------------------------------------------
## IMPORTANT: Kill Switch during server changes IMPORTANT 
## IMPORTANT: ----------------------------------------------------------

For maximum protection between connection changes, you should still consider testing and using a separate, permanent Kill Switch configuration.

BUT:

The Proton VPN documentation states that the Kill Switch remains active during a server change.
The expected connection flow is:

```text
CONNECTED
    ↓ new connect command
DISCONNECTING
    ↓ the current VPN connection is closed
DISCONNECTED with a stored reconnection request
    ↓ the Kill Switch is enabled or confirmed
CONNECTING
    ↓ only traffic required to reach the new VPN server is allowed
CONNECTED
```

This ensures your IP should never exposed during the transition. It directly sends a new `protonvpn connect` command and lets the Proton VPN CLI handle the protected reconnection process.

