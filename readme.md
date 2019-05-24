# ProtonVPN with Nix

Configure ProtonVPN with your NixOS configuration.

---

## Quick Start

### Credential file.

Create a file where you want with two lines, your login and your password.

```
login
password
```

### Nix Configuration.

```nix
{ config, pkgs, ... }:

let
	credentials = /path/to/credentials; # The path to your credential file.
in {
	imports = [
		(builtins.fetchTarball https://github.com/LightDiscord/ProtonVPN-Nix/archive/master.tar.gz)
	];

  	services.openvpn.providers.protonvpn = {
		# The list of available regions can be found in the regions.nix file
		countries = [
			{ region = "fr"; autoStart = true;  }
			{ region = "us"; }
			{ region = "ca"; }
		];

		inherit credentials;
  	};
}
```
