{pkgs}:
pkgs.stdenv.mkDerivation rec {
  pname = "nixos-rebuild-commit";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "Undercoverer";
    repo = "NixOS-Config";
    rev = "23f91f2";
    sha1 = "AsUlmdcwrFH+vsoyCMYvTiuaOLE=";
  };

  installPhase = ''
    install -D nixos-rebuild-commit $out/bin/nixos-rebuild-commit
  '';

  meta = with pkgs.lib; {
    description = "Safe build / install + git integration";
    homepage = "https://github.com/Undercoverer/NixOS-Config";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
