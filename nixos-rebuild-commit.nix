{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "nixos-rebuild-commit";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "Undercoverer";
    repo = "NixOS-Config";
    rev = "1690993";
    hash = "sha256-nszqES4DwopoGM8NR9sieDsx5Nl/tExFKqYr1AWXr7o=";
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
