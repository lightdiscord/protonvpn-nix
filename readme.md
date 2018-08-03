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
	country = "fr"; # The server region you want to be connected to.
	credentials = /path/to/credentials; # The path to your credential file.
in {
	imports = [
		(builtins.fetchTarball https://github.com/LightDiscord/ProtonVPN-Nix/archive/master.tar.gz)
	];

  	services.openvpn.providers.protonvpn = {
  	  enable = true;
  	  inherit country credentials;
  	};
}
```
