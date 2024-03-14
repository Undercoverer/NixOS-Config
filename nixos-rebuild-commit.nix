{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nixos-rebuild-commit";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Undercoverer";
    repo = "NixOS-Config";
    rev = "1690993";
    sha256 = "169099326e45479d54d123e64410b8533c44f5a4";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp nixos-rebuild-commit $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "Safe build / install + git integration";
    homepage = "https://github.com/Undercoverer/NixOS-Config";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
