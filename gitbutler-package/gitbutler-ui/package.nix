{ lib
, mkYarnPackage
, fetchYarnDeps
, fetchFromGitHub
}:

mkYarnPackage rec {
  pname = "gitbutler-ui";
  version = "0.10.27";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    rev = "release/${version}";
    hash = "sha256-Y8LurSQKhjHX3RUiuOdHtPkZK5NKmx3eqQ5NGtnhMlY=";
  };

  sourceRoot = "${src.name}/gitbutler-ui";

  # The package.json must use spaces instead of upstream's tabs to pass Nixpkgs
  # CI.
  # To generate the Yarn lockfile, run `yarn install`.
  # There is no way to import the tagged pnpm lockfile, so make sure to test the
  # result thoughly as dependency versions may differ from the release.
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    hash = "sha256-rggtkfE6An8It0Rvgfk0J8JHpg0NbLiweRsz0nM/tzM=";
  };

  preConfigure = ''
    chmod u+w -R "$NIX_BUILD_TOP"
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="$(mktemp -d)"
    yarn --offline prepare
    yarn --offline build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r deps/@gitbutler/ui/build "$out"

    runHook postInstall
  '';

  distPhase = "true";

  meta = rec {
    description = "The UI for GitButler.";
    homepage = "https://gitbutler.com";
    downloadPage = homepage;
    changelog = "https://github.com/gitbutlerapp/gitbutler/releases/tag/release/${version}";
    license = {
      fullName = "Functional Source License, Version 1.0, MIT Change License";
      url = "https://github.com/getsentry/fsl.software/blob/7a73b65596671c42fa8df81a42731cb1c226d8fa/FSL-1.0-MIT.template.md";
      free = true;
      redistributable = true;
    };
    maintainers = with lib.maintainers; [ hacker1024 ];
    platforms = with lib.platforms; all;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
