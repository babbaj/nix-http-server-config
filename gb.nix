{ lib, makeWrapper, buildGoModule, fetchFromGitHub, lepton }:

buildGoModule {
  pname = "gb-backup";
  version = "unstable-2021-11-01";

  src = fetchFromGitHub {
    owner = "babbaj";
    repo = "gb";
    rev = "7abfabeef7da8cd23d9891941c966dc99b35ecd9";
    sha256 = "sha256-ESQxGqJyE1Pk7VQverTO+w6QMdxACulP+NEEOsKIgD0=";
  };

  vendorSha256 = "sha256-H3Zf4VNJVX9C3GTeqU4YhNqCIQz1R55MfhrygDgJTxc=";

  nativeBuildInputs = [ makeWrapper ];

  checkInputs = [ lepton ];

  postFixup = ''
    wrapProgram $out/bin/gb --prefix PATH : ${lib.makeBinPath [ lepton ]}
  '';

  meta = with lib; {
    description = "Gamer Backup, a super opinionated cloud backup system";
    homepage = "https://github.com/leijurv/gb";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ babbaj ];
    platforms = platforms.unix;
  };
}
