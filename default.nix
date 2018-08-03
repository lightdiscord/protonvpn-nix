{ config, lib, pkgs, ... }:

with lib;

let
	cfg = config.services.openvpn.providers.protonvpn;

	configure = credentials: ''
		client
		dev tun
		proto udp

		remote ${cfg.country}.protonvpn.com 1194

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

		ca ${toString ./.vpn/ca.crt}

		key-direction 1
		tls-auth ${toString ./.vpn/tls-auth.key}
	'';
in {
	options.services.openvpn.providers.protonvpn = {
		enable = mkOption {
			type = types.bool;
			default = false;
			description = ''
				Whether to enable ProtonVPN.
			'';
		};

		country = mkOption {
			type = types.str;
			default = "fr";
			description = ''
				In which region you want to be connected.
			'';
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

	config = mkIf cfg.enable {
		assertions = [
			{
				assertion = cfg.credentials != null;
				message = "services.openvpn.providers.protonvpn.credentials must be set.";
			}
		];

		services.openvpn.servers.ProtonVPN = {
			config = configure cfg.credentials;
		};
	};
}
