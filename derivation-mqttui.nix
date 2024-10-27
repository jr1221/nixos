{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "mqttui";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "Northeastern-Electric-Racing";
    repo = "mqttui";
    rev = "refs/tags/v${version}-ner";
    hash = "sha256-zQoQ+oClVg/vHBc8gsAVpBRRbg8q/xPfoosA3Ei8aps=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    allowBuiltinFetchGit = true;
  };
#
#   postPatch = ''
#     ln -sf ${./Cargo.lock} Cargo.lock
#   '';



  meta = with lib; {
    description = "Terminal client for MQTT";
    homepage = "https://github.com/EdJoPaTo/mqttui";
    changelog = "https://github.com/EdJoPaTo/mqttui/blob/v${version}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [
      fab
      sikmir
    ];
    mainProgram = "mqttui";
  };
}
