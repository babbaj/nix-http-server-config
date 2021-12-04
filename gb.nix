{ lib, makeWrapper, buildGoModule, fetchFromGitHub, lepton }:

buildGoModule {
  pname = "gb-backup";
  version = "unstable-2021-11-01";

  src = fetchFromGitHub {
    owner = "leijurv";
    repo = "gb";
    rev = "a30388bda97666123ddb9f2bf870ac40ada3b583";
    sha256 = "sha256-s1zfcgjwdcM9KDumvviIF2K2Tx1V3MJ4z4wtgacxgfM=";
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
