{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.openvpn.providers.protonvpn;

  configure = { credentials, region }: ''
	  client
	  dev tun
	  proto udp

	  remote ${region}.protonvpn.com 80
	  remote ${region}.protonvpn.com 443
	  remote ${region}.protonvpn.com 4569
	  remote ${region}.protonvpn.com 1194
	  remote ${region}.protonvpn.com 5060

	  remote-random
	  resolv-retry infinite
	  nobind
	  cipher AES-256-CBC
	  auth SHA512
	  comp-lzo
	  verb 3

	  tun-mtu 1500
	  tun-mtu-extra 32
	  mssfix 1450
	  persist-key
	  persist-tun

	  ping 15
	  ping-restart 0
	  ping-timer-rem
	  reneg-sec 0

	  remote-cert-tls server
	  auth-user-pass ${toString credentials}
	  pull
	  fast-io

	  ca ${toString ./vpn/ca.crt}

	  key-direction 1
	  tls-auth ${toString ./vpn/tls-auth.key}
  '';

  makeProvider = { credentials, region, autoStart ? false, updateResolvConf ? true, ... }: {
	inherit autoStart updateResolvConf;
	config = configure {
	  inherit credentials region;
	};
  };

  mapCountry = { region, ... }@country: nameValuePair
	"protonvpn-${region}"
	(makeProvider (country // { inherit (cfg) credentials; }));

  countryModule = {
	region = mkOption {
		type = types.enum (import ./regions.nix);
		example = "fr";
		description = ''
			In which region you want to be connected.
		'';
	};
	autoStart = mkOption {
		default = false;
		type = types.bool;
		description = ''
			Whether this instance should be started automatically.
		'';
	};
	updateResolvConf = mkOption {
		default = true;
		type = types.bool;
	};
  };

in {
  options.services.openvpn.providers.protonvpn = {
	countries = mkOption {
	  default = {};
	  type = types.listOf (types.submodule ({ options = countryModule;}));
	};

	credentials = mkOption {
	  type = types.path;
	  example = "/home/username/.protonvpn.credentials";
	  description = ''
		  Path to the file containing your ProtonVPN OpenVPN credentials.

		  The file must contain two lines, the first one is your login and the last
		  one your password.
	  '';
	};
  };

  config = mkIf (length cfg.countries > 0) {
	assertions = [
	  {
		assertion = cfg.credentials != null;
		message = "services.openvpn.providers.protonvpn.credentials must be set.";
	  }
	];

	services.openvpn.servers = listToAttrs (map mapCountry cfg.countries);
  };
}
