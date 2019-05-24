# ProtonVPN with Nix

Configure ProtonVPN with your NixOS configuration.

---

## Quick Start

### A file containing your credentials

Create a file where you want with two lines, your login and your password.

```
login
password
```

### And nixos configuration

```nix
{
	imports = [
		(builtins.fetchTarball https://github.com/LightDiscord/protonvpn-nix/archive/master.tar.gz)
	];

  	services.openvpn.providers.protonvpn = {
		# The path to the file containing your credentials.
		credentials = /path/to/credentials;

		# The list of available regions can be found in the regions.nix file
		countries = [
			{ region = "fr"; autoStart = true;  }
			{ region = "us"; }
			{ region = "ca"; }
		];
  	};
}
```
