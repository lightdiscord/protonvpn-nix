import <nixpkgs/nixos/tests/make-test.nix> {
	machine = { config, pkgs, ... }: {
		imports = [
			./../default.nix
		];
	};

	testScript = ''
		$machine->waitForUnit("multi-user.target");
	'';
}
